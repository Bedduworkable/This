import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services.dart';
import 'models.dart';

// Auth Providers
final authStateProvider = StreamProvider<User?>((ref) {
  return AuthService.authStateChanges;
});

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user != null) {
    return await AuthService.getUserData(user.uid);
  }
  return null;
});

final isAdminProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user != null) {
    return await FirestoreService.isUserAdmin(user.uid);
  }
  return false;
});

// Auth Controller
class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController() : super(const AsyncValue.data(null));

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      await AuthService.signUp(email: email, password: password);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      await AuthService.signIn(email: email, password: password);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();
    try {
      await AuthService.sendPasswordResetEmail(email);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await AuthService.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController();
});

// Custom Fields Providers - NEW
final customFieldsProvider = StreamProvider.family<List<CustomFieldModel>, CustomFieldType>((ref, type) {
  return FirestoreService.getCustomFields(type);
});

// Custom Fields Controller - NEW
class CustomFieldsController extends StateNotifier<AsyncValue<void>> {
  CustomFieldsController(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  Future<void> addCustomField(CustomFieldType type, String name) async {
    state = const AsyncValue.loading();
    try {
      final field = CustomFieldModel(
        id: '',
        name: name,
        type: type,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirestoreService.createCustomField(field);
      state = const AsyncValue.data(null);

      // Refresh the custom fields
      ref.invalidate(customFieldsProvider(type));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateCustomField(
    String fieldId,
    CustomFieldType type,
    String newName,
  ) async {
    state = const AsyncValue.loading();
    try {
      await FirestoreService.updateCustomField(fieldId, newName);
      state = const AsyncValue.data(null);

      // Refresh the updated custom field list
      ref.invalidate(customFieldsProvider(type));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final customFieldsControllerProvider = StateNotifierProvider<CustomFieldsController, AsyncValue<void>>((ref) {
  return CustomFieldsController(ref);
});

// Lead Providers
final userLeadsProvider = StreamProvider<List<LeadModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user != null) {
    return FirestoreService.getUserLeads(user.uid);
  }
  return Stream.value([]);
});

final allLeadsProvider = StreamProvider<List<LeadModel>>((ref) {
  return FirestoreService.getAllLeads();
});

final leadProvider = FutureProvider.family<LeadModel?, String>((ref, leadId) async {
  ref.watch(userLeadsProvider);
  return await FirestoreService.getLead(leadId);
});

final activityLogsProvider = StreamProvider.family<List<ActivityLogModel>, String>((ref, leadId) {
  return FirestoreService.getActivityLogs(leadId);
});

// Lead Controller
class LeadController extends StateNotifier<AsyncValue<void>> {
  LeadController(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  Future<String?> createLead(LeadModel lead) async {
    state = const AsyncValue.loading();
    try {
      final leadId = await FirestoreService.createLead(lead);
      state = const AsyncValue.data(null);

      ref.invalidate(userLeadsProvider);

      return leadId;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<void> updateLead(String leadId, LeadModel oldLead, LeadModel newLead) async {
    state = const AsyncValue.loading();
    try {
      await FirestoreService.updateLead(leadId, oldLead, newLead);
      state = const AsyncValue.data(null);

      ref.invalidate(userLeadsProvider);
      ref.invalidate(leadProvider(leadId));

    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> logCallActivity({
    required String leadId,
    required String outcome,
    required String notes,
  }) async {
    try {
      await FirestoreService.logCallActivity(
        leadId: leadId,
        outcome: outcome,
        notes: notes,
      );

      ref.invalidate(activityLogsProvider(leadId));

    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final leadControllerProvider = StateNotifierProvider<LeadController, AsyncValue<void>>((ref) {
  return LeadController(ref);
});

// Search and Filter Providers
final searchQueryProvider = StateProvider<String>((ref) => '');

// Lead Filter Model - NEW
class LeadFilter {
  final String? source;
  final String? project;
  final String? status;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const LeadFilter({
    this.source,
    this.project,
    this.status,
    this.dateFrom,
    this.dateTo,
  });
}

final leadFilterProvider = StateProvider<LeadFilter>((ref) => const LeadFilter());

// Filtered Leads Provider - Updated
final filteredLeadsProvider = Provider<List<LeadModel>>((ref) {
  final leads = ref.watch(userLeadsProvider).value ?? [];
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(leadFilterProvider);

  var filteredLeads = leads;

  // Apply search
  if (query.isNotEmpty) {
    filteredLeads = filteredLeads.where((lead) {
      final searchText = '${lead.name} ${lead.phone} ${lead.email} ${lead.source} ${lead.project} ${lead.status}'.toLowerCase();
      return searchText.contains(query) ||
          lead.name.toLowerCase().contains(query) ||
          lead.phone.replaceAll(RegExp(r'[^\d]'), '').contains(query.replaceAll(RegExp(r'[^\d]'), '')) ||
          lead.email.toLowerCase().contains(query) ||
          lead.source.toLowerCase().contains(query) ||
          lead.project.toLowerCase().contains(query) ||
          lead.status.toLowerCase().contains(query);
    }).toList();
  }

  // Apply filters
  if (filter.source != null) {
    filteredLeads = filteredLeads.where((lead) => lead.source == filter.source).toList();
  }
  if (filter.project != null) {
    filteredLeads = filteredLeads.where((lead) => lead.project == filter.project).toList();
  }
  if (filter.status != null) {
    filteredLeads = filteredLeads.where((lead) => lead.status == filter.status).toList();
  }
  if (filter.dateFrom != null) {
    filteredLeads = filteredLeads.where((lead) => lead.createdAt.isAfter(filter.dateFrom!)).toList();
  }
  if (filter.dateTo != null) {
    final endDate = DateTime(filter.dateTo!.year, filter.dateTo!.month, filter.dateTo!.day, 23, 59, 59);
    filteredLeads = filteredLeads.where((lead) => lead.createdAt.isBefore(endDate)).toList();
  }

  return filteredLeads;
});

// Lead Grouping - NEW
enum LeadGroupBy { source, status, project }

final groupedLeadsProvider = Provider.family<List<MapEntry<String, List<LeadModel>>>, LeadGroupBy>((ref, groupBy) {
  final leads = ref.watch(filteredLeadsProvider);

  final Map<String, List<LeadModel>> grouped = {};

  for (final lead in leads) {
    String key;
    switch (groupBy) {
      case LeadGroupBy.source:
        key = lead.source;
        break;
      case LeadGroupBy.status:
        key = lead.status;
        break;
      case LeadGroupBy.project:
        key = lead.project;
        break;
    }

    grouped.putIfAbsent(key, () => []).add(lead);
  }

  // Sort groups by count (descending)
  final sortedEntries = grouped.entries.toList()
    ..sort((a, b) => b.value.length.compareTo(a.value.length));

  return sortedEntries;
});

// Admin Providers
final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  return await FirestoreService.getAllUsers();
});

final selectedUsersProvider = StateProvider<List<String>>((ref) => []);

// Notification Providers
final userNotificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user != null) {
    return FirestoreService.getUserNotifications(user.uid);
  }
  return Stream.value([]);
});

// Notification Controller
class NotificationController extends StateNotifier<AsyncValue<void>> {
  NotificationController() : super(const AsyncValue.data(null));

  Future<void> sendBroadcastNotification({
    required String title,
    required String message,
    required List<String> userIds,
  }) async {
    state = const AsyncValue.loading();
    try {
      final notification = NotificationModel(
        id: '',
        sentTo: userIds,
        title: title,
        message: message,
        type: NotificationType.broadcast,
        sentAt: DateTime.now(),
      );

      await FirestoreService.createNotification(notification);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final notificationControllerProvider = StateNotifierProvider<NotificationController, AsyncValue<void>>((ref) {
  return NotificationController();
});

// Reminder Providers
final upcomingRemindersProvider = Provider<List<LeadModel>>((ref) {
  final leads = ref.watch(userLeadsProvider).value ?? [];
  final now = DateTime.now();
  final tomorrow = now.add(const Duration(days: 1));

  return leads.where((lead) {
    if (lead.followUp == null) return false;
    return lead.followUp!.isAfter(now) && lead.followUp!.isBefore(tomorrow);
  }).toList();
});

final overdueRemindersProvider = Provider<List<LeadModel>>((ref) {
  final leads = ref.watch(userLeadsProvider).value ?? [];
  final now = DateTime.now();

  return leads.where((lead) {
    if (lead.followUp == null) return false;
    return lead.followUp!.isBefore(now);
  }).toList();
});

// Dashboard Statistics Providers - Updated
final leadStatsProvider = Provider<Map<String, int>>((ref) {
  final leads = ref.watch(userLeadsProvider).value ?? [];

  final stats = <String, int>{};
  stats['total'] = leads.length;

  // Define active vs completed statuses
  final completedStatuses = ['Site Visit Completed', 'Not Interested'];

  stats['active'] = leads.where((lead) => !completedStatuses.contains(lead.status)).length;
  stats['completed'] = leads.where((lead) => completedStatuses.contains(lead.status)).length;

  // Count by each status
  final statusCounts = <String, int>{};
  for (final lead in leads) {
    statusCounts[lead.status] = (statusCounts[lead.status] ?? 0) + 1;
  }
  stats.addAll(statusCounts);

  return stats;
});

final adminLeadStatsProvider = Provider<Map<String, int>>((ref) {
  final leads = ref.watch(allLeadsProvider).value ?? [];

  final stats = <String, int>{};
  stats['total'] = leads.length;

  // Define active vs completed statuses
  final completedStatuses = ['Site Visit Completed', 'Not Interested'];

  stats['active'] = leads.where((lead) => !completedStatuses.contains(lead.status)).length;
  stats['completed'] = leads.where((lead) => completedStatuses.contains(lead.status)).length;

  // Count by each status
  final statusCounts = <String, int>{};
  for (final lead in leads) {
    statusCounts[lead.status] = (statusCounts[lead.status] ?? 0) + 1;
  }
  stats.addAll(statusCounts);

  return stats;
});
