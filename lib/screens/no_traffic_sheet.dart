import 'package:flutter/material.dart';

import '../../models/followup.dart';
import '../core/theme/theme.dart';

class NoTrafficReasonSheet extends StatelessWidget {
  const NoTrafficReasonSheet({super.key});

  static Future<NoTrafficReason?> show(BuildContext context) {
    return showModalBottomSheet<NoTrafficReason>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const NoTrafficReasonSheet(),
    );
  }

  static const _reasons = [
    (
      reason: NoTrafficReason.rateTooHigh,
      label: 'Rate Too High',
      icon: Icons.price_change_outlined,
    ),
    (
      reason: NoTrafficReason.qualityConcern,
      label: 'Quality Concern',
      icon: Icons.signal_cellular_alt_outlined,
    ),
    (
      reason: NoTrafficReason.customerDisappeared,
      label: 'Customer Disappeared',
      icon: Icons.person_off_outlined,
    ),
    (
      reason: NoTrafficReason.supplierIssue,
      label: 'Supplier Issue',
      icon: Icons.business_outlined,
    ),
    (
      reason: NoTrafficReason.unknown,
      label: 'Unknown',
      icon: Icons.help_outline,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          Text(
            'No Traffic — What Happened?',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Select a reason to log with this request.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          ..._reasons.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Material(
                color: AppColors.bgSurface,
                borderRadius: AppRadius.cardRadius,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(r.reason),
                  borderRadius: AppRadius.cardRadius,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.cardRadius,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(r.icon, color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: AppSpacing.md),
                        Text(r.label, style: AppTextStyles.titleMedium),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
