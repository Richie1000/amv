import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/route_request.dart';
import '../../providers/history_provider.dart';
import '../core/theme/theme.dart';

String _n(Enum e) => e.toString().split('.').last;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final provider = context.read<HistoryProvider>();
    final now = DateTime.now();

    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: provider.dateFrom != null && provider.dateTo != null
          ? DateTimeRange(start: provider.dateFrom!, end: provider.dateTo!)
          : null,
      builder: (context, child) =>
          Theme(data: Theme.of(context), child: child!),
    );

    if (range != null) {
      provider.filterByDateRange(range.start, range.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: const Text('Rate History'),
        actions: [
          Consumer<HistoryProvider>(
            builder: (_, provider, __) => provider.hasActiveFilters
                ? TextButton(
                    onPressed: () {
                      _searchCtrl.clear();
                      provider.clearFilters();
                    },
                    child: const Text('Clear'),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(controller: _searchCtrl),
          _FilterRow(onDateTap: () => _pickDateRange(context)),
          const Divider(height: 1),
          Expanded(
            child: Consumer<HistoryProvider>(
              builder: (context, provider, _) {
                // Error state — usually missing Firestore index
                if (provider.error != null) {
                  return _ErrorState(message: provider.error!);
                }

                if (provider.results.isEmpty) {
                  return _EmptyState(hasFilters: provider.hasActiveFilters);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: provider.results.length,
                  itemBuilder: (_, i) =>
                      _RateCard(request: provider.results[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: TextField(
        controller: controller,
        onChanged: context.read<HistoryProvider>().search,
        decoration: InputDecoration(
          hintText: 'Search country, operator, supplier...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    context.read<HistoryProvider>().search('');
                  },
                )
              : null,
        ),
      ),
    );
  }
}

// ── Filter chips row ──────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.onDateTap});
  final VoidCallback onDateTap;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          // SMS chip
          _FilterChip(
            label: 'SMS',
            selected: provider.routeType == RouteType.sms,
            color: AppColors.info,
            onTap: () => provider.filterByRouteType(
              provider.routeType == RouteType.sms ? null : RouteType.sms,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Voice chip
          _FilterChip(
            label: 'Voice',
            selected: provider.routeType == RouteType.voice,
            color: AppColors.statusSent,
            onTap: () => provider.filterByRouteType(
              provider.routeType == RouteType.voice ? null : RouteType.voice,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Date range chip
          _FilterChip(
            label: provider.dateFrom != null && provider.dateTo != null
                ? '${_fmt(provider.dateFrom!)} – ${_fmt(provider.dateTo!)}'
                : 'Date Range',
            selected: provider.dateFrom != null,
            color: AppColors.primary,
            icon: Icons.date_range_outlined,
            onTap: onDateTap,
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : AppColors.bgSubtle,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected ? color : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: selected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Rate card ─────────────────────────────────────────────────────────────────

class _RateCard extends StatelessWidget {
  const _RateCard({required this.request});
  final RouteRequest request;

  @override
  Widget build(BuildContext context) {
    final isSms = request.isSms;
    final currency = isSms ? 'EUR' : 'USD';
    final color = isSms ? AppColors.info : AppColors.statusSent;

    final subType = isSms
        ? (request.smsRouteType != null
              ? _n(request.smsRouteType!).toUpperCase()
              : null)
        : (request.voiceRouteType != null
              ? _n(request.voiceRouteType!).toUpperCase()
              : null);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.customerName,
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${request.country}  ·  ${request.operator}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
                // Route type badge
                Container(
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
                    subType != null
                        ? '${isSms ? 'SMS' : 'Voice'}  ·  $subType'
                        : (isSms ? 'SMS' : 'Voice'),
                    style: AppTextStyles.labelSmall.copyWith(color: color),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),

            // Rates row
            Row(
              children: [
                _RateCell(
                  label: 'Target',
                  value: request.targetRate,
                  currency: currency,
                  color: AppColors.textSecondary,
                ),
                _VerticalDivider(),
                _RateCell(
                  label: 'Supplier',
                  value: request.supplierRate,
                  currency: currency,
                  color: AppColors.info,
                ),
                _VerticalDivider(),
                _RateCell(
                  label: 'Selling',
                  value: request.sellingRate,
                  currency: currency,
                  color: AppColors.success,
                ),
              ],
            ),

            // Supplier name + date
            if (request.supplierName != null || true) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  if (request.supplierName != null) ...[
                    Icon(
                      Icons.business_outlined,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(request.supplierName!, style: AppTextStyles.bodySmall),
                    const Spacer(),
                  ] else
                    const Spacer(),
                  Text(
                    _formatDate(request.updatedAt),
                    style: AppTextStyles.monoSmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';
}

class _RateCell extends StatelessWidget {
  const _RateCell({
    required this.label,
    required this.value,
    required this.currency,
    required this.color,
  });

  final String label;
  final double? value;
  final String currency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: AppTextStyles.labelSmall),
          const SizedBox(height: 4),
          Text(
            value != null ? value!.toStringAsFixed(4) : '—',
            style: AppTextStyles.mono.copyWith(color: color),
          ),
          Text(currency, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.border,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.lg),
            Text('Failed to load history', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message.contains('index')
                  ? 'Missing Firestore index.\nGo to Firebase Console → Firestore → Indexes and create:\n\nCollection: route_requests\nstatus (ASC) + updatedAt (DESC)'
                  : message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilters});
  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 48, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.lg),
          Text(
            hasFilters ? 'No results found' : 'No history yet',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hasFilters
                ? 'Try adjusting your filters.'
                : 'Closed requests will appear here\nwith their full rate history.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
