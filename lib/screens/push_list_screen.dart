import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/theme.dart';
import '../models/promotion.dart';
import '../models/push_list_item.dart';
import '../models/route_request.dart';
import '../providers/promotion_provider.dart';
import '../providers/push_list_provider.dart';
import '../providers/request_provider.dart';

String _n(Enum e) => e.toString().split('.').last;

String _smsLabel(String key) => switch (key) {
  'direct' => 'Direct',
  'hq' => 'HQ',
  'localBypass' => 'Local Bypass',
  'sim' => 'SIM',
  'casino' => 'Casino',
  'spam' => 'Spam',
  'local' => 'Local',
  'ss7' => 'SS7',
  _ => key.toUpperCase(),
};

String _voiceLabel(String key) => switch (key) {
  'cli' => 'CLI',
  'nonCli' => 'Non-CLI',
  'cc' => 'CC',
  'tdm' => 'TDM',
  _ => key.toUpperCase(),
};

class PushListScreen extends StatelessWidget {
  const PushListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: const Text('Push List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Route',
            onPressed: () => _showAddSheet(context),
          ),
        ],
      ),
      body: Consumer<PushListProvider>(
        builder: (context, provider, _) {
          if (provider.error != null) {
            return Center(
              child: Text(provider.error!, style: AppTextStyles.bodyMedium),
            );
          }

          if (provider.all.isEmpty) {
            return _EmptyState(onAdd: () => _showAddSheet(context));
          }

          final smsGroups = provider.groupedSms;
          final voiceGroups = provider.groupedVoice;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // ── SMS section ───────────────────────────────────────────
              if (smsGroups.isNotEmpty) ...[
                _TypeHeader(
                  label: 'SMS',
                  color: AppColors.info,
                  count: provider.all.where((i) => i.isSms).length,
                ),
                const SizedBox(height: AppSpacing.md),
                ...smsGroups.entries.map(
                  (entry) => _SubGroup(
                    label: _smsLabel(entry.key),
                    color: AppColors.info,
                    items: entry.value,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // ── Voice section ─────────────────────────────────────────
              if (voiceGroups.isNotEmpty) ...[
                _TypeHeader(
                  label: 'Voice',
                  color: AppColors.statusSent,
                  count: provider.all.where((i) => i.isVoice).length,
                ),
                const SizedBox(height: AppSpacing.md),
                ...voiceGroups.entries.map(
                  (entry) => _SubGroup(
                    label: _voiceLabel(entry.key),
                    color: AppColors.statusSent,
                    items: entry.value,
                  ),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Route'),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddRouteSheet(),
    );
  }
}

// ── Type header (SMS / Voice) ─────────────────────────────────────────────────

class _TypeHeader extends StatelessWidget {
  const _TypeHeader({
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                label == 'SMS' ? Icons.sms_outlined : Icons.call_outlined,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.titleMedium.copyWith(color: color),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.labelSmall.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        const Expanded(child: Divider()),
      ],
    );
  }
}

// ── Sub-group (Direct, CLI etc.) ──────────────────────────────────────────────

class _SubGroup extends StatelessWidget {
  const _SubGroup({
    required this.label,
    required this.color,
    required this.items,
  });

  final String label;
  final Color color;
  final List<PushListItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.sm,
            bottom: AppSpacing.xs,
          ),
          child: Text(
            label.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(color: color),
          ),
        ),
        ...items.map((item) => _PushListTile(item: item, accentColor: color)),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

// ── Push list tile ────────────────────────────────────────────────────────────

class _PushListTile extends StatelessWidget {
  const _PushListTile({required this.item, required this.accentColor});

  final PushListItem item;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.country}  ·  ${item.operator}',
                    style: AppTextStyles.titleMedium,
                  ),
                  if (item.supplierName != null)
                    Text(item.supplierName!, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            if (item.rate != null) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.rate!.toStringAsFixed(4),
                    style: AppTextStyles.mono,
                  ),
                  Text(item.currency, style: AppTextStyles.labelSmall),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            // Source badge
            _SourceBadge(source: item.sourceType),
            const SizedBox(width: AppSpacing.sm),
            // Remove button
            IconButton(
              icon: const Icon(
                Icons.remove_circle_outline,
                color: AppColors.error,
                size: 20,
              ),
              onPressed: () => _confirmRemove(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove from Push List'),
        content: Text('Remove ${item.country} · ${item.operator}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<PushListProvider>().remove(item.id);
    }
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source});
  final PushListSource source;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (source) {
      PushListSource.request => ('REQ', AppColors.statusPending),
      PushListSource.promotion => ('PROMO', AppColors.primary),
      PushListSource.manual => ('MAN', AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}

// ── Add route sheet ───────────────────────────────────────────────────────────

enum _AddSource { request, promotion, manual }

class _AddRouteSheet extends StatefulWidget {
  const _AddRouteSheet();

  @override
  State<_AddRouteSheet> createState() => _AddRouteSheetState();
}

class _AddRouteSheetState extends State<_AddRouteSheet> {
  _AddSource _source = _AddSource.request;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.x3l,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add to Push List', style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppSpacing.lg),

          // Source toggle
          Row(
            children: [
              _SourceToggle(
                label: 'From Request',
                selected: _source == _AddSource.request,
                onTap: () => setState(() => _source = _AddSource.request),
              ),
              const SizedBox(width: AppSpacing.sm),
              _SourceToggle(
                label: 'From Promo',
                selected: _source == _AddSource.promotion,
                onTap: () => setState(() => _source = _AddSource.promotion),
              ),
              const SizedBox(width: AppSpacing.sm),
              _SourceToggle(
                label: 'Manual',
                selected: _source == _AddSource.manual,
                onTap: () => setState(() => _source = _AddSource.manual),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          if (_source == _AddSource.request)
            _FromRequestForm()
          else if (_source == _AddSource.promotion)
            _FromPromotionForm()
          else
            _ManualForm(),
        ],
      ),
    );
  }
}

class _SourceToggle extends StatelessWidget {
  const _SourceToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryMuted : AppColors.bgSubtle,
            borderRadius: AppRadius.cardRadius,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium.copyWith(
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── From Request form ─────────────────────────────────────────────────────────

class _FromRequestForm extends StatefulWidget {
  @override
  State<_FromRequestForm> createState() => _FromRequestFormState();
}

class _FromRequestFormState extends State<_FromRequestForm> {
  RouteRequest? _selected;

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<RequestProvider>().all;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<RouteRequest>(
          value: _selected,
          dropdownColor: AppColors.bgElevated,
          decoration: const InputDecoration(
            labelText: 'Select Request',
            prefixIcon: Icon(Icons.swap_horiz_outlined),
          ),
          items: requests
              .map(
                (r) => DropdownMenuItem(
                  value: r,
                  child: Text(
                    '${r.customerName}  ·  ${r.country}  ·  ${r.operator}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selected = v),
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: _selected == null
              ? null
              : () async {
                  await context.read<PushListProvider>().addFromRequest(
                    _selected!,
                  );
                  if (context.mounted) Navigator.of(context).pop();
                },
          child: const Text('Add to Push List'),
        ),
      ],
    );
  }
}

// ── From Promotion form ───────────────────────────────────────────────────────

class _FromPromotionForm extends StatefulWidget {
  @override
  State<_FromPromotionForm> createState() => _FromPromotionFormState();
}

class _FromPromotionFormState extends State<_FromPromotionForm> {
  Promotion? _selectedPromo;
  PromotionDestination? _selectedDest;

  @override
  Widget build(BuildContext context) {
    final promotions = context.watch<PromotionProvider>().active;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Promotion picker
        DropdownButtonFormField<Promotion>(
          value: _selectedPromo,
          dropdownColor: AppColors.bgElevated,
          decoration: const InputDecoration(
            labelText: 'Select Promotion',
            prefixIcon: Icon(Icons.campaign_outlined),
          ),
          items: promotions
              .map(
                (p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.title, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() {
            _selectedPromo = v;
            _selectedDest = null;
          }),
        ),

        if (_selectedPromo != null) ...[
          const SizedBox(height: AppSpacing.md),
          // Destination picker
          DropdownButtonFormField<PromotionDestination>(
            value: _selectedDest,
            dropdownColor: AppColors.bgElevated,
            decoration: const InputDecoration(
              labelText: 'Select Destination',
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items: _selectedPromo!.destinations
                .map(
                  (d) => DropdownMenuItem(
                    value: d,
                    child: Text(
                      '${d.country}  ·  ${d.operator}  ·  ${d.supplierName}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedDest = v),
          ),
        ],

        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: _selectedDest == null || _selectedPromo == null
              ? null
              : () async {
                  await context.read<PushListProvider>().addFromPromotion(
                    _selectedDest!,
                    _selectedPromo!.id,
                  );
                  if (context.mounted) Navigator.of(context).pop();
                },
          child: const Text('Add to Push List'),
        ),
      ],
    );
  }
}

// ── Manual form ───────────────────────────────────────────────────────────────

class _ManualForm extends StatefulWidget {
  @override
  State<_ManualForm> createState() => _ManualFormState();
}

class _ManualFormState extends State<_ManualForm> {
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<PushListProvider>().addManual(
      country: _countryCtrl.text.trim(),
      operator: _operatorCtrl.text.trim(),
      routeType: _routeType,
      smsRouteType: _smsType,
      voiceRouteType: _voiceType,
      rate: _rateCtrl.text.trim().isEmpty
          ? null
          : double.tryParse(_rateCtrl.text.trim()),
      supplierName: _supplierCtrl.text.trim().isEmpty
          ? null
          : _supplierCtrl.text.trim(),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
              itemLabel: (v) => _smsLabel(_n(v)),
              onChanged: (v) => setState(() => _smsType = v),
            )
          else
            _Dropdown<VoiceRouteType>(
              label: 'Voice Type',
              value: _voiceType,
              items: VoiceRouteType.values,
              itemLabel: (v) => _voiceLabel(_n(v)),
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
            label: 'Supplier (optional)',
            icon: Icons.business_outlined,
            required: false,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _rateCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Rate (optional)',
              prefixIcon: const Icon(Icons.attach_money),
              suffixText: _routeType == RouteType.sms ? 'EUR' : 'USD',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return null;
              if (double.tryParse(v.trim()) == null)
                return 'Enter a valid number.';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: _submit,
            child: const Text('Add to Push List'),
          ),
        ],
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

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
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl,
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    validator: required
        ? (v) => v == null || v.trim().isEmpty ? '$label is required.' : null
        : null,
  );
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
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    value: value,
    dropdownColor: AppColors.bgElevated,
    decoration: InputDecoration(labelText: label),
    items: items
        .map((e) => DropdownMenuItem(value: e, child: Text(itemLabel(e))))
        .toList(),
    onChanged: onChanged,
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.list_alt_outlined, size: 48, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.lg),
          Text('Push list is empty', style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add routes from requests, promotions,\nor enter them manually.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add Route'),
          ),
        ],
      ),
    );
  }
}
