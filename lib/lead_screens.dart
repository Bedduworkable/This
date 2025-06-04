import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'models.dart';
import 'providers.dart';
import 'widgets.dart';
import 'utils.dart';
import 'services.dart';

// Premium Dashboard with Modern Design
class LeadsListScreen extends ConsumerWidget {
  const LeadsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final stats = ref.watch(leadStatsProvider);
    final recentLeads = ref.watch(userLeadsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Premium Header Section
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 30.h),
                child: Column(
                  children: [
                    // Top Navigation Bar
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.dashboard_rounded,
                            color: Colors.white,
                            size: 24.w,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lead Dashboard',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Manage your business efficiently',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Action Buttons
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.settings, color: Colors.white, size: 20.w),
                            onPressed: () => context.push('/custom-fields'),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        if (isAdmin.value == true)
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.admin_panel_settings, color: Colors.white, size: 20.w),
                              onPressed: () => context.push('/admin'),
                            ),
                          ),
                        SizedBox(width: 8.w),
                        PopupMenuButton(
                          icon: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.account_circle, color: Colors.white, size: 20.w),
                          ),
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

                    SizedBox(height: 30.h),

                    // Stats Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: _PremiumStatsCard(
                            title: 'Total Leads',
                            value: '${stats['total'] ?? 0}',
                            icon: Icons.people_outline,
                            color: const Color(0xFF10B981),
                            trend: '+12%',
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _PremiumStatsCard(
                            title: 'Active',
                            value: '${stats['active'] ?? 0}',
                            icon: Icons.trending_up,
                            color: const Color(0xFFF59E0B),
                            trend: '+5%',
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _PremiumStatsCard(
                            title: 'Closed',
                            value: '${stats['completed'] ?? 0}',
                            icon: Icons.check_circle_outline,
                            color: const Color(0xFF8B5CF6),
                            trend: '+8%',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Main Content Area
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Actions Section
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Action Cards Grid
                    Row(
                      children: [
                        Expanded(
                          child: _PremiumActionCard(
                            title: 'Browse by Status',
                            subtitle: 'View leads by their current status',
                            icon: Icons.flag_outlined,
                            color: const Color(0xFFEF4444),
                            onTap: () => context.push('/leads/by-status'),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _PremiumActionCard(
                            title: 'Browse by Project',
                            subtitle: 'Organize by project type',
                            icon: Icons.business_outlined,
                            color: const Color(0xFF10B981),
                            onTap: () => context.push('/leads/by-project'),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    Row(
                      children: [
                        Expanded(
                          child: _PremiumActionCard(
                            title: 'Browse by Source',
                            subtitle: 'Track lead sources',
                            icon: Icons.source_outlined,
                            color: const Color(0xFF3B82F6),
                            onTap: () => context.push('/leads/by-source'),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _PremiumActionCard(
                            title: 'Add New Lead',
                            subtitle: 'Create a new lead entry',
                            icon: Icons.add_circle_outline,
                            color: const Color(0xFF8B5CF6),
                            onTap: () => context.push('/add-lead'),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Recent Activity Section
                    Row(
                      children: [
                        Text(
                          'Recent Leads',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => context.push('/leads/by-status'),
                          child: Text(
                            'View All',
                            style: TextStyle(
                              color: const Color(0xFF3B82F6),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    // Recent Leads List
                    Expanded(
                      child: recentLeads.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Center(
                          child: Text(
                            'Error loading leads',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        data: (leads) {
                          final recentLeadsList = leads.take(3).toList();
                          if (recentLeadsList.isEmpty) {
                            return _EmptyLeadsCard();
                          }
                          return Column(
                            children: recentLeadsList.map((lead) => _RecentLeadCard(lead: lead)).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Premium Stats Card Widget
class _PremiumStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const _PremiumStatsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16.w),
              ),
              const Spacer(),
              Text(
                trend,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// Premium Action Card Widget
class _PremiumActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PremiumActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2937).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24.w),
                ),
                SizedBox(height: 16.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Recent Lead Card Widget
class _RecentLeadCard extends StatelessWidget {
  final LeadModel lead;

  const _RecentLeadCard({required this.lead});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2937).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/lead/${lead.id}'),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3B82F6).withOpacity(0.8),
                    const Color(0xFF1E40AF),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  AppHelpers.initials(lead.name),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lead.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    AppHelpers.formatPhoneNumber(lead.phone),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(lead.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    lead.status,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: _getStatusColor(lead.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  AppHelpers.timeAgo(lead.updatedAt),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'untouched lead':
        return const Color(0xFF3B82F6);
      case 'site visit follow-up':
        return const Color(0xFFF59E0B);
      case 'site visit completed':
        return const Color(0xFF10B981);
      case 'not interested':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }
}

// Empty Leads Card Widget
class _EmptyLeadsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.people_outline,
              color: const Color(0xFF3B82F6),
              size: 32.w,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No leads yet',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Start by adding your first lead',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.push('/add-lead'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Add Lead'),
          ),
        ],
      ),
    );
  }
}

// NEW: Leads by Status Screen (List View)
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

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: PremiumAppBar(
        title: 'Leads by Status',
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
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: statuses.when(
              data: (statusList) => Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    hint: const Text('Filter by Status'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Statuses'),
                      ),
                      ...statusList.map((status) => DropdownMenuItem<String>(
                        value: status.name,
                        child: Text(status.name),
                      )),
                    ],
                    onChanged: (value) => setState(() => _selectedStatus = value),
                  ),
                ),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error loading statuses'),
            ),
          ),

          // Leads List
          Expanded(
            child: filteredLeads.isEmpty
                ? const EmptyState(
              title: 'No leads found',
              subtitle: 'Try adjusting your search or filters',
              icon: Icons.people_outline,
            )
                : ListView.builder(
              itemCount: filteredLeads.length,
              itemBuilder: (context, index) {
                return LeadListTile(lead: filteredLeads[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// NEW: Leads by Project Screen (List View)
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

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: PremiumAppBar(
        title: 'Leads by Project',
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
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: projects.when(
              data: (projectList) => Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedProject,
                    hint: const Text('Filter by Project'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Projects'),
                      ),
                      ...projectList.map((project) => DropdownMenuItem<String>(
                        value: project.name,
                        child: Text(project.name),
                      )),
                    ],
                    onChanged: (value) => setState(() => _selectedProject = value),
                  ),
                ),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error loading projects'),
            ),
          ),

          // Leads List
          Expanded(
            child: filteredLeads.isEmpty
                ? const EmptyState(
              title: 'No leads found',
              subtitle: 'Try adjusting your search or filters',
              icon: Icons.people_outline,
            )
                : ListView.builder(
              itemCount: filteredLeads.length,
              itemBuilder: (context, index) {
                return LeadListTile(lead: filteredLeads[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// NEW: Leads by Source Screen (List View)
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

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: PremiumAppBar(
        title: 'Leads by Source',
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
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: sources.when(
              data: (sourceList) => Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSource,
                    hint: const Text('Filter by Source'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Sources'),
                      ),
                      ...sourceList.map((source) => DropdownMenuItem<String>(
                        value: source.name,
                        child: Text(source.name),
                      )),
                    ],
                    onChanged: (value) => setState(() => _selectedSource = value),
                  ),
                ),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error loading sources'),
            ),
          ),

          // Leads List
          Expanded(
            child: filteredLeads.isEmpty
                ? const EmptyState(
              title: 'No leads found',
              subtitle: 'Try adjusting your search or filters',
              icon: Icons.people_outline,
            )
                : ListView.builder(
              itemCount: filteredLeads.length,
              itemBuilder: (context, index) {
                return LeadListTile(lead: filteredLeads[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// NEW: Lead List Tile Widget (Clean List Item)
class LeadListTile extends ConsumerWidget {
  final LeadModel lead;

  const LeadListTile({super.key, required this.lead});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: ListTile(
        onTap: () => context.push('/lead/${lead.id}'),
        leading: CircleAvatar(
          radius: 20.w,
          backgroundColor: const Color(0xFFE60023).withOpacity(0.1),
          child: Text(
            AppHelpers.initials(lead.name),
            style: TextStyle(
              color: const Color(0xFFE60023),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          lead.name,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppHelpers.formatPhoneNumber(lead.phone),
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF666666),
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(lead.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    lead.status,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: _getStatusColor(lead.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '• ${AppHelpers.timeAgo(lead.updatedAt)}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Call Button
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE60023).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: Icon(Icons.call, size: 18.w, color: const Color(0xFFE60023)),
                onPressed: () async {
                  final success = await CallService.makeCall(lead.phone);
                  if (success && context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => CallOutcomeDialog(
                        leadId: lead.id,
                        leadName: lead.name,
                      ),
                    );
                  }
                },
                constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.w),
                padding: EdgeInsets.all(6.w),
              ),
            ),

            // Follow-up indicator
            if (lead.followUp != null) ...[
              SizedBox(width: 8.w),
              Icon(
                Icons.schedule,
                size: 16.w,
                color: lead.followUp!.isBefore(DateTime.now())
                    ? const Color(0xFFE53935)
                    : const Color(0xFF4CAF50),
              ),
            ],
          ],
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'untouched lead':
        return const Color(0xFF2196F3);
      case 'site visit follow-up':
        return const Color(0xFFFF9800);
      case 'site visit completed':
        return const Color(0xFF4CAF50);
      case 'not interested':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}

// Lead Detail Screen - Keep existing implementation
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
        appBar: const PremiumAppBar(title: 'Lead Details'),
        body: CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(leadProvider(leadId)),
        ),
      ),
      data: (lead) {
        if (lead == null) {
          return Scaffold(
            appBar: const PremiumAppBar(title: 'Lead Not Found'),
            body: const EmptyState(
              title: 'Lead not found',
              subtitle: 'This lead may have been deleted or moved',
              icon: Icons.error_outline,
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          appBar: PremiumAppBar(
            title: lead.name,
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
      appBar: PremiumAppBar(
        title: isEditing ? 'Edit Lead' : 'Add Lead',
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