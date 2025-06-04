import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'models.dart';
import 'providers.dart';
import 'widgets.dart';
import 'utils.dart';

// Custom Fields Management Screen
class CustomFieldsScreen extends ConsumerStatefulWidget {
  const CustomFieldsScreen({super.key});

  @override
  ConsumerState<CustomFieldsScreen> createState() => _CustomFieldsScreenState();
}

class _CustomFieldsScreenState extends ConsumerState<CustomFieldsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PremiumAppBar(
        title: 'Manage Custom Fields',
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Sources'),
            Tab(text: 'Projects'),
            Tab(text: 'Status'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CustomFieldsList(type: CustomFieldType.source),
          CustomFieldsList(type: CustomFieldType.project),
          CustomFieldsList(type: CustomFieldType.status),
        ],
      ),
    );
  }
}

// Custom Fields List Widget
class CustomFieldsList extends ConsumerWidget {
  final CustomFieldType type;

  const CustomFieldsList({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customFields = ref.watch(customFieldsProvider(type));
    final controller = ref.read(customFieldsControllerProvider.notifier);

    return Column(
      children: [
        // Add Button
        Container(
          padding: EdgeInsets.all(16.w),
          width: double.infinity,
          child: CustomButton(
            text: 'Add New ${type.displayName}',
            icon: Icons.add,
            backgroundColor: const Color(0xFF3B82F6),
            onPressed: () => _showAddDialog(context, ref, type),
          ),
        ),

        // Fields List
        Expanded(
          child: customFields.when(
            loading: () => const LoadingWidget(message: 'Loading fields...'),
            error: (error, stack) => CustomErrorWidget(
              message: error.toString(),
              onRetry: () => ref.refresh(customFieldsProvider(type)),
            ),
            data: (fields) {
              if (fields.isEmpty) {
                return EmptyState(
                  title: 'No ${type.displayName.toLowerCase()}s found',
                  subtitle: 'Add your first ${type.displayName.toLowerCase()} to get started',
                  icon: Icons.category_outlined,
                  buttonText: 'Add ${type.displayName}',
                  onButtonPressed: () => _showAddDialog(context, ref, type),
                );
              }

              return ListView.builder(
                itemCount: fields.length,
                itemBuilder: (context, index) {
                  final field = fields[index];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
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
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      leading: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: _getTypeColor(type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getTypeIcon(type),
                          color: _getTypeColor(type),
                          size: 20.w,
                        ),
                      ),
                      title: Text(
                        field.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      subtitle: Text(
                        'Created ${AppHelpers.timeAgo(field.createdAt)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF6B7280)),
                        onPressed: () => _showEditDialog(context, ref, field),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(CustomFieldType type) {
    switch (type) {
      case CustomFieldType.source:
        return const Color(0xFF2196F3);
      case CustomFieldType.project:
        return const Color(0xFF4CAF50);
      case CustomFieldType.status:
        return const Color(0xFFFF9800);
    }
  }

  IconData _getTypeIcon(CustomFieldType type) {
    switch (type) {
      case CustomFieldType.source:
        return Icons.source_outlined;
      case CustomFieldType.project:
        return Icons.business_outlined;
      case CustomFieldType.status:
        return Icons.flag_outlined;
    }
  }

  void _showAddDialog(BuildContext context, WidgetRef ref, CustomFieldType type) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add New ${type.displayName}'),
        content: Form(
          key: formKey,
          child: CustomTextField(
            controller: controller,
            label: '${type.displayName} Name',
            hint: 'Enter ${type.displayName.toLowerCase()} name',
            validator: (value) => Validators.required(value, '${type.displayName} name'),
          ),
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (context, ref, child) {
              return CustomButton(
                text: 'Add',
                isLoading: ref.watch(customFieldsControllerProvider).isLoading,
                backgroundColor: const Color(0xFF3B82F6),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    await ref.read(customFieldsControllerProvider.notifier)
                        .addCustomField(type, controller.text.trim());
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${type.displayName} added successfully'),
                          backgroundColor: const Color(0xFF4CAF50),
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, CustomFieldModel field) {
    final controller = TextEditingController(text: field.name);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit ${field.type.displayName}'),
        content: Form(
          key: formKey,
          child: CustomTextField(
            controller: controller,
            label: '${field.type.displayName} Name',
            hint: 'Enter ${field.type.displayName.toLowerCase()} name',
            validator: (value) => Validators.required(value, '${field.type.displayName} name'),
          ),
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (context, ref, child) {
              return CustomButton(
                text: 'Update',
                isLoading: ref.watch(customFieldsControllerProvider).isLoading,
                backgroundColor: const Color(0xFF3B82F6),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    await ref.read(customFieldsControllerProvider.notifier)
                        .updateCustomField(
                          field.id,
                          field.type,
                          controller.text.trim(),
                        );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${field.type.displayName} updated successfully'),
                          backgroundColor: const Color(0xFF4CAF50),
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
