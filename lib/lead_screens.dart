import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'models.dart';
import 'providers.dart';
import 'widgets.dart';
import 'utils.dart';
import 'services.dart';

// Leads List Screen
class LeadsListScreen extends ConsumerStatefulWidget {
  const LeadsListScreen({super.key});

  @override
  ConsumerState<LeadsListScreen> createState() => _LeadsListScreenState();
}

class _LeadsListScreenState extends ConsumerState<LeadsListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leads = ref.watch(statusFilteredLeadsProvider);
    final statusFilter = ref.watch(statusFilterProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('My Leads'),
        actions: [
          // Filter Button
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

          // Stats Summary
          Container(
            padding: EdgeInsets.all(16.w),
            child: Consumer(
              builder: (context, ref, child) {
                final stats = ref.watch(leadStatsProvider);
                return Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        title: 'Total Leads',
                        value: '${stats['total'] ?? 0}',
                        icon: Icons.people_outline,
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                    Expanded(
                      child: StatsCard(
                        title: 'Won',
                        value: '${stats['closed_won'] ?? 0}',
                        icon: Icons.check_circle_outline,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                    Expanded(
                      child: StatsCard(
                        title: 'In Progress',
                        value: '${(stats['contacted'] ?? 0) + (stats['qualified'] ?? 0) + (stats['proposal_sent'] ?? 0)}',
                        icon: Icons.trending_up,
                        color: const Color(0xFFFF9800),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Leads List
          Expanded(
            child: leads.isEmpty
                ? EmptyState(
              title: 'No leads found',
              subtitle: _searchController.text.isNotEmpty
                  ? 'Try adjusting your search or filters'
                  : 'Start by adding your first lead',
              icon: Icons.people_outline,
              buttonText: 'Add Lead',
              onButtonPressed: () => context.push('/add-lead'),
            )
                : ListView.builder(
              itemCount: leads.length,
              itemBuilder: (context, index) {
                return LeadCard(lead: leads[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-lead'),
        backgroundColor: const Color(0xFFE60023),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// Lead Detail Screen
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
                              child: Text(
                                lead.name,
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF333333),
                                ),
                              ),
                            ),
                            LeadStatusChip(status: lead.status),
                          ],
                        ),

                        SizedBox(height: 20.h),

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
                                    // Show call outcome dialog
                                    showDialog(
                                      context: context,
                                      builder: (context) => CallOutcomeDialog(
                                        leadId: leadId,
                                        leadName: lead.name,
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
                                onPressed: () => CallService.sendEmail(lead.email),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),

                        // Contact Details
                        _buildDetailRow('Phone', AppHelpers.formatPhoneNumber(lead.phone), Icons.phone),
                        if (lead.email.isNotEmpty)
                          _buildDetailRow('Email', lead.email, Icons.email),
                        _buildDetailRow('Source', lead.source, Icons.source),
                        if (lead.project.isNotEmpty)
                          _buildDetailRow('Project', lead.project, Icons.business),

                        if (lead.remarks.isNotEmpty) ...[
                          SizedBox(height: 16.h),
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

                        if (lead.followUp != null) ...[
                          SizedBox(height: 16.h),
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: lead.followUp!.isBefore(DateTime.now())
                                  ? const Color(0xFFFFEBEE)
                                  : const Color(0xFFE8F5E8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 20.w,
                                  color: lead.followUp!.isBefore(DateTime.now())
                                      ? const Color(0xFFE53935)
                                      : const Color(0xFF4CAF50),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Follow-up Reminder',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: lead.followUp!.isBefore(DateTime.now())
                                              ? const Color(0xFFE53935)
                                              : const Color(0xFF4CAF50),
                                        ),
                                      ),
                                      Text(
                                        AppHelpers.formatDateTime(lead.followUp!),
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: lead.followUp!.isBefore(DateTime.now())
                                              ? const Color(0xFFE53935)
                                              : const Color(0xFF4CAF50),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        SizedBox(height: 16.h),

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

                SizedBox(height: 100.h), // Space for FAB
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
      padding: EdgeInsets.symmetric(vertical: 8.h),
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
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF333333),
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

// Add/Edit Lead Screen
class AddEditLeadScreen extends ConsumerStatefulWidget {
  final String? leadId;

  const AddEditLeadScreen({super.key, this.leadId});

  @override
  ConsumerState<AddEditLeadScreen> createState() => _AddEditLeadScreenState();
}

class _AddEditLeadScreenState extends ConsumerState<AddEditLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  bool get isEditing => widget.leadId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadExistingLead();
    }
  }

  Future<void> _loadExistingLead() async {
    final lead = await ref.read(leadProvider(widget.leadId!).future);
    if (lead != null && mounted) {
      ref.read(leadFormProvider.notifier).loadLead(lead);
    }
  }

  Future<void> _saveLead() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = AuthService.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final formState = ref.read(leadFormProvider);
      final newLead = formState.toLead(currentUser.uid, existingId: widget.leadId);

      if (isEditing) {
        // Update existing lead
        final oldLead = await ref.read(leadProvider(widget.leadId!).future);
        if (oldLead != null) {
          await ref.read(leadControllerProvider.notifier).updateLead(
            widget.leadId!,
            oldLead,
            newLead,
          );
        }
      } else {
        // Create new lead
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
    final formState = ref.watch(leadFormProvider);
    final formController = ref.read(leadFormProvider.notifier);

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
                        controller: TextEditingController(text: formState.name)..selection = TextSelection.collapsed(offset: formState.name.length),
                        label: 'Name',
                        prefixIcon: Icons.person_outline,
                        validator: Validators.name,
                        onTap: () {},
                      ),

                      SizedBox(height: 16.h),

                      // Phone
                      CustomTextField(
                        controller: TextEditingController(text: formState.phone)..selection = TextSelection.collapsed(offset: formState.phone.length),
                        label: 'Phone',
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        validator: Validators.phone,
                        onTap: () {},
                      ),

                      SizedBox(height: 16.h),

                      // Email
                      CustomTextField(
                        controller: TextEditingController(text: formState.email)..selection = TextSelection.collapsed(offset: formState.email.length),
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (value) => value?.isNotEmpty == true ? Validators.email(value) : null,
                        onTap: () {},
                      ),

                      SizedBox(height: 16.h),

                      // Source
                      CustomDropdown<String>(
                        label: 'Source',
                        value: formState.source.isNotEmpty ? formState.source : null,
                        items: AppConstants.leadSources,
                        getDisplayText: (source) => source,
                        onChanged: (value) => formController.updateSource(value ?? ''),
                        validator: (value) => Validators.required(value, 'Source'),
                      ),

                      SizedBox(height: 16.h),

                      // Project
                      CustomDropdown<String>(
                        label: 'Project',
                        value: formState.project.isNotEmpty ? formState.project : null,
                        items: AppConstants.projects,
                        getDisplayText: (project) => project,
                        onChanged: (value) => formController.updateProject(value ?? ''),
                        validator: (value) => Validators.required(value, 'Project'),
                      ),

                      SizedBox(height: 16.h),

                      // Status
                      CustomDropdown<LeadStatus>(
                        label: 'Status',
                        value: formState.status,
                        items: LeadStatus.values,
                        getDisplayText: (status) => status.displayName,
                        onChanged: (value) => formController.updateStatus(value ?? LeadStatus.new_lead),
                      ),

                      SizedBox(height: 16.h),

                      // Remarks
                      CustomTextField(
                        controller: TextEditingController(text: formState.remarks)..selection = TextSelection.collapsed(offset: formState.remarks.length),
                        label: 'Remarks',
                        hint: 'Add any additional notes...',
                        maxLines: 3,
                        onTap: () {},
                      ),

                      SizedBox(height: 16.h),

                      // Follow-up Date
                      CustomTextField(
                        controller: TextEditingController(
                            text: formState.followUp != null
                                ? AppHelpers.formatDateTime(formState.followUp!)
                                : ''
                        ),
                        label: 'Follow-up Reminder',
                        hint: 'Select date and time',
                        prefixIcon: Icons.schedule,
                        enabled: false,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: formState.followUp ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );

                          if (date != null && mounted) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(formState.followUp ?? DateTime.now()),
                            );

                            if (time != null) {
                              final followUp = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                              formController.updateFollowUp(followUp);
                            }
                          }
                        },
                      ),

                      if (formState.followUp != null) ...[
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            const Spacer(),
                            TextButton(
                              onPressed: () => formController.updateFollowUp(null),
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

              // Save Button
              CustomButton(
                text: isEditing ? 'Update Lead' : 'Create Lead',
                onPressed: _saveLead,
                isLoading: _isLoading,
              ),

              SizedBox(height: 100.h), // Safe area for bottom
            ],
          ),
        ),
      ),
    );
  }
}