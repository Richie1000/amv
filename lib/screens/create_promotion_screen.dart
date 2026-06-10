import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../core/routes/routes.dart';
import '../core/theme/theme.dart';
import '../models/promotion.dart';
import '../models/route_request.dart';
import '../providers/promotion_provider.dart';

String _n(Enum e) => e.toString().split('.').last;

class CreatePromotionScreen extends StatefulWidget {
  const CreatePromotionScreen({super.key});

  @override
  State<CreatePromotionScreen> createState() => _CreatePromotionScreenState();
}

class _CreatePromotionScreenState extends State<CreatePromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _qualityCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  PromotionPriority _priority = PromotionPriority.medium;
  PromotionStatus _status = PromotionStatus.draft;
  DateTime _startDate = DateTime.now();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));

  final List<PromotionDestination> _destinations = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _qualityCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_destinations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one destination.')),
      );
      return;
    }

    final success = await context.read<PromotionProvider>().create(
      title: _titleCtrl.text.trim(),
      qualityDescription: _qualityCtrl.text.trim().isEmpty
          ? null
          : _qualityCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      startDate: _startDate,
      expiryDate: _expiryDate,
      priority: _priority,
      destinations: _destinations,
      status: _status,
    );

    if (success && mounted) context.go(AppRoutes.promotions);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PromotionProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: const Text('New Promotion'),
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
            if (provider.error != null) ...[
              _ErrorBanner(message: provider.error!),
              const SizedBox(height: AppSpacing.lg),
            ],

            // ── Basic info ────────────────────────────────────────────────
            _Label('Promotion Details'),
            const SizedBox(height: AppSpacing.sm),

            _Field(
              ctrl: _titleCtrl,
              label: 'Promotion Title',
              icon: Icons.campaign_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            _Field(
              ctrl: _qualityCtrl,
              label: 'Quality Description (optional)',
              icon: Icons.star_outline,
              required: false,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                alignLabelWithHint: true,
              ),
            ),

            // ── Priority ──────────────────────────────────────────────────
            const SizedBox(height: AppSpacing.xl),
            _Label('Priority'),
            const SizedBox(height: AppSpacing.sm),
            _PrioritySelector(
              value: _priority,
              onChanged: (v) => setState(() => _priority = v),
            ),

            // ── Status ────────────────────────────────────────────────────
            const SizedBox(height: AppSpacing.xl),
            _Label('Initial Status'),
            const SizedBox(height: AppSpacing.sm),
            _StatusSelector(
              value: _status,
              onChanged: (v) => setState(() => _status = v),
            ),

            // ── Dates ─────────────────────────────────────────────────────
            const SizedBox(height: AppSpacing.xl),
            _Label('Dates'),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Start Date',
                    value: _startDate,
                    onPick: (d) => setState(() => _startDate = d),
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _DateField(
                    label: 'Expiry Date',
                    value: _expiryDate,
                    onPick: (d) => setState(() => _expiryDate = d),
                    firstDate: _startDate,
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  ),
                ),
              ],
            ),

            // ── Destinations ──────────────────────────────────────────────
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                _Label('Destinations'),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  onPressed: () => _addDestination(context),
                ),
              ],
            ),

            if (_destinations.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.bgSubtle,
                  borderRadius: AppRadius.cardRadius,
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'No destinations added yet.\nTap Add to include countries and operators.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              )
            else
              ..._destinations.asMap().entries.map(
                (e) => _DestinationTile(
                  destination: e.value,
                  index: e.key,
                  onRemove: () => setState(() => _destinations.removeAt(e.key)),
                ),
              ),

            const SizedBox(height: AppSpacing.x4l),
          ],
        ),
      ),
    );
  }

  Future<void> _addDestination(BuildContext context) async {
    final dest = await showModalBottomSheet<PromotionDestination>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddDestinationSheet(),
    );
    if (dest != null) setState(() => _destinations.add(dest));
  }
}

// ── Add destination sheet ─────────────────────────────────────────────────────

class _AddDestinationSheet extends StatefulWidget {
  const _AddDestinationSheet();

  @override
  State<_AddDestinationSheet> createState() => _AddDestinationSheetState();
}

class _AddDestinationSheetState extends State<_AddDestinationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _countryCtrl = TextEditingController();
  final _operatorCtrl = TextEditingController();
  final _supplierCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();

  RouteType _routeType = RouteType.sms;
  SmsRouteType? _smsType;
  VoiceRouteType? _voiceType;

  @override
  void dispose() {
    _countryCtrl.dispose();
    _operatorCtrl.dispose();
    _supplierCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final dest = PromotionDestination(
      id: const Uuid().v4(),
      country: _countryCtrl.text.trim(),
      operator: _operatorCtrl.text.trim(),
      supplierName: _supplierCtrl.text.trim(),
      routeType: _routeType,
      smsRouteType: _routeType == RouteType.sms ? _smsType : null,
      voiceRouteType: _routeType == RouteType.voice ? _voiceType : null,
      rate: double.parse(_rateCtrl.text.trim()),
    );
    Navigator.of(context).pop(dest);
  }

  @override
  Widget build(BuildContext context) {
    final currency = _routeType == RouteType.sms ? 'EUR' : 'USD';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.x3l,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Destination', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppSpacing.xl),

            // Route type toggle
            _RouteTypeToggle(
              value: _routeType,
              onChanged: (v) => setState(() {
                _routeType = v;
                _smsType = null;
                _voiceType = null;
              }),
            ),
            const SizedBox(height: AppSpacing.md),

            // Sub type
            if (_routeType == RouteType.sms)
              _Dropdown<SmsRouteType>(
                label: 'SMS Type',
                value: _smsType,
                items: SmsRouteType.values,
                itemLabel: _smsLabel,
                onChanged: (v) => setState(() => _smsType = v),
              )
            else
              _Dropdown<VoiceRouteType>(
                label: 'Voice Type',
                value: _voiceType,
                items: VoiceRouteType.values,
                itemLabel: _voiceLabel,
                onChanged: (v) => setState(() => _voiceType = v),
              ),

            const SizedBox(height: AppSpacing.md),
            _Field(
              ctrl: _countryCtrl,
              label: 'Country',
              icon: Icons.flag_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            _Field(
              ctrl: _operatorCtrl,
              label: 'Operator',
              icon: Icons.cell_tower_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            _Field(
              ctrl: _supplierCtrl,
              label: 'Supplier Name',
              icon: Icons.business_outlined,
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _rateCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Rate',
                prefixIcon: const Icon(Icons.attach_money),
                suffixText: currency,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Rate is required.';
                if (double.tryParse(v.trim()) == null)
                  return 'Enter a valid number.';
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Add Destination'),
              ),
            ),
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
    SmsRouteType.ss7 => 'SS7',
  };

  String _voiceLabel(VoiceRouteType v) => switch (v) {
    VoiceRouteType.cli => 'CLI',
    VoiceRouteType.nonCli => 'Non-CLI',
    VoiceRouteType.cc => 'CC',
    VoiceRouteType.tdm => 'TDM',
  };
}

// ── Destination tile ──────────────────────────────────────────────────────────

class _DestinationTile extends StatelessWidget {
  const _DestinationTile({
    required this.destination,
    required this.index,
    required this.onRemove,
  });

  final PromotionDestination destination;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final color = destination.isSms ? AppColors.info : AppColors.statusSent;

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
                    '${destination.isSms ? 'SMS' : 'Voice'}  ·  '
                    '${destination.currency} ${destination.rate.toStringAsFixed(4)}',
                    style: AppTextStyles.monoSmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.remove_circle_outline,
                color: AppColors.error,
                size: 20,
              ),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Priority selector ─────────────────────────────────────────────────────────

class _PrioritySelector extends StatelessWidget {
  const _PrioritySelector({required this.value, required this.onChanged});
  final PromotionPriority value;
  final ValueChanged<PromotionPriority> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: PromotionPriority.values.map((p) {
        final selected = value == p;
        final style = AppStatusStyles.priority[_n(p)]!;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: p != PromotionPriority.high ? AppSpacing.sm : 0,
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

// ── Status selector ───────────────────────────────────────────────────────────

class _StatusSelector extends StatelessWidget {
  const _StatusSelector({required this.value, required this.onChanged});
  final PromotionStatus value;
  final ValueChanged<PromotionStatus> onChanged;

  static const _options = [PromotionStatus.draft, PromotionStatus.active];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _options.map((s) {
        final selected = value == s;
        final (label, color) = _style(s);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: s != _options.last ? AppSpacing.sm : 0,
            ),
            child: GestureDetector(
              onTap: () => onChanged(s),
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
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: selected ? color : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  (String, Color) _style(PromotionStatus s) => switch (s) {
    PromotionStatus.draft => ('Draft', AppColors.textSecondary),
    PromotionStatus.active => ('Active', AppColors.success),
    _ => ('', AppColors.textSecondary),
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

// ── Date field ────────────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onPick,
    required this.firstDate,
    required this.lastDate,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onPick;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: firstDate,
          lastDate: lastDate,
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgSubtle,
          borderRadius: AppRadius.inputRadius,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelSmall),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${value.day.toString().padLeft(2, '0')}/'
                  '${value.month.toString().padLeft(2, '0')}/'
                  '${value.year}',
                  style: AppTextStyles.mono,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: AppTextStyles.labelMedium);
}

class _Field extends StatelessWidget {
  const _Field({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.required = true,
  });

  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: required
          ? (v) => v == null || v.trim().isEmpty ? '$label is required.' : null
          : null,
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: AppColors.bgElevated,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(itemLabel(e))))
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
