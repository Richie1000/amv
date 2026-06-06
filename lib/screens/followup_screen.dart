import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/followup.dart';
import '../../models/route_request.dart';
import '../../providers/followup_provider.dart';
import '../../providers/request_provider.dart';
import '../core/theme/theme.dart';
import 'quick_action_sheet.dart';

class FollowupsScreen extends StatelessWidget {
  const FollowupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FollowupProvider>(
      builder: (context, provider, _) {
        final hasContent =
            provider.overdue.isNotEmpty ||
            provider.today.isNotEmpty ||
            provider.upcoming.isNotEmpty;

        return Scaffold(
          backgroundColor: AppColors.bgBase,
          appBar: AppBar(
            title: const Text('Follow-ups'),
            actions: [
              if (provider.overdueCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.lg),
                  child: Badge(
                    label: Text('${provider.overdueCount}'),
                    child: const Icon(
                      Icons.warning_amber_outlined,
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
          body: !hasContent
              ? _EmptyState()
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    if (provider.overdue.isNotEmpty) ...[
                      _SectionHeader(
                        label: 'OVERDUE',
                        color: AppColors.error,
                        count: provider.overdue.length,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...provider.overdue.map(
                        (f) => _FollowupCard(followup: f),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    if (provider.today.isNotEmpty) ...[
                      _SectionHeader(
                        label: 'TODAY',
                        color: AppColors.warning,
                        count: provider.today.length,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...provider.today.map((f) => _FollowupCard(followup: f)),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    if (provider.upcoming.isNotEmpty) ...[
                      _SectionHeader(
                        label: 'UPCOMING',
                        color: AppColors.textSecondary,
                        count: provider.upcoming.length,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...provider.upcoming.map(
                        (f) => _FollowupCard(followup: f),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    if (provider.completed.isNotEmpty) ...[
                      _SectionHeader(
                        label: 'COMPLETED',
                        color: AppColors.success,
                        count: provider.completed.length,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...provider.completed.map(
                        (f) => _FollowupCard(followup: f),
                      ),
                    ],
                  ],
                ),
        );
      },
    );
  }
}

// ── Follow-up card ────────────────────────────────────────────────────────────

class _FollowupCard extends StatelessWidget {
  const _FollowupCard({required this.followup});
  final Followup followup;

  @override
  Widget build(BuildContext context) {
    final isCompleted = followup.status == FollowupStatus.completed;
    final isOverdue = followup.status == FollowupStatus.overdue;
    final isStability = followup.type == FollowupType.trafficStability;

    final statusColor = isOverdue
        ? AppColors.error
        : isCompleted
        ? AppColors.success
        : AppColors.textSecondary;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isStability
                        ? AppColors.statusSent.withOpacity(0.12)
                        : AppColors.primaryMuted,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isStability
                            ? Icons.monitor_heart_outlined
                            : Icons.person_outline,
                        size: 12,
                        color: isStability
                            ? AppColors.statusSent
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isStability ? 'Stability Check' : 'Customer Check',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isStability
                              ? AppColors.statusSent
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Overdue / completed chip
                if (isOverdue || isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      isOverdue ? 'Overdue' : 'Done',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: statusColor,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(followup.customerName, style: AppTextStyles.titleMedium),

            const SizedBox(height: AppSpacing.xs),

            Row(
              children: [
                Icon(Icons.schedule, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(followup.scheduledAt),
                  style: AppTextStyles.monoSmall,
                ),
                if (followup.lastAction != null) ...[
                  const SizedBox(width: AppSpacing.md),
                  Icon(
                    Icons.check_circle_outline,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _actionLabel(followup.lastAction!),
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ],
            ),

            // Quick action button — only for non-completed
            if (!isCompleted) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.bolt, size: 16),
                  label: const Text('Take Action'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isOverdue
                        ? AppColors.error
                        : AppColors.primary,
                    side: BorderSide(
                      color: isOverdue
                          ? AppColors.error.withOpacity(0.5)
                          : AppColors.primary.withOpacity(0.5),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  onPressed: () => _openQuickActions(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openQuickActions(BuildContext context) async {
    final request = context
        .read<RequestProvider>()
        .all
        .where((r) => r.id == followup.requestId)
        .firstOrNull;

    if (request == null) return;

    await QuickActionsSheet.show(context, followup: followup, request: request);
  }

  String _formatDateTime(DateTime dt) {
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    final date =
        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
    return '$date  $time';
  }

  String _actionLabel(FollowupAction a) => switch (a) {
    FollowupAction.trafficStarted => 'Traffic Started',
    FollowupAction.customerTesting => 'Testing',
    FollowupAction.noFeedbackYet => 'No Feedback',
    FollowupAction.customerRejected => 'Rejected',
    FollowupAction.rescheduled => 'Rescheduled',
  };
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.color,
    required this.count,
  });

  final String label;
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.labelMedium.copyWith(color: color)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.labelSmall.copyWith(color: color),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider()),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none, size: 48, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.lg),
          Text('No follow-ups', style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Follow-ups are created automatically\nwhen a request is sent to a customer.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
