import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/route_request.dart';
import '../../providers/request_provider.dart';
import '../core/theme/theme.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerCtrl = TextEditingController();
  final _managerCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _operatorCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _targetRateCtrl = TextEditingController();

  RouteType _routeType = RouteType.sms;
  SmsRouteType? _smsType;
  VoiceRouteType? _voiceType;
  RequestPriority _priority = RequestPriority.medium;

  @override
  void dispose() {
    _customerCtrl.dispose();
    _managerCtrl.dispose();
    _countryCtrl.dispose();
    _operatorCtrl.dispose();
    _notesCtrl.dispose();
    _targetRateCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<RequestProvider>().create(
      customerName: _customerCtrl.text.trim(),
      accountManager: _managerCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      operator: _operatorCtrl.text.trim(),
      routeType: _routeType,
      smsRouteType: _smsType,
      voiceRouteType: _voiceType,
      priority: _priority,
      targetRate: _targetRateCtrl.text.trim().isEmpty
          ? null
          : double.tryParse(_targetRateCtrl.text.trim()),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    if (success && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: const Text('New Request'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: FilledButton(
              onPressed: provider.isLoading ? null : _submit,
              child: provider.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textOnPrimary,
                      ),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Error banner
            if (provider.error != null) ...[
              _ErrorBanner(message: provider.error!),
              const SizedBox(height: AppSpacing.lg),
            ],

            _SectionLabel('Route Type'),
            const SizedBox(height: AppSpacing.sm),
            _RouteTypeToggle(
              value: _routeType,
              onChanged: (v) => setState(() {
                _routeType = v;
                _smsType = null;
                _voiceType = null;
              }),
            ),

            const SizedBox(height: AppSpacing.lg),
            _SectionLabel('Sub Type'),
            const SizedBox(height: AppSpacing.sm),

            // SMS sub-type
            if (_routeType == RouteType.sms)
              _DropdownField<SmsRouteType>(
                label: 'SMS Route Type',
                value: _smsType,
                items: SmsRouteType.values,
                label2: (v) => _smsLabel(v),
                onChanged: (v) => setState(() => _smsType = v),
              ),

            // Voice sub-type
            if (_routeType == RouteType.voice)
              _DropdownField<VoiceRouteType>(
                label: 'Voice Route Type',
                value: _voiceType,
                items: VoiceRouteType.values,
                label2: (v) => _voiceLabel(v),
                onChanged: (v) => setState(() => _voiceType = v),
              ),

            const SizedBox(height: AppSpacing.lg),
            _SectionLabel('Request Details'),
            const SizedBox(height: AppSpacing.sm),

            _TextField(
              controller: _customerCtrl,
              label: 'Customer Name',
              icon: Icons.person_outline,
              action: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),

            _TextField(
              controller: _managerCtrl,
              label: 'Account Manager',
              icon: Icons.badge_outlined,
              action: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),

            _TextField(
              controller: _countryCtrl,
              label: 'Country',
              icon: Icons.flag_outlined,
              action: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),

            _TextField(
              controller: _operatorCtrl,
              label: 'Operator',
              icon: Icons.cell_tower_outlined,
              action: TextInputAction.next,
            ),

            const SizedBox(height: AppSpacing.lg),
            _SectionLabel('Priority'),
            const SizedBox(height: AppSpacing.sm),

            _PrioritySelector(
              value: _priority,
              onChanged: (v) => setState(() => _priority = v),
            ),

            const SizedBox(height: AppSpacing.lg),
            _SectionLabel('Target Rate (optional)'),
            const SizedBox(height: AppSpacing.sm),

            TextFormField(
              controller: _targetRateCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Target Rate',
                prefixIcon: const Icon(Icons.track_changes_outlined),
                suffixText: _routeType == RouteType.sms ? 'EUR' : 'USD',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null; // optional
                if (double.tryParse(v.trim()) == null)
                  return 'Enter a valid number.';
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.lg),
            _SectionLabel('Notes  (optional)'),
            const SizedBox(height: AppSpacing.sm),

            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Any additional notes...',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: AppSpacing.x3l),
          ],
        ),
      ),
    );
  }

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

// ── Route type toggle ─────────────────────────────────────────────────────────

class _RouteTypeToggle extends StatelessWidget {
  const _RouteTypeToggle({required this.value, required this.onChanged});
  final RouteType value;
  final ValueChanged<RouteType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: RouteType.values.map((type) {
        final selected = value == type;
        final isSms = type == RouteType.sms;
        final color = isSms ? AppColors.info : AppColors.statusSent;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isSms ? AppSpacing.sm : 0),
            child: GestureDetector(
              onTap: () => onChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: selected
                      ? color.withOpacity(0.12)
                      : AppColors.bgSubtle,
                  borderRadius: AppRadius.cardRadius,
                  border: Border.all(
                    color: selected ? color : AppColors.border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSms ? Icons.sms_outlined : Icons.call_outlined,
                      size: 18,
                      color: selected ? color : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isSms ? 'SMS' : 'Voice',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: selected ? color : AppColors.textSecondary,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Priority selector ─────────────────────────────────────────────────────────

class _PrioritySelector extends StatelessWidget {
  const _PrioritySelector({required this.value, required this.onChanged});
  final RequestPriority value;
  final ValueChanged<RequestPriority> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: RequestPriority.values.map((p) {
        final selected = value == p;
        final style = AppStatusStyles.priority[p.name]!;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: p != RequestPriority.high ? AppSpacing.sm : 0,
            ),
            child: GestureDetector(
              onTap: () => onChanged(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: selected
                      ? style.color.withOpacity(0.12)
                      : AppColors.bgSubtle,
                  borderRadius: AppRadius.cardRadius,
                  border: Border.all(
                    color: selected ? style.color : AppColors.border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      style.icon,
                      size: 16,
                      color: selected ? style.color : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      style.label,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: selected ? style.color : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Reusable small widgets ────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: AppTextStyles.labelMedium);
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.action,
  });
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputAction action;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: action,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (v) =>
          v == null || v.trim().isEmpty ? '$label is required.' : null,
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.label2,
    required this.onChanged,
  });
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) label2;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: AppColors.bgElevated,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(label2(e))))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
