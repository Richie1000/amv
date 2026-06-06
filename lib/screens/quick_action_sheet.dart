import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/followup.dart';
import '../../models/route_request.dart';
import '../../providers/followup_provider.dart';
import '../../providers/request_provider.dart';
import '../core/theme/theme.dart';
import 'no_traffic_sheet.dart';

class QuickActionsSheet extends StatelessWidget {
  const QuickActionsSheet({
    super.key,
    required this.followup,
    required this.request,
  });

  final Followup followup;
  final RouteRequest request;

  static Future<void> show(
    BuildContext context, {
    required Followup followup,
    required RouteRequest request,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false, // non-dismissible
      enableDrag: false,
      isScrollControlled: true,
      builder: (_) => QuickActionsSheet(followup: followup, request: request),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStability = followup.type == FollowupType.trafficStability;

    return PopScope(
      canPop: false, // back button blocked
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.x3l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isStability ? 'Traffic Stability Check' : 'Follow-up',
                        style: AppTextStyles.headlineSmall,
                      ),
                      Text(
                        followup.customerName,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),
            Text('WHAT\'S THE UPDATE?', style: AppTextStyles.labelMedium),
            const SizedBox(height: AppSpacing.md),

            // Actions
            if (!isStability) ...[
              _ActionTile(
                icon: Icons.trending_up,
                color: AppColors.success,
                label: 'Traffic Started',
                onTap: () => _onAction(context, FollowupAction.trafficStarted),
              ),
              _ActionTile(
                icon: Icons.science_outlined,
                color: AppColors.info,
                label: 'Customer Testing',
                onTap: () => _onAction(context, FollowupAction.customerTesting),
              ),
              _ActionTile(
                icon: Icons.hourglass_empty,
                color: AppColors.warning,
                label: 'No Feedback Yet',
                onTap: () => _onAction(context, FollowupAction.noFeedbackYet),
              ),
              _ActionTile(
                icon: Icons.cancel_outlined,
                color: AppColors.error,
                label: 'Customer Rejected',
                onTap: () => _onRejected(context),
              ),
            ] else ...[
              _ActionTile(
                icon: Icons.signal_cellular_4_bar,
                color: AppColors.success,
                label: 'Traffic Stable',
                onTap: () => _onAction(context, FollowupAction.trafficStarted),
              ),
              _ActionTile(
                icon: Icons.trending_down,
                color: AppColors.warning,
                label: 'Traffic Weak',
                onTap: () => _onAction(context, FollowupAction.customerTesting),
              ),
              _ActionTile(
                icon: Icons.signal_cellular_off_outlined,
                color: AppColors.error,
                label: 'Traffic Dropped',
                onTap: () => _onRejected(context),
              ),
            ],

            _ActionTile(
              icon: Icons.schedule,
              color: AppColors.textSecondary,
              label: 'Reschedule Follow-up',
              onTap: () => _onReschedule(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onAction(BuildContext context, FollowupAction action) async {
    final fp = context.read<FollowupProvider>();
    final rp = context.read<RequestProvider>();

    await fp.handleAction(followup: followup, action: action, request: request);

    // Update request status if traffic started
    if (action == FollowupAction.trafficStarted) {
      await rp.updateStatus(request, RequestStatus.trafficConfirmed);
    }

    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _onRejected(BuildContext context) async {
    final reason = await NoTrafficReasonSheet.show(context);
    if (reason == null || !context.mounted) return;

    final fp = context.read<FollowupProvider>();
    final rp = context.read<RequestProvider>();

    await fp.handleAction(
      followup: followup,
      action: FollowupAction.customerRejected,
      request: request,
      noTrafficReason: reason,
    );

    await rp.updateStatus(request, RequestStatus.noTraffic);

    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _onReschedule(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (time == null || !context.mounted) return;

    final newTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    await context.read<FollowupProvider>().reschedule(followup, newTime);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.bgSurface,
        borderRadius: AppRadius.cardRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardRadius,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: AppRadius.cardRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: AppSpacing.md),
                Text(label, style: AppTextStyles.titleMedium),
                const Spacer(),
                Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
