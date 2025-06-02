import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models.dart';
import 'utils.dart';
import 'services.dart';
import 'providers.dart';

// Custom Button Widget
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(0xFFE60023),
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
          width: 20.w,
          height: 20.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: textColor ?? Colors.white,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18.w),
              SizedBox(width: 8.w),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Text Field Widget
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool enabled;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          enabled: enabled,
          onTap: onTap,
          style: TextStyle(
            fontSize: 16.sp,
            color: const Color(0xFF333333),
          ),
          decoration: InputDecoration(
            hintText: hint ?? 'Enter $label',
            hintStyle: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFF999999),
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: const Color(0xFF666666), size: 20.w)
                : null,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE60023)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF5F5F5),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
        ),
      ],
    );
  }
}

// Custom Dropdown Widget
class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) getDisplayText;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.getDisplayText,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<T>(
          value: value,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE60023)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                getDisplayText(item),
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF333333),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Lead Card Widget
class LeadCard extends ConsumerWidget {
  final LeadModel lead;
  final bool showUser;

  const LeadCard({
    super.key,
    required this.lead,
    this.showUser = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: InkWell(
        onTap: () => context.push('/lead/${lead.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lead.name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        if (showUser) ...[
                          SizedBox(height: 4.h),
                          Text(
                            'ID: ${lead.userId.substring(0, 8)}...',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF999999),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  LeadStatusChip(status: lead.status),
                ],
              ),

              SizedBox(height: 12.h),

              // Contact info
              Row(
                children: [
                  Icon(Icons.phone_outlined, size: 16.w, color: const Color(0xFF666666)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      AppHelpers.formatPhoneNumber(lead.phone),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.call, size: 20.w, color: const Color(0xFFE60023)),
                    onPressed: () => CallService.makeCall(lead.phone),
                    constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.w),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),

              if (lead.email.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.email_outlined, size: 16.w, color: const Color(0xFF666666)),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        lead.email,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 12.h),

              // Source and Project
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.source_outlined, size: 16.w, color: const Color(0xFF666666)),
                        SizedBox(width: 6.w),
                        Text(
                          lead.source,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (lead.project.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.business_outlined, size: 16.w, color: const Color(0xFF666666)),
                        SizedBox(width: 6.w),
                        Text(
                          lead.project,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Follow-up reminder
              if (lead.followUp != null) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: lead.followUp!.isBefore(DateTime.now())
                        ? const Color(0xFFFFEBEE)
                        : const Color(0xFFE8F5E8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14.w,
                        color: lead.followUp!.isBefore(DateTime.now())
                            ? const Color(0xFFE53935)
                            : const Color(0xFF4CAF50),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Follow up: ${AppHelpers.formatDateTime(lead.followUp!)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: lead.followUp!.isBefore(DateTime.now())
                              ? const Color(0xFFE53935)
                              : const Color(0xFF4CAF50),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 8.h),

              // Last updated
              Text(
                'Updated ${AppHelpers.timeAgo(lead.updatedAt)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF999999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Lead Status Chip Widget
class LeadStatusChip extends StatelessWidget {
  final LeadStatus status;

  const LeadStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(AppHelpers.getStatusColor(status.displayName).substring(1), radix: 16) + 0xFF000000);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Activity Log Tile Widget
class ActivityLogTile extends StatelessWidget {
  final ActivityLogModel log;

  const ActivityLogTile({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getActivityIcon(),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  log.description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
              Text(
                AppHelpers.timeAgo(log.timestamp),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF999999),
                ),
              ),
            ],
          ),

          if (log.details != null) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: _buildDetails(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _getActivityIcon() {
    IconData icon;
    Color color;

    switch (log.actionType) {
      case ActivityType.created:
        icon = Icons.add_circle_outline;
        color = const Color(0xFF4CAF50);
        break;
      case ActivityType.edit:
        icon = Icons.edit_outlined;
        color = const Color(0xFF2196F3);
        break;
      case ActivityType.status_change:
        icon = Icons.swap_horiz;
        color = const Color(0xFF9C27B0);
        break;
      case ActivityType.call:
        icon = Icons.call_outlined;
        color = const Color(0xFFE60023);
        break;
      case ActivityType.reminder:
        icon = Icons.schedule;
        color = const Color(0xFFFF9800);
        break;
      case ActivityType.note:
        icon = Icons.note_outlined;
        color = const Color(0xFF607D8B);
        break;
    }

    return Icon(icon, size: 18.w, color: color);
  }

  Widget _buildDetails() {
    if (log.details == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: log.details!.entries.map((entry) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Text(
            '${AppHelpers.capitalizeFirst(entry.key)}: ${entry.value}',
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF666666),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Empty State Widget
class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64.w,
              color: const Color(0xFFCCCCCC),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF999999),
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              SizedBox(height: 24.h),
              SizedBox(
                width: 200.w,
                child: CustomButton(
                  text: buttonText!,
                  onPressed: onButtonPressed,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Loading Widget
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFFE60023),
          ),
          if (message != null) ...[
            SizedBox(height: 16.h),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF666666),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Custom Error Widget
class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.w,
              color: const Color(0xFFE53935),
            ),
            SizedBox(height: 16.h),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 24.h),
              SizedBox(
                width: 200.w,
                child: CustomButton(
                  text: 'Try Again',
                  onPressed: onRetry,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Custom Search Bar Widget
class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint = 'Search leads...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 16.sp,
          color: const Color(0xFF333333),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 16.sp,
            color: const Color(0xFF999999),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: const Color(0xFF666666),
            size: 20.w,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
            icon: Icon(
              Icons.clear,
              color: const Color(0xFF666666),
              size: 20.w,
            ),
            onPressed: () {
              controller.clear();
              onChanged('');
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Color(0xFFE60023)),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        ),
      ),
    );
  }
}

// Stats Card Widget
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24.w,
                    ),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16.w,
                      color: const Color(0xFF999999),
                    ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
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

// Call Outcome Dialog
class CallOutcomeDialog extends StatefulWidget {
  final String leadId;
  final String leadName;

  const CallOutcomeDialog({
    super.key,
    required this.leadId,
    required this.leadName,
  });

  @override
  State<CallOutcomeDialog> createState() => _CallOutcomeDialogState();
}

class _CallOutcomeDialogState extends State<CallOutcomeDialog> {
  String _selectedOutcome = AppConstants.callOutcomes.first;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Call with ${widget.leadName}',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomDropdown<String>(
            label: 'Call Outcome',
            value: _selectedOutcome,
            items: AppConstants.callOutcomes,
            getDisplayText: (outcome) => outcome,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedOutcome = value;
                });
              }
            },
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            controller: _notesController,
            label: 'Notes',
            hint: 'Add call notes...',
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        Consumer(
          builder: (context, ref, child) {
            return TextButton(
              onPressed: () async {
                await ref.read(leadControllerProvider.notifier).logCallActivity(
                  leadId: widget.leadId,
                  outcome: _selectedOutcome,
                  notes: _notesController.text,
                );
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Call logged successfully'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            );
          },
        ),
      ],
    );
  }
}