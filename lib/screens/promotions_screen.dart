import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/routes/routes.dart';
import '../core/theme/theme.dart';
import '../models/promotion.dart';
import '../providers/promotion_provider.dart';

String _n(Enum e) => e.toString().split('.').last;

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: const Text('Promotions'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Draft'),
            Tab(text: 'Expiring'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: Consumer<PromotionProvider>(
        builder: (context, provider, _) {
          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Failed to load promotions',
                      style: AppTextStyles.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      provider.error!,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return TabBarView(
            controller: _tabs,
            children: [
              _PromotionList(promotions: provider.active),
              _PromotionList(promotions: provider.draft),
              _PromotionList(promotions: provider.expiring),
              _PromotionList(promotions: provider.all),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.createPromotion),
        icon: const Icon(Icons.add),
        label: const Text('New Promotion'),
      ),
    );
  }
}

// ── Promotion list ────────────────────────────────────────────────────────────

class _PromotionList extends StatelessWidget {
  const _PromotionList({required this.promotions});
  final List<Promotion> promotions;

  @override
  Widget build(BuildContext context) {
    if (promotions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.campaign_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.lg),
            Text('No promotions here', style: AppTextStyles.headlineSmall),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: promotions.length,
      itemBuilder: (_, i) => _PromotionCard(promotion: promotions[i]),
    );
  }
}

// ── Promotion card ────────────────────────────────────────────────────────────

class _PromotionCard extends StatelessWidget {
  const _PromotionCard({required this.promotion});
  final Promotion promotion;

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusStyle(promotion.status);
    final priorityStyle = AppStatusStyles.priority[_n(promotion.priority)]!;
    final isExpiringSoon = promotion.isExpiringSoon;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () => context.go('${AppRoutes.promotions}/${promotion.id}'),
        borderRadius: AppRadius.cardRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      promotion.title,
                      style: AppTextStyles.headlineSmall,
                    ),
                  ),
                  _StatusChip(label: statusStyle.$1, color: statusStyle.$2),
                ],
              ),

              const SizedBox(height: AppSpacing.xs),

              // Suppliers (unique across destinations)
              Row(
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    promotion.destinations
                        .map((d) => d.supplierName)
                        .toSet()
                        .join(', '),
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Destinations chips
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children:
                    promotion.destinations.take(3).map((d) {
                      final color = d.isSms
                          ? AppColors.info
                          : AppColors.statusSent;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Text(
                          '${d.country} · ${d.operator}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: color,
                          ),
                        ),
                      );
                    }).toList()..addAll(
                      promotion.destinations.length > 3
                          ? [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.bgSubtle,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.full,
                                  ),
                                ),
                                child: Text(
                                  '+${promotion.destinations.length - 3} more',
                                  style: AppTextStyles.labelSmall,
                                ),
                              ),
                            ]
                          : [],
                    ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Bottom row — priority + expiry
              Row(
                children: [
                  Icon(
                    priorityStyle.icon,
                    size: 14,
                    color: priorityStyle.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    priorityStyle.label,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: priorityStyle.color,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.schedule,
                    size: 13,
                    color: isExpiringSoon
                        ? AppColors.warning
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    promotion.expiryLabel,
                    style: AppTextStyles.monoSmall.copyWith(
                      color: isExpiringSoon
                          ? AppColors.warning
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  (String, Color) _statusStyle(PromotionStatus s) => switch (s) {
    PromotionStatus.active => ('Active', AppColors.success),
    PromotionStatus.draft => ('Draft', AppColors.textSecondary),
    PromotionStatus.paused => ('Paused', AppColors.warning),
    PromotionStatus.expired => ('Expired', AppColors.error),
    PromotionStatus.closed => ('Closed', AppColors.statusClosed),
  };
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}
