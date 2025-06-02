import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'models.dart';
import 'providers.dart';
import 'widgets.dart';
import 'utils.dart';
import 'services.dart';

// NEW: Navigation Dashboard (No Lead Display)
class LeadsListScreen extends ConsumerWidget {
  const LeadsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final stats = ref.watch(leadStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('My Leads'),
        actions: [
          // Edit Custom Fields Button
          IconButton(
            icon: const Icon(Icons.edit_attributes),
            onPressed: () => context.push('/custom-fields'),
            tooltip: 'Edit Custom Fields',
          ),
          // Admin Panel Access
          if (isAdmin.value == true)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => context.push('/admin'),
            ),
          // Profile/Logout
          PopupMenuButton(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                },
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: Color(0xFF666666)),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
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
                        Icons.business_center,
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
                            'Lead Management',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          Text(
                            'Organize and track your leads efficiently',
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

            // Stats Overview
            Text(
              'Overview',
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
                  child: CompactStatsCard(
                    title: 'Total Leads',
                    value: '${stats['total'] ?? 0}',
                    icon: Icons.people_outline,
                    color: const Color(0xFF2196F3),
                  ),
                ),
                Expanded(
                  child: CompactStatsCard(
                    title: 'Active',
                    value: '${stats['active'] ?? 0}',
                    icon: Icons.trending_up,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
                Expanded(
                  child: CompactStatsCard(
                    title: 'Completed',
                    value: '${stats['completed'] ?? 0}',
                    icon: Icons.check_circle_outline,
                    color: const Color(0xFFFF9800),
                  ),
                ),
              ],
            ),

            SizedBox(height: 32.h),

            // Navigation Buttons
            Text(
              'Browse Leads By',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),

            SizedBox(height: 16.h),

            // Status Button
            _NavigationCard(
              title: 'Status',
              subtitle: 'View leads by their current status',
              icon: Icons.flag_outlined,
              color: const Color(0xFFFF9800),
              onTap: () => context.push('/leads/by-status'),
            ),

            SizedBox(height: 12.h),

            // Project Button
            _NavigationCard(
              title: 'Project',
              subtitle: 'Browse leads by project type',
              icon: Icons.business_outlined,
              color: const Color(0xFF4CAF50),
              onTap: () => context.push('/leads/by-project'),
            ),

            SizedBox(height: 12.h),

            // Source Button
            _NavigationCard(
              title: 'Source',
              subtitle: 'Organize leads by their source',
              icon: Icons.source_outlined,
              color: const Color(0xFF2196F3),
              onTap: () => context.push('/leads/by-source'),
            ),

            SizedBox(height: 32.h),

            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),

            SizedBox(height: 16.h),

            // Add Lead Button
            CustomButton(
              text: 'Add New Lead',
              icon: Icons.add,
              onPressed: () => context.push('/add-lead'),
            ),
          ],
        ),
      ),
    );
  }
}

// Navigation Card Widget
class _NavigationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NavigationCard({
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
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: const Color(0xFF999999),
                size: 16.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// NEW: Leads by Status Screen
class LeadsByStatusScreen extends ConsumerStatefulWidget {
  const LeadsByStatusScreen({super.key});

  @override
  ConsumerState<LeadsByStatusScreen> createState() => _LeadsByStatusScreenState();
}

class _LeadsByStatusScreenState extends ConsumerState<LeadsByStatusScreen> {
  final _searchController = TextEditingController();
  String? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statuses = ref.watch(customFieldsProvider(CustomFieldType.status));
    final leads = ref.watch(filteredLeadsProvider);

    // Filter by selected status
    final filteredLeads = _selectedStatus == null
        ? leads
        : leads.where((lead) => lead.status == _selectedStatus).toList();

    // Group by status
    final groupedLeads = <String, List<LeadModel>>{};
    for (final lead in filteredLeads) {
      groupedLeads.putIfAbsent(lead.status, () => []).add(lead);
    }
    final sortedGroups = groupedLeads.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Leads by Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/add-lead'),
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
            hint: 'Search leads...',
          ),

          // Status Filter
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: statuses.when(
              data: (statusList) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Filter by Status',
                  border: OutlineInputBorder(),
                ),
                value: _selectedStatus,
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Statuses')),
                  ...statusList.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name))),
                ],
                onChanged: (value) => setState(() => _selectedStatus = value),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error loading statuses'),
            ),
          ),

          SizedBox(height: 16.h),

          // Grouped Leads
          Expanded(
            child: sortedGroups.isEmpty
                ? const EmptyState(
              title: 'No leads found',
              subtitle: 'Try adjusting your search or filters',
              icon: Icons.people_outline,
            )
                : ListView.builder(
              itemCount: sortedGroups.length,
              itemBuilder: (context, index) {
                final group = sortedGroups[index];
                return LeadGroupCard(
                  groupName: group.key,
                  leads: group.value,
                  groupBy: LeadGroupBy.status,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// NEW: Leads by Project Screen
class LeadsByProjectScreen extends ConsumerStatefulWidget {
  const LeadsByProjectScreen({super.key});

  @override
  ConsumerState<LeadsByProjectScreen> createState() => _LeadsByProjectScreenState();
}

class _LeadsByProjectScreenState extends ConsumerState<LeadsByProjectScreen> {
  final _searchController = TextEditingController();
  String? _selectedProject;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(customFieldsProvider(CustomFieldType.project));
    final leads = ref.watch(filteredLeadsProvider);

    // Filter by selected project
    final filteredLeads = _selectedProject == null
        ? leads
        : leads.where((lead) => lead.project == _selectedProject).toList();

    // Group by project
    final groupedLeads = <String, List<LeadModel>>{};
    for (final lead in filteredLeads) {
      groupedLeads.putIfAbsent(lead.project, () => []).add(lead);
    }
    final sortedGroups = groupedLeads.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Leads by Project'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/add-lead'),
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
            hint: 'Search leads...',
          ),

          // Project Filter
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: projects.when(
              data: (projectList) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Filter by Project',
                  border: OutlineInputBorder(),
                ),
                value: _selectedProject,
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Projects')),
                  ...projectList.map((p) => DropdownMenuItem(value: p.name, child: Text(p.name))),
                ],
                onChanged: (value) => setState(() => _selectedProject = value),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error loading projects'),
            ),
          ),

          SizedBox(height: 16.h),

          // Grouped Leads
          Expanded(
            child: sortedGroups.isEmpty
                ? const EmptyState(
              title: 'No leads found',
              subtitle: 'Try adjusting your search or filters',
              icon: Icons.people_outline,
            )
                : ListView.builder(
              itemCount: sortedGroups.length,
              itemBuilder: (context, index) {
                final group = sortedGroups[index];
                return LeadGroupCard(
                  groupName: group.key,
                  leads: group.value,
                  groupBy: LeadGroupBy.project,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// NEW: Leads by Source Screen
class LeadsBySourceScreen extends ConsumerStatefulWidget {
  const LeadsBySourceScreen({super.key});

  @override
  ConsumerState<LeadsBySourceScreen> createState() => _LeadsBySourceScreenState();
}

class _LeadsBySourceScreenState extends ConsumerState<LeadsBySourceScreen> {
  final _searchController = TextEditingController();
  String? _selectedSource;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sources = ref.watch(customFieldsProvider(CustomFieldType.source));
    final leads = ref.watch(filteredLeadsProvider);

    // Filter by selected source
    final filteredLeads = _selectedSource == null
        ? leads
        : leads.where((lead) => lead.source == _selectedSource).toList();

    // Group by source
    final groupedLeads = <String, List<LeadModel>>{};
    for (final lead in filteredLeads) {
      groupedLeads.putIfAbsent(lead.source, () => []).add(lead);
    }
    final sortedGroups = groupedLeads.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Leads by Source'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/add-lead'),
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
            hint: 'Search leads...',
          ),

          // Source Filter
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: sources.when(
              data: (sourceList) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Filter by Source',
                  border: OutlineInputBorder(),
                ),
                value: _selectedSource,
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Sources')),
                  ...sourceList.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name))),
                ],
                onChanged: (value) => setState(() => _selectedSource = value),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error loading sources'),
            ),
          ),

          SizedBox(height: 16.h),

          // Grouped Leads
          Expanded(
            child: sortedGroups.isEmpty
                ? const EmptyState(
              title: 'No leads found',
              subtitle: 'Try adjusting your search or filters',
              icon: Icons.people_outline,
            )
                : ListView.builder(
              itemCount: sortedGroups.length,
              itemBuilder: (context, index) {
                final group = sortedGroups[index];
                return LeadGroupCard(
                  groupName: group.key,
                  leads: group.value,
                  groupBy: LeadGroupBy.source,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Lead Group Card Widget
class LeadGroupCard extends StatefulWidget {
  final String groupName;
  final List<LeadModel> leads;
  final LeadGroupBy groupBy;

  const LeadGroupCard({
    super.key,
    required this.groupName,
    required this.leads,
    required this.groupBy,
  });

  @override
  State<LeadGroupCard> createState() => _LeadGroupCardState();
}

class _LeadGroupCardState extends State<LeadGroupCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          // Group Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: _getGroupColor(widget.groupBy).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getGroupIcon(widget.groupBy),
                      color: _getGroupColor(widget.groupBy),
                      size: 20.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.groupName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        Text(
                          '${widget.leads.length} lead${widget.leads.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF666666),
                  ),
                ],
              ),
            ),
          ),

          // Group Content
          if (_isExpanded)
            Column(
              children: widget.leads.map((lead) => CompactLeadCard(lead: lead)).toList(),
            ),
        ],
      ),
    );
  }

  Color _getGroupColor(LeadGroupBy groupBy) {
    switch (groupBy) {
      case LeadGroupBy.source:
        return const Color(0xFF2196F3);
      case LeadGroupBy.status:
        return const Color(0xFFFF9800);
      case LeadGroupBy.project:
        return const Color(0xFF4CAF50);
    }
  }

  IconData _getGroupIcon(LeadGroupBy groupBy) {
    switch (groupBy) {
      case LeadGroupBy.source:
        return Icons.source_outlined;
      case LeadGroupBy.status:
        return Icons.flag_outlined;
      case LeadGroupBy.project:
        return Icons.business_outlined;
    }
  }
}

// Lead Detail Screen - Updated to work with new string-based status
class LeadDetailScreen extends ConsumerWidget {
  final String leadId;

  const LeadDetailScreen({super.key, required this.leadId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadAsync = ref.watch(leadProvider(leadId));
    final activityLogs = ref.watch(activityLogsProvider(leadId));

    return leadAsync.when(
      loading: () => const Scaffold(
        body: LoadingWidget(message: 'Loading lead details...'),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Lead Details')),
        body: CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(leadProvider(leadId)),
        ),
      ),
      data: (lead) {
        if (lead == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Lead Not Found')),
            body: const EmptyState(
              title: 'Lead not found',
              subtitle: 'This lead may have been deleted or moved',
              icon: Icons.error_outline,
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          appBar: AppBar(
            title: Text(lead.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/edit-lead/$leadId'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Lead Info Card
                Card(
                  margin: EdgeInsets.all(16.w),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and Status
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lead Name',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF999999),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    lead.name,
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.w),
                            CustomStatusChip(status: lead.status),
                          ],
                        ),

                        SizedBox(height: 24.h),

                        // Contact Actions
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'Call',
                                icon: Icons.call,
                                onPressed: () async {
                                  final success = await CallService.makeCall(lead.phone);
                                  if (success && context.mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => CallOutcomeDialog(
                                        leadId: leadId,
                                        leadName: lead.name,
                                      ),
                                    );
                                  } else if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Unable to make call. Please check phone settings.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: CustomButton(
                                text: 'Email',
                                icon: Icons.email,
                                backgroundColor: const Color(0xFF2196F3),
                                onPressed: () async {
                                  if (lead.email.isNotEmpty) {
                                    await CallService.sendEmail(lead.email);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('No email address available'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),

                        // Contact Details
                        _buildDetailRow('Phone Number', AppHelpers.formatPhoneNumber(lead.phone), Icons.phone),
                        if (lead.email.isNotEmpty)
                          _buildDetailRow('Email', lead.email, Icons.email),
                        _buildDetailRow('Source', lead.source, Icons.source),
                        _buildDetailRow('Project', lead.project, Icons.business),
                        _buildDetailRow('Status', lead.status, Icons.flag),

                        if (lead.remarks.isNotEmpty) ...[
                          SizedBox(height: 20.h),
                          Text(
                            'Remarks',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              lead.remarks,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF666666),
                              ),
                            ),
                          ),
                        ],

                        // Follow-up section
                        if (lead.followUp != null) ...[
                          SizedBox(height: 20.h),
                          FollowUpCard(
                            leadId: leadId,
                            followUpDate: lead.followUp!,
                            leadName: lead.name,
                          ),
                        ],

                        SizedBox(height: 20.h),

                        // Timestamps
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailRow(
                                'Created',
                                AppHelpers.formatDateTime(lead.createdAt),
                                Icons.add_circle_outline,
                              ),
                            ),
                            Expanded(
                              child: _buildDetailRow(
                                'Updated',
                                AppHelpers.timeAgo(lead.updatedAt),
                                Icons.update,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Follow-up Action Button
                if (lead.followUp == null)
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: CustomButton(
                        text: 'Set Follow-up Reminder',
                        icon: Icons.schedule,
                        backgroundColor: const Color(0xFF4CAF50),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 1)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );

                          if (date != null && context.mounted) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: const TimeOfDay(hour: 9, minute: 0),
                            );

                            if (time != null && context.mounted) {
                              final followUp = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );

                              final updatedLead = lead.copyWith(
                                followUp: followUp,
                                updatedAt: DateTime.now(),
                              );

                              await ref.read(leadControllerProvider.notifier).updateLead(
                                leadId,
                                lead,
                                updatedLead,
                              );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Follow-up reminder set successfully'),
                                    backgroundColor: Color(0xFF4CAF50),
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ),
                  ),

                SizedBox(height: 16.h),

                // Activity Log Card
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activity Log',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        activityLogs.when(
                          loading: () => const LoadingWidget(),
                          error: (error, stack) => Text(
                            'Error loading activities: $error',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.red,
                            ),
                          ),
                          data: (logs) {
                            if (logs.isEmpty) {
                              return const EmptyState(
                                title: 'No activities yet',
                                subtitle: 'Activities will appear here as you interact with this lead',
                                icon: Icons.history,
                              );
                            }
                            return Column(
                              children: logs.map((log) => ActivityLogTile(log: log)).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 100.h),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/edit-lead/$leadId'),
            backgroundColor: const Color(0xFFE60023),
            child: const Icon(Icons.edit, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.w, color: const Color(0xFF666666)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF999999),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Add/Edit Lead Screen - Updated for custom fields
class AddEditLeadScreen extends ConsumerStatefulWidget {
  final String? leadId;

  const AddEditLeadScreen({super.key, this.leadId});

  @override
  ConsumerState<AddEditLeadScreen> createState() => _AddEditLeadScreenState();
}

class _AddEditLeadScreenState extends ConsumerState<AddEditLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _remarksController = TextEditingController();

  String? _selectedSource;
  String? _selectedProject;
  String? _selectedStatus;
  DateTime? _followUp;

  bool _isLoading = false;

  bool get isEditing => widget.leadId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadExistingLead();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingLead() async {
    try {
      final lead = await ref.read(leadProvider(widget.leadId!).future);

      if (lead != null && mounted) {
        _nameController.text = lead.name;
        _phoneController.text = lead.phone;
        _emailController.text = lead.email;
        _remarksController.text = lead.remarks;
        _selectedSource = lead.source;
        _selectedProject = lead.project;
        _selectedStatus = lead.status;
        _followUp = lead.followUp;
        setState(() {});
      }
    } catch (e) {
      print('Error loading lead: $e');
    }
  }

  Future<void> _saveLead() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSource == null || _selectedProject == null || _selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Source, Project, and Status'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = AuthService.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final newLead = LeadModel(
        id: widget.leadId ?? '',
        userId: currentUser.uid,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        source: _selectedSource!,
        project: _selectedProject!,
        status: _selectedStatus!,
        remarks: _remarksController.text.trim(),
        followUp: _followUp,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditing) {
        final oldLead = await ref.read(leadProvider(widget.leadId!).future);
        if (oldLead != null) {
          await ref.read(leadControllerProvider.notifier).updateLead(
            widget.leadId!,
            oldLead,
            newLead,
          );
          ref.invalidate(leadProvider(widget.leadId!));
        }
      } else {
        final leadId = await ref.read(leadControllerProvider.notifier).createLead(newLead);
        if (leadId != null && mounted) {
          context.go('/lead/$leadId');
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Lead updated successfully' : 'Lead created successfully'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sources = ref.watch(customFieldsProvider(CustomFieldType.source));
    final projects = ref.watch(customFieldsProvider(CustomFieldType.project));
    final statuses = ref.watch(customFieldsProvider(CustomFieldType.status));

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Lead' : 'Add Lead'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveLead,
            child: Text(
              isEditing ? 'Update' : 'Save',
              style: TextStyle(
                color: _isLoading ? const Color(0xFF999999) : const Color(0xFFE60023),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lead Information',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Name
                      CustomTextField(
                        controller: _nameController,
                        label: 'Name',
                        prefixIcon: Icons.person_outline,
                        validator: Validators.name,
                      ),

                      SizedBox(height: 16.h),

                      // Phone
                      CustomTextField(
                        controller: _phoneController,
                        label: 'Phone',
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        validator: Validators.phone,
                      ),

                      SizedBox(height: 16.h),

                      // Email
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (value) => value?.isNotEmpty == true ? Validators.email(value) : null,
                      ),

                      SizedBox(height: 16.h),

                      // Source
                      sources.when(
                        data: (sourceList) => CustomDropdown<String>(
                          label: 'Source',
                          value: _selectedSource,
                          items: sourceList.map((s) => s.name).toList(),
                          getDisplayText: (source) => source,
                          onChanged: (value) => setState(() => _selectedSource = value),
                          validator: (value) => Validators.required(value, 'Source'),
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text('Error loading sources'),
                      ),

                      SizedBox(height: 16.h),

                      // Project
                      projects.when(
                        data: (projectList) => CustomDropdown<String>(
                          label: 'Project',
                          value: _selectedProject,
                          items: projectList.map((p) => p.name).toList(),
                          getDisplayText: (project) => project,
                          onChanged: (value) => setState(() => _selectedProject = value),
                          validator: (value) => Validators.required(value, 'Project'),
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text('Error loading projects'),
                      ),

                      SizedBox(height: 16.h),

                      // Status
                      statuses.when(
                        data: (statusList) => CustomDropdown<String>(
                          label: 'Status',
                          value: _selectedStatus,
                          items: statusList.map((s) => s.name).toList(),
                          getDisplayText: (status) => status,
                          onChanged: (value) => setState(() => _selectedStatus = value),
                          validator: (value) => Validators.required(value, 'Status'),
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text('Error loading statuses'),
                      ),

                      SizedBox(height: 16.h),

                      // Remarks
                      CustomTextField(
                        controller: _remarksController,
                        label: 'Remarks',
                        hint: 'Add any additional notes...',
                        maxLines: 3,
                      ),

                      SizedBox(height: 16.h),

                      // Follow-up Date
                      CustomTextField(
                        controller: TextEditingController(
                            text: _followUp != null
                                ? AppHelpers.formatDateTime(_followUp!)
                                : ''
                        ),
                        label: 'Follow-up Reminder',
                        hint: 'Select date and time',
                        prefixIcon: Icons.schedule,
                        enabled: false,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _followUp ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );

                          if (date != null && mounted) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(_followUp ?? DateTime.now()),
                            );

                            if (time != null) {
                              setState(() {
                                _followUp = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        },
                      ),

                      if (_followUp != null) ...[
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            const Spacer(),
                            TextButton(
                              onPressed: () => setState(() => _followUp = null),
                              child: Text(
                                'Clear',
                                style: TextStyle(
                                  color: const Color(0xFFE60023),
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              CustomButton(
                text: isEditing ? 'Update Lead' : 'Create Lead',
                onPressed: _saveLead,
                isLoading: _isLoading,
              ),

              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
    );
  }
}