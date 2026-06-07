import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/routes/routes.dart';
import '../core/theme/theme.dart';
import '../models/promotion.dart';
import '../models/route_request.dart';
import '../providers/promotion_provider.dart';
import '../providers/request_provider.dart';

String _n(Enum e) => e.toString().split('.').last;

class PromotionDetailScreen extends StatelessWidget {
  const PromotionDetailScreen({super.key, required this.promotionId});
  final String promotionId;

  @override
  Widget build(BuildContext context) {
    final promotion = context
        .watch<PromotionProvider>()
        .all
        .where((p) => p.id == promotionId)
        .firstOrNull;

    if (promotion == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Promotion not found.')),
      );
    }

    return _DetailView(promotion: promotion);
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.promotion});
  final Promotion promotion;

  @override
  Widget build(BuildContext context) {
    final priorityStyle = AppStatusStyles.priority[_n(promotion.priority)]!;
    final (statusLabel, statusColor) = _statusStyle(promotion.status);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(promotion.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Status + priority + expiry
          Row(
            children: [
              _Chip(label: statusLabel, color: statusColor),
              const SizedBox(width: AppSpacing.sm),
              Icon(priorityStyle.icon, size: 14, color: priorityStyle.color),
              const SizedBox(width: 4),
              Text(
                priorityStyle.label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: priorityStyle.color,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.schedule,
                size: 13,
                color: promotion.isExpiringSoon
                    ? AppColors.warning
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                promotion.expiryLabel,
                style: AppTextStyles.monoSmall.copyWith(
                  color: promotion.isExpiringSoon
                      ? AppColors.warning
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          if (promotion.qualityDescription != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _Card(
              title: 'Quality',
              children: [
                Text(
                  promotion.qualityDescription!,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // Dates card
          _Card(
            title: 'Validity',
            children: [
              _Row('Start Date', _fmtDate(promotion.startDate)),
              _Row('Expiry Date', _fmtDate(promotion.expiryDate)),
            ],
          ),

          if (promotion.notes != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _Card(
              title: 'Notes',
              children: [
                Text(promotion.notes!, style: AppTextStyles.bodyMedium),
              ],
            ),
          ],

          // Destinations
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(
            label: 'Destinations (${promotion.destinations.length})',
          ),
          const SizedBox(height: AppSpacing.sm),
          ...promotion.destinations.map(
            (d) => _DestinationCard(destination: d),
          ),

          // Linked requests
          const SizedBox(height: AppSpacing.lg),
          _LinkedRequests(promotion: promotion),

          // Status actions
          const SizedBox(height: AppSpacing.xl),
          _StatusActions(promotion: promotion),

          const SizedBox(height: AppSpacing.x4l),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Promotion'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<PromotionProvider>().delete(promotion.id);
    if (context.mounted) context.go(AppRoutes.promotions);
  }

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  (String, Color) _statusStyle(PromotionStatus s) => switch (s) {
    PromotionStatus.active => ('Active', AppColors.success),
    PromotionStatus.draft => ('Draft', AppColors.textSecondary),
    PromotionStatus.paused => ('Paused', AppColors.warning),
    PromotionStatus.expired => ('Expired', AppColors.error),
    PromotionStatus.closed => ('Closed', AppColors.statusClosed),
  };
}

// ── Status actions ────────────────────────────────────────────────────────────

class _StatusActions extends StatelessWidget {
  const _StatusActions({required this.promotion});
  final Promotion promotion;

  static const _transitions = {
    PromotionStatus.draft: [PromotionStatus.active, PromotionStatus.closed],
    PromotionStatus.active: [PromotionStatus.paused, PromotionStatus.closed],
    PromotionStatus.paused: [PromotionStatus.active, PromotionStatus.closed],
    PromotionStatus.expired: [PromotionStatus.closed],
    PromotionStatus.closed: <PromotionStatus>[],
  };

  (String, Color) _style(PromotionStatus s) => switch (s) {
    PromotionStatus.active => ('Set Active', AppColors.success),
    PromotionStatus.paused => ('Pause', AppColors.warning),
    PromotionStatus.closed => ('Close', AppColors.error),
    PromotionStatus.expired => ('Mark Expired', AppColors.error),
    PromotionStatus.draft => ('Revert Draft', AppColors.textSecondary),
  };

  @override
  Widget build(BuildContext context) {
    final next = _transitions[promotion.status] ?? [];
    if (next.isEmpty) {
      return Center(
        child: Text(
          'This promotion is closed.',
          style: AppTextStyles.bodyMedium,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('CHANGE STATUS', style: AppTextStyles.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        ...next.map((s) {
          final (label, color) = _style(s);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              onPressed: () async {
                await context.read<PromotionProvider>().updateStatus(
                  promotion,
                  s,
                );
              },
              child: Text(label),
            ),
          );
        }),
      ],
    );
  }
}

// ── Linked requests ───────────────────────────────────────────────────────────

class _LinkedRequests extends StatelessWidget {
  const _LinkedRequests({required this.promotion});
  final Promotion promotion;

  @override
  Widget build(BuildContext context) {
    // Match requests by country/operator overlap with promotion destinations
    final allRequests = context.watch<RequestProvider>().all;
    final countries = promotion.destinations.map((d) => d.country).toSet();
    final linked = allRequests
        .where((r) => countries.contains(r.country))
        .take(5)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(label: 'Linked Requests'),
        const SizedBox(height: AppSpacing.sm),
        if (linked.isEmpty)
          Text('No matching requests found.', style: AppTextStyles.bodyMedium)
        else
          ...linked.map((r) => _LinkedRequestTile(request: r)),
      ],
    );
  }
}

class _LinkedRequestTile extends StatelessWidget {
  const _LinkedRequestTile({required this.request});
  final RouteRequest request;

  @override
  Widget build(BuildContext context) {
    final statusStyle = AppStatusStyles.requestStatus[_n(request.status)]!;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        title: Text(request.customerName, style: AppTextStyles.titleMedium),
        subtitle: Text(
          '${request.country} · ${request.operator}',
          style: AppTextStyles.bodySmall,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: statusStyle.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            statusStyle.label,
            style: AppTextStyles.labelSmall.copyWith(color: statusStyle.color),
          ),
        ),
      ),
    );
  }
}

// ── Destination card ──────────────────────────────────────────────────────────

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({required this.destination});
  final PromotionDestination destination;

  @override
  Widget build(BuildContext context) {
    final color = destination.isSms ? AppColors.info : AppColors.statusSent;
    final subType = destination.isSms
        ? destination.smsRouteType?.toString().split('.').last.toUpperCase()
        : destination.voiceRouteType?.toString().split('.').last.toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${destination.country}  ·  ${destination.operator}',
                    style: AppTextStyles.titleMedium,
                  ),
                  Text(
                    destination.supplierName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    subType != null
                        ? '${destination.isSms ? "SMS" : "Voice"}  ·  $subType'
                        : (destination.isSms ? 'SMS' : 'Voice'),
                    style: AppTextStyles.bodySmall.copyWith(color: color),
                  ),
                ],
              ),
            ),
            Text(
              '${destination.currency} ${destination.rate.toStringAsFixed(4)}',
              style: AppTextStyles.mono,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(color: color),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: AppTextStyles.labelMedium),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.bodyMedium),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label.toUpperCase(), style: AppTextStyles.labelMedium);
  }
}
