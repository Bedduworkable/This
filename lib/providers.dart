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
  return await FirestoreService.getLead(leadId);
});

final activityLogsProvider = StreamProvider.family<List<ActivityLogModel>, String>((ref, leadId) {
  return FirestoreService.getActivityLogs(leadId);
});

// Lead Controller
class LeadController extends StateNotifier<AsyncValue<void>> {
  LeadController() : super(const AsyncValue.data(null));

  Future<String?> createLead(LeadModel lead) async {
    state = const AsyncValue.loading();
    try {
      final leadId = await FirestoreService.createLead(lead);
      state = const AsyncValue.data(null);
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
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final leadControllerProvider = StateNotifierProvider<LeadController, AsyncValue<void>>((ref) {
  return LeadController();
});

// Search and Filter Providers
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredLeadsProvider = Provider<List<LeadModel>>((ref) {
  final leads = ref.watch(userLeadsProvider).value ?? [];
  final query = ref.watch(searchQueryProvider);

  if (query.isEmpty) return leads;

  return leads.where((lead) {
    return lead.name.toLowerCase().contains(query.toLowerCase()) ||
        lead.phone.contains(query) ||
        lead.email.toLowerCase().contains(query.toLowerCase()) ||
        lead.source.toLowerCase().contains(query.toLowerCase()) ||
        lead.project.toLowerCase().contains(query.toLowerCase());
  }).toList();
});

final filteredAllLeadsProvider = Provider<List<LeadModel>>((ref) {
  final leads = ref.watch(allLeadsProvider).value ?? [];
  final query = ref.watch(searchQueryProvider);

  if (query.isEmpty) return leads;

  return leads.where((lead) {
    return lead.name.toLowerCase().contains(query.toLowerCase()) ||
        lead.phone.contains(query) ||
        lead.email.toLowerCase().contains(query.toLowerCase()) ||
        lead.source.toLowerCase().contains(query.toLowerCase()) ||
        lead.project.toLowerCase().contains(query.toLowerCase());
  }).toList();
});

// Status Filter Provider
final statusFilterProvider = StateProvider<LeadStatus?>((ref) => null);

final statusFilteredLeadsProvider = Provider<List<LeadModel>>((ref) {
  final leads = ref.watch(filteredLeadsProvider);
  final statusFilter = ref.watch(statusFilterProvider);

  if (statusFilter == null) return leads;

  return leads.where((lead) => lead.status == statusFilter).toList();
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

// Dashboard Statistics Providers
final leadStatsProvider = Provider<Map<String, int>>((ref) {
  final leads = ref.watch(userLeadsProvider).value ?? [];

  final stats = <String, int>{};
  stats['total'] = leads.length;

  for (final status in LeadStatus.values) {
    stats[status.name] = leads.where((lead) => lead.status == status).length;
  }

  return stats;
});

final adminLeadStatsProvider = Provider<Map<String, int>>((ref) {
  final leads = ref.watch(allLeadsProvider).value ?? [];

  final stats = <String, int>{};
  stats['total'] = leads.length;

  for (final status in LeadStatus.values) {
    stats[status.name] = leads.where((lead) => lead.status == status).length;
  }

  return stats;
});

// Form Providers
final leadFormProvider = StateNotifierProvider<LeadFormController, LeadFormState>((ref) {
  return LeadFormController();
});

class LeadFormState {
  final String name;
  final String phone;
  final String email;
  final String source;
  final String project;
  final LeadStatus status;
  final String remarks;
  final DateTime? followUp;

  LeadFormState({
    this.name = '',
    this.phone = '',
    this.email = '',
    this.source = '',
    this.project = '',
    this.status = LeadStatus.new_lead,
    this.remarks = '',
    this.followUp,
  });

  LeadFormState copyWith({
    String? name,
    String? phone,
    String? email,
    String? source,
    String? project,
    LeadStatus? status,
    String? remarks,
    DateTime? followUp,
  }) {
    return LeadFormState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      source: source ?? this.source,
      project: project ?? this.project,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      followUp: followUp ?? this.followUp,
    );
  }

  LeadModel toLead(String userId, {String? existingId}) {
    return LeadModel(
      id: existingId ?? '',
      userId: userId,
      name: name,
      phone: phone,
      email: email,
      source: source,
      project: project,
      status: status,
      remarks: remarks,
      followUp: followUp,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

class LeadFormController extends StateNotifier<LeadFormState> {
  LeadFormController() : super(LeadFormState());

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updatePhone(String phone) {
    state = state.copyWith(phone: phone);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updateSource(String source) {
    state = state.copyWith(source: source);
  }

  void updateProject(String project) {
    state = state.copyWith(project: project);
  }

  void updateStatus(LeadStatus status) {
    state = state.copyWith(status: status);
  }

  void updateRemarks(String remarks) {
    state = state.copyWith(remarks: remarks);
  }

  void updateFollowUp(DateTime? followUp) {
    state = state.copyWith(followUp: followUp);
  }

  void loadLead(LeadModel lead) {
    state = LeadFormState(
      name: lead.name,
      phone: lead.phone,
      email: lead.email,
      source: lead.source,
      project: lead.project,
      status: lead.status,
      remarks: lead.remarks,
      followUp: lead.followUp,
    );
  }

  void reset() {
    state = LeadFormState();
  }
}