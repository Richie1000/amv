import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/routes/routes.dart';
import '../core/theme/theme.dart';
import '../models/followup.dart';
import '../models/route_request.dart';
import '../providers/followup_provider.dart';
import '../providers/request_provider.dart';

String _n(Enum e) => e.toString().split('.').last;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<RequestProvider>();
    final followups = context.watch<FollowupProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('${AppRoutes.requests}/new'),
            tooltip: 'New Request',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // ── Stats row ────────────────────────────────────────────────────
          _StatsRow(requests: requests, followups: followups),

          const SizedBox(height: AppSpacing.xl),

          // ── Attention needed ─────────────────────────────────────────────
          if (followups.overdue.isNotEmpty) ...[
            _SectionHeader(
              label: 'Attention Needed',
              icon: Icons.warning_amber_rounded,
              color: AppColors.error,
              count: followups.overdue.length,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...followups.overdue.map((f) => _OverdueFollowupCard(followup: f)),
            const SizedBox(height: AppSpacing.xl),
          ],

          // ── Active requests ───────────────────────────────────────────────
          _SectionHeader(
            label: 'Active Requests',
            icon: Icons.swap_horiz_outlined,
            color: AppColors.primary,
            count: _activeCount(requests),
          ),
          const SizedBox(height: AppSpacing.sm),

          if (_active(requests).isEmpty)
            _EmptySection(
              message: 'No active requests.',
              onTap: () => context.go('${AppRoutes.requests}/new'),
              buttonLabel: 'Create one',
            )
          else ...[
            ..._active(requests).take(5).map((r) => _RequestTile(request: r)),
            if (_activeCount(requests) > 5)
              _ViewAllButton(
                label: 'View all ${_activeCount(requests)} requests',
                onTap: () => context.go(AppRoutes.requests),
              ),
          ],

          const SizedBox(height: AppSpacing.xl),

          // ── Today's follow-ups ────────────────────────────────────────────
          _SectionHeader(
            label: 'Due Today',
            icon: Icons.notifications_outlined,
            color: AppColors.warning,
            count: followups.today.length,
          ),
          const SizedBox(height: AppSpacing.sm),

          if (followups.today.isEmpty)
            const _EmptySection(message: 'No follow-ups due today.')
          else
            ...followups.today.map((f) => _FollowupTile(followup: f)),

          const SizedBox(height: AppSpacing.x4l),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('${AppRoutes.requests}/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
    );
  }

  List<RouteRequest> _active(RequestProvider p) => p.all
      .where(
        (r) =>
            r.status != RequestStatus.closed &&
            r.status != RequestStatus.noTraffic,
      )
      .toList();

  int _activeCount(RequestProvider p) => _active(p).length;
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.requests, required this.followups});

  final RequestProvider requests;
  final FollowupProvider followups;

  @override
  Widget build(BuildContext context) {
    final pending = requests.all
        .where((r) => r.status == RequestStatus.pending)
        .length;
    final searching = requests.all
        .where((r) => r.status == RequestStatus.searchingSupplier)
        .length;
    final confirmed = requests.all
        .where((r) => r.status == RequestStatus.trafficConfirmed)
        .length;
    final overdue = followups.overdueCount;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 2.2,
      children: [
        _StatCard(
          label: 'Pending',
          value: '$pending',
          color: AppColors.statusPending,
          icon: Icons.schedule_outlined,
        ),
        _StatCard(
          label: 'Searching',
          value: '$searching',
          color: AppColors.statusSearching,
          icon: Icons.search_outlined,
        ),
        _StatCard(
          label: 'Confirmed',
          value: '$confirmed',
          color: AppColors.statusConfirmed,
          icon: Icons.traffic_outlined,
        ),
        _StatCard(
          label: 'Overdue',
          value: '$overdue',
          color: overdue > 0 ? AppColors.error : AppColors.textMuted,
          icon: Icons.warning_amber_outlined,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: AppTextStyles.displayMedium.copyWith(
                  color: color,
                  fontSize: 22,
                ),
              ),
              Text(label, style: AppTextStyles.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Overdue followup card ─────────────────────────────────────────────────────

class _OverdueFollowupCard extends StatelessWidget {
  const _OverdueFollowupCard({required this.followup});
  final Followup followup;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
        side: BorderSide(color: AppColors.error.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 18,
          ),
        ),
        title: Text(followup.customerName, style: AppTextStyles.titleMedium),
        subtitle: Text(
          'Was due ${_timeAgo(followup.scheduledAt)}',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
        ),
        trailing: TextButton(
          onPressed: () => context.go(AppRoutes.followups),
          child: const Text('Act'),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}

// ── Request tile ──────────────────────────────────────────────────────────────

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.request});
  final RouteRequest request;

  @override
  Widget build(BuildContext context) {
    final statusStyle = AppStatusStyles.requestStatus[_n(request.status)]!;
    final isSms = request.isSms;
    final typeColor = isSms ? AppColors.info : AppColors.statusSent;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => context.go('${AppRoutes.requests}/${request.id}'),
        borderRadius: AppRadius.cardRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Route type dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: typeColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.customerName,
                      style: AppTextStyles.titleMedium,
                    ),
                    Text(
                      '${request.country}  ·  ${request.operator}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: statusStyle.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  statusStyle.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: statusStyle.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Followup tile ─────────────────────────────────────────────────────────────

class _FollowupTile extends StatelessWidget {
  const _FollowupTile({required this.followup});
  final Followup followup;

  @override
  Widget build(BuildContext context) {
    final isStability = followup.type == FollowupType.trafficStability;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(
          isStability ? Icons.monitor_heart_outlined : Icons.person_outline,
          color: AppColors.warning,
        ),
        title: Text(followup.customerName, style: AppTextStyles.titleMedium),
        subtitle: Text(
          isStability ? 'Traffic stability check' : 'Customer follow-up',
          style: AppTextStyles.bodySmall,
        ),
        trailing: Text(
          _formatTime(followup.scheduledAt),
          style: AppTextStyles.monoSmall,
        ),
        onTap: () => context.go(AppRoutes.followups),
      ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.icon,
    required this.color,
    required this.count,
  });

  final String label;
  final IconData icon;
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: AppTextStyles.titleMedium.copyWith(color: color)),
        const SizedBox(width: AppSpacing.sm),
        if (count > 0)
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
        const Spacer(),
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _ViewAllButton extends StatelessWidget {
  const _ViewAllButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: onTap, child: Text(label));
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.message, this.onTap, this.buttonLabel});

  final String message;
  final VoidCallback? onTap;
  final String? buttonLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Text(message, style: AppTextStyles.bodyMedium),
          if (onTap != null && buttonLabel != null) ...[
            const SizedBox(width: AppSpacing.sm),
            TextButton(onPressed: onTap, child: Text(buttonLabel!)),
          ],
        ],
      ),
    );
  }
}
