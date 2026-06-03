import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/route_request.dart';
import '../../providers/request_provider.dart';
import '../core/theme/theme.dart';

// Helper — works on all Dart versions
String _n(Enum e) => e.toString().split('.').last;

class RequestDetailScreen extends StatelessWidget {
  const RequestDetailScreen({super.key, required this.requestId});
  final String requestId;

  @override
  Widget build(BuildContext context) {
    final request = context
        .watch<RequestProvider>()
        .all
        .where((r) => r.id == requestId)
        .firstOrNull;

    if (request == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Request not found.')),
      );
    }

    return _DetailView(request: request);
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.request});
  final RouteRequest request;

  @override
  Widget build(BuildContext context) {
    final statusStyle = AppStatusStyles.requestStatus[_n(request.status)]!;
    final priorityStyle = AppStatusStyles.priority[_n(request.priority)]!;
    final currency = request.isSms ? 'EUR' : 'USD';

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(request.customerName),
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
          // Status + Priority row
          Row(
            children: [
              _StatusChip(style: statusStyle),
              const SizedBox(width: AppSpacing.sm),
              Icon(priorityStyle.icon, size: 14, color: priorityStyle.color),
              const SizedBox(width: 4),
              Text(
                priorityStyle.label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: priorityStyle.color,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Main info card
          _Card(
            children: [
              _Row('Customer', request.customerName),
              _Row('Account Manager', request.accountManager),
              _Row('Country', request.country),
              _Row('Operator', request.operator),
              _Row('Route Type', request.isSms ? 'SMS' : 'Voice'),
              if (request.isSms && request.smsRouteType != null)
                _Row('SMS Type', _smsLabel(request.smsRouteType!)),
              if (request.isVoice && request.voiceRouteType != null)
                _Row('Voice Type', _voiceLabel(request.voiceRouteType!)),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Rates card
          _Card(
            title: 'Rates ($currency)',
            children: [
              _Row(
                'Target Rate',
                request.targetRate != null
                    ? '$currency ${request.targetRate!.toStringAsFixed(4)}'
                    : '—',
              ),
              _Row(
                'Actual Rate',
                request.actualRate != null
                    ? '$currency ${request.actualRate!.toStringAsFixed(4)}'
                    : '—',
              ),
            ],
          ),

          if (request.notes != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _Card(
              title: 'Notes',
              children: [Text(request.notes!, style: AppTextStyles.bodyMedium)],
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          _Card(
            children: [
              _Row('Created', _formatDate(request.createdAt)),
              _Row('Updated', _formatDate(request.updatedAt)),
            ],
          ),

          const SizedBox(height: AppSpacing.x3l),

          _StatusActions(request: request),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Request'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final success = await context.read<RequestProvider>().delete(request.id);
    if (!context.mounted) return;

    if (success) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete request.')),
      );
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _smsLabel(SmsRouteType v) => switch (v) {
    SmsRouteType.direct => 'Direct',
    SmsRouteType.hq => 'HQ',
    SmsRouteType.localBypass => 'Local Bypass',
    SmsRouteType.sim => 'SIM',
    SmsRouteType.casino => 'Casino',
    SmsRouteType.spam => 'Spam',
    SmsRouteType.local => 'Local',
  };

  String _voiceLabel(VoiceRouteType v) => switch (v) {
    VoiceRouteType.cli => 'CLI',
    VoiceRouteType.nonCli => 'Non-CLI',
    VoiceRouteType.cc => 'CC',
    VoiceRouteType.tdm => 'TDM',
  };
}

// ── Status actions ────────────────────────────────────────────────────────────

class _StatusActions extends StatelessWidget {
  const _StatusActions({required this.request});
  final RouteRequest request;

  static const _transitions = {
    RequestStatus.pending: [
      RequestStatus.searchingSupplier,
      RequestStatus.closed,
    ],
    RequestStatus.searchingSupplier: [
      RequestStatus.supplierFound,
      RequestStatus.closed,
    ],
    RequestStatus.supplierFound: [
      RequestStatus.sentToCustomer,
      RequestStatus.closed,
    ],
    RequestStatus.sentToCustomer: [
      RequestStatus.trafficConfirmed,
      RequestStatus.noTraffic,
    ],
    RequestStatus.trafficConfirmed: [RequestStatus.closed],
    RequestStatus.noTraffic: [
      RequestStatus.searchingSupplier,
      RequestStatus.closed,
    ],
    RequestStatus.closed: <RequestStatus>[],
  };

  @override
  Widget build(BuildContext context) {
    final next = _transitions[request.status] ?? [];

    if (next.isEmpty) {
      return Center(
        child: Text('This request is closed.', style: AppTextStyles.bodyMedium),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('MOVE TO', style: AppTextStyles.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        ...next.map((status) {
          final style = AppStatusStyles.requestStatus[_n(status)]!;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: style.color,
                side: BorderSide(color: style.color.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              icon: Icon(style.icon, size: 18),
              label: Text(style.label),
              onPressed: () => _onTap(context, status),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _onTap(BuildContext context, RequestStatus status) async {
    // Traffic Confirmed requires actualRate
    if (status == RequestStatus.trafficConfirmed &&
        request.actualRate == null) {
      final rate = await _showActualRateDialog(context);
      if (rate == null || !context.mounted) return;
      await context.read<RequestProvider>().updateStatus(
        request.copyWith(actualRate: rate),
        status,
      );
    } else {
      await context.read<RequestProvider>().updateStatus(request, status);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Moved to ${AppStatusStyles.requestStatus[_n(status)]!.label}',
          ),
        ),
      );
    }
  }

  Future<double?> _showActualRateDialog(BuildContext context) {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final currency = request.isSms ? 'EUR' : 'USD';

    return showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enter Actual Rate'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Actual rate is required to confirm traffic.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: ctrl,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Actual Rate',
                  suffixText: currency,
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Rate is required.';
                  if (double.tryParse(v.trim()) == null)
                    return 'Enter a valid number.';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop(double.parse(ctrl.text.trim()));
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.style});
  final dynamic style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: style.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 13, color: style.color),
          const SizedBox(width: 5),
          Text(
            style.label,
            style: AppTextStyles.labelMedium.copyWith(color: style.color),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children, this.title});
  final List<Widget> children;
  final String? title;

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
          if (title != null) ...[
            Text(title!.toUpperCase(), style: AppTextStyles.labelMedium),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
          ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
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
