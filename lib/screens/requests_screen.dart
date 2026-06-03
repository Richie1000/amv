import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/route_request.dart';
import '../../providers/request_provider.dart';
import '../core/routes/routes.dart';
import '../core/theme/theme.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: const Text('Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('${AppRoutes.requests}/new'),
            tooltip: 'New Request',
          ),
        ],
      ),
      body: Consumer<RequestProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.all.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.all.isEmpty) {
            return _EmptyState(
              onAdd: () => context.go('${AppRoutes.requests}/new'),
            );
          }

          final grouped = provider.groupedByStatus;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              for (final entry in grouped.entries) ...[
                _StatusHeader(status: entry.key, count: entry.value.length),
                const SizedBox(height: AppSpacing.sm),
                ...entry.value.map((r) => _RequestCard(request: r)),
                const SizedBox(height: AppSpacing.lg),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('${AppRoutes.requests}/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
    );
  }
}

// ── Status section header ─────────────────────────────────────────────────────

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.status, required this.count});

  final RequestStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    final style =
        AppStatusStyles.requestStatus[status.toString().split(".").last]!;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: style.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          style.label.toUpperCase(),
          style: AppTextStyles.labelMedium.copyWith(color: style.color),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: style.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.labelSmall.copyWith(color: style.color),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider()),
      ],
    );
  }
}

// ── Request card ──────────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final RouteRequest request;

  @override
  Widget build(BuildContext context) {
    final statusStyle = AppStatusStyles
        .requestStatus[request.status.toString().split(".").last]!;
    final priorityStyle =
        AppStatusStyles.priority[request.priority.toString().split(".").last]!;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => context.go('${AppRoutes.requests}/${request.id}'),
        borderRadius: AppRadius.cardRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row — customer + priority
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.customerName,
                      style: AppTextStyles.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _PriorityBadge(style: priorityStyle),
                ],
              ),

              const SizedBox(height: 6),

              // Country · Operator
              Text(
                '${request.country}  ·  ${request.operator}',
                style: AppTextStyles.bodyMedium,
              ),

              const SizedBox(height: 10),

              // Bottom row — route type chip + status + date
              Row(
                children: [
                  _RouteTypeChip(request: request),
                  const SizedBox(width: 8),
                  Icon(statusStyle.icon, size: 14, color: statusStyle.color),
                  const SizedBox(width: 4),
                  Text(
                    statusStyle.label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: statusStyle.color,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(request.createdAt),
                    style: AppTextStyles.monoSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

// ── Route type chip ───────────────────────────────────────────────────────────

class _RouteTypeChip extends StatelessWidget {
  const _RouteTypeChip({required this.request});
  final RouteRequest request;

  @override
  Widget build(BuildContext context) {
    final isSms = request.isSms;
    final label = isSms ? 'SMS' : 'Voice';
    final sub = isSms
        ? (request.smsRouteType?.toString().split(".").last.toUpperCase() ?? '')
        : (request.voiceRouteType?.toString().split(".").last.toUpperCase() ??
              '');
    final color = isSms ? AppColors.info : AppColors.statusSent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        sub.isNotEmpty ? '$label · $sub' : label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}

// ── Priority badge ────────────────────────────────────────────────────────────

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.style});
  final dynamic style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(style.icon, size: 14, color: style.color),
        const SizedBox(width: 3),
        Text(
          style.label,
          style: AppTextStyles.labelSmall.copyWith(color: style.color),
        ),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.swap_horiz, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('No requests yet', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Create your first route request.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('New Request'),
          ),
        ],
      ),
    );
  }
}
