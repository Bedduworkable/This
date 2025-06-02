import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'models.dart';
import 'providers.dart';
import 'widgets.dart';
import 'utils.dart';

// Admin Dashboard
class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminLeadStatsProvider);
    final allUsers = ref.watch(allUsersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => context.push('/leads'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE60023).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.admin_panel_settings,
                        color: const Color(0xFFE60023),
                        size: 32.w,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Panel',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          Text(
                            'Manage leads and send notifications',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),

            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    title: 'View All Leads',
                    subtitle: 'Browse and manage all leads',
                    icon: Icons.people_outline,
                    color: const Color(0xFF2196F3),
                    onTap: () => context.push('/admin/leads'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ActionCard(
                    title: 'Send Notification',
                    subtitle: 'Broadcast to users',
                    icon: Icons.notifications_outlined,
                    color: const Color(0xFFFF9800),
                    onTap: () => context.push('/admin/notifications'),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // System Stats
            Text(
              'System Overview',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),

            SizedBox(height: 12.h),

            // Lead Statistics
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              mainAxisSpacing: 12.w,
              crossAxisSpacing: 12.w,
              children: [
                StatsCard(
                  title: 'Total Leads',
                  value: '${stats['total'] ?? 0}',
                  icon: Icons.people_outline,
                  color: const Color(0xFF2196F3),
                ),
                StatsCard(
                  title: 'New Leads',
                  value: '${stats['new_lead'] ?? 0}',
                  icon: Icons.fiber_new,
                  color: const Color(0xFF9C27B0),
                ),
                StatsCard(
                  title: 'Won Deals',
                  value: '${stats['closed_won'] ?? 0}',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF4CAF50),
                ),
                StatsCard(
                  title: 'Lost Deals',
                  value: '${stats['closed_lost'] ?? 0}',
                  icon: Icons.cancel_outlined,
                  color: const Color(0xFFE53935),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Users Overview
            Text(
              'Users Overview',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),

            SizedBox(height: 12.h),

            allUsers.when(
              loading: () => const LoadingWidget(message: 'Loading users...'),
              error: (error, stack) => CustomErrorWidget(
                message: error.toString(),
                onRetry: () => ref.refresh(allUsersProvider),
              ),
              data: (users) => Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.people, color: const Color(0xFF666666), size: 20.w),
                          SizedBox(width: 8.w),
                          Text(
                            'Total Users: ${users.length}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.push('/admin/notifications'),
                            child: const Text('Send Notification'),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      ...users.take(5).map((user) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE60023).withOpacity(0.1),
                          child: Text(
                            AppHelpers.initials(user.email),
                            style: TextStyle(
                              color: const Color(0xFFE60023),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        title: Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Joined ${AppHelpers.formatDate(user.createdAt)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF666666),
                          ),
                        ),
                        trailing: user.isAdmin
                            ? Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE60023).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Admin',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: const Color(0xFFE60023),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                            : null,
                      )),
                      if (users.length > 5) ...[
                        SizedBox(height: 8.h),
                        Text(
                          '... and ${users.length - 5} more users',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF999999),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Action Card Widget
class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24.w),
              ),
              SizedBox(height: 12.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Admin Leads Screen
class AdminLeadsScreen extends ConsumerStatefulWidget {
  const AdminLeadsScreen({super.key});

  @override
  ConsumerState<AdminLeadsScreen> createState() => _AdminLeadsScreenState();
}

class _AdminLeadsScreenState extends ConsumerState<AdminLeadsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leads = ref.watch(filteredAllLeadsProvider);
    final statusFilter = ref.watch(statusFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('All Leads'),
        actions: [
          PopupMenuButton<LeadStatus?>(
            icon: Icon(
              Icons.filter_list,
              color: statusFilter != null ? const Color(0xFFE60023) : const Color(0xFF666666),
            ),
            onSelected: (status) {
              ref.read(statusFilterProvider.notifier).state = status;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Leads'),
              ),
              ...LeadStatus.values.map((status) => PopupMenuItem(
                value: status,
                child: Text(status.displayName),
              )),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          CustomSearchBar(
            controller: _searchController,
            onChanged: (query) {
              ref.read(searchQueryProvider.notifier).state = query;
            },
            hint: 'Search all leads...',
          ),

          // Status Filter Chips
          if (statusFilter != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Chip(
                    label: Text(statusFilter.displayName),
                    onDeleted: () {
                      ref.read(statusFilterProvider.notifier).state = null;
                    },
                    deleteIcon: const Icon(Icons.close, size: 16),
                  ),
                ],
              ),
            ),

          // Quick Stats
          Container(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Total',
                    value: '${leads.length}',
                    icon: Icons.people_outline,
                    color: const Color(0xFF2196F3),
                  ),
                ),
                Expanded(
                  child: StatsCard(
                    title: 'Active',
                    value: '${leads.where((l) => l.status != LeadStatus.closed_won && l.status != LeadStatus.closed_lost).length}',
                    icon: Icons.trending_up,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
                Expanded(
                  child: StatsCard(
                    title: 'Closed',
                    value: '${leads.where((l) => l.status == LeadStatus.closed_won || l.status == LeadStatus.closed_lost).length}',
                    icon: Icons.done_all,
                    color: const Color(0xFF9C27B0),
                  ),
                ),
              ],
            ),
          ),

          // Leads List
          Expanded(
            child: leads.isEmpty
                ? EmptyState(
              title: 'No leads found',
              subtitle: _searchController.text.isNotEmpty
                  ? 'Try adjusting your search or filters'
                  : 'No leads in the system yet',
              icon: Icons.people_outline,
            )
                : ListView.builder(
              itemCount: leads.length,
              itemBuilder: (context, index) {
                return LeadCard(
                  lead: leads[index],
                  showUser: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Admin Notifications Screen
class AdminNotificationsScreen extends ConsumerStatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  ConsumerState<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends ConsumerState<AdminNotificationsScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    final selectedUsers = ref.read(selectedUsersProvider);
    if (selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one user'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await ref.read(notificationControllerProvider.notifier).sendBroadcastNotification(
      title: _titleController.text.trim(),
      message: _messageController.text.trim(),
      userIds: selectedUsers,
    );

    if (mounted) {
      // Clear form
      _titleController.clear();
      _messageController.clear();
      ref.read(selectedUsersProvider.notifier).state = [];

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification sent successfully'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allUsers = ref.watch(allUsersProvider);
    final selectedUsers = ref.watch(selectedUsersProvider);
    final notificationState = ref.watch(notificationControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Send Notifications'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Form Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Compose Notification',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Title
                      CustomTextField(
                        controller: _titleController,
                        label: 'Title',
                        prefixIcon: Icons.title,
                        validator: (value) => Validators.required(value, 'Title'),
                      ),

                      SizedBox(height: 16.h),

                      // Message
                      CustomTextField(
                        controller: _messageController,
                        label: 'Message',
                        hint: 'Enter your notification message...',
                        maxLines: 4,
                        validator: (value) => Validators.required(value, 'Message'),
                      ),

                      SizedBox(height: 20.h),

                      // Send Button
                      CustomButton(
                        text: 'Send Notification',
                        icon: Icons.send,
                        onPressed: selectedUsers.isNotEmpty ? _sendNotification : null,
                        isLoading: notificationState.isLoading,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // User Selection Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Select Recipients',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${selectedUsers.length} selected',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      allUsers.when(
                        loading: () => const LoadingWidget(message: 'Loading users...'),
                        error: (error, stack) => CustomErrorWidget(
                          message: error.toString(),
                          onRetry: () => ref.refresh(allUsersProvider),
                        ),
                        data: (users) {
                          final nonAdminUsers = users.where((user) => !user.isAdmin).toList();

                          return Column(
                            children: [
                              // Select All Button
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      ref.read(selectedUsersProvider.notifier).state =
                                          nonAdminUsers.map((u) => u.id).toList();
                                    },
                                    child: const Text('Select All'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ref.read(selectedUsersProvider.notifier).state = [];
                                    },
                                    child: const Text('Clear All'),
                                  ),
                                ],
                              ),

                              SizedBox(height: 8.h),

                              // User List
                              ...nonAdminUsers.map((user) => CheckboxListTile(
                                title: Text(
                                  user.email,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  'Joined ${AppHelpers.formatDate(user.createdAt)}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF666666),
                                  ),
                                ),
                                value: selectedUsers.contains(user.id),
                                onChanged: (bool? value) {
                                  final currentSelected = List<String>.from(selectedUsers);
                                  if (value == true) {
                                    currentSelected.add(user.id);
                                  } else {
                                    currentSelected.remove(user.id);
                                  }
                                  ref.read(selectedUsersProvider.notifier).state = currentSelected;
                                },
                                activeColor: const Color(0xFFE60023),
                                contentPadding: EdgeInsets.zero,
                              )),

                              if (nonAdminUsers.isEmpty)
                                const EmptyState(
                                  title: 'No users found',
                                  subtitle: 'No non-admin users to send notifications to',
                                  icon: Icons.people_outline,
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}