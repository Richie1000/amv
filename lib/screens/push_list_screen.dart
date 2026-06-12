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

// ── Screen ────────────────────────────────────────────────────────────────────

class PushListScreen extends StatefulWidget {
  const PushListScreen({super.key});

  @override
  State<PushListScreen> createState() => _PushListScreenState();
}

class _PushListScreenState extends State<PushListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    context.read<PushListProvider>().search('');
    super.dispose();
  }

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) {
                context.read<PushListProvider>().search(v);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search country, operator, supplier...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<PushListProvider>().search('');
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: Consumer<PushListProvider>(
              builder: (context, provider, _) {
                if (provider.error != null) {
                  return Center(
                    child: Text(
                      provider.error!,
                      style: AppTextStyles.bodyMedium,
                    ),
                  );
                }

                if (provider.all.isEmpty) {
                  return _searchCtrl.text.isNotEmpty
                      ? Center(
                          child: Text(
                            'No results for "${_searchCtrl.text}"',
                            style: AppTextStyles.bodyMedium,
                          ),
                        )
                      : _EmptyState(onAdd: () => _showAddSheet(context));
                }

                final smsGroups = provider.groupedSms;
                final voiceGroups = provider.groupedVoice;

                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    if (smsGroups.isNotEmpty) ...[
                      _TypeHeader(
                        label: 'SMS',
                        color: AppColors.info,
                        count: provider.all.where((i) => i.isSms).length,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...smsGroups.entries.map(
                        (e) => _SubGroup(
                          label: _smsLabel(e.key),
                          color: AppColors.info,
                          items: e.value,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    if (voiceGroups.isNotEmpty) ...[
                      _TypeHeader(
                        label: 'Voice',
                        color: AppColors.statusSent,
                        count: provider.all.where((i) => i.isVoice).length,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...voiceGroups.entries.map(
                        (e) => _SubGroup(
                          label: _voiceLabel(e.key),
                          color: AppColors.statusSent,
                          items: e.value,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
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

// ── Type header ───────────────────────────────────────────────────────────────

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

// ── Sub-group ─────────────────────────────────────────────────────────────────

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
      child: InkWell(
        onTap: () => _showDetail(context),
        borderRadius: AppRadius.cardRadius,
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
                    Text(item.supplierName, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.sellingRate.toStringAsFixed(4),
                    style: AppTextStyles.mono,
                  ),
                  Text(item.currency, style: AppTextStyles.labelSmall),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              _SourceBadge(source: item.sourceType),
              const SizedBox(width: AppSpacing.sm),
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
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PushListDetailSheet(item: item),
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

// ── Detail sheet ──────────────────────────────────────────────────────────────

class _PushListDetailSheet extends StatelessWidget {
  const _PushListDetailSheet({required this.item});
  final PushListItem item;

  @override
  Widget build(BuildContext context) {
    final isSms = item.isSms;
    final color = isSms ? AppColors.info : AppColors.statusSent;
    final subType = isSms
        ? _smsLabel(item.smsRouteType?.toString().split('.').last ?? '')
        : _voiceLabel(item.voiceRouteType?.toString().split('.').last ?? '');

    final requests = context.watch<RequestProvider>().all;
    final promotions = context.watch<PromotionProvider>().all;

    final linkedRequest = item.sourceType == PushListSource.request
        ? requests.where((r) => r.id == item.sourceId).firstOrNull
        : null;

    final linkedPromotion = item.sourceType == PushListSource.promotion
        ? promotions.where((p) => p.id == item.sourceId).firstOrNull
        : null;

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
          // Header
          Row(
            children: [
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
                  '${isSms ? "SMS" : "Voice"}  ·  $subType',
                  style: AppTextStyles.labelMedium.copyWith(color: color),
                ),
              ),
              const Spacer(),
              _SourceBadge(source: item.sourceType),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Route details
          _DetailRow('Country', item.country),
          _DetailRow('Operator', item.operator),
          _DetailRow('Supplier', item.supplierName),
          _DetailRow(
            'Supplier Rate',
            '${item.currency} ${item.supplierRate.toStringAsFixed(4)}',
          ),
          _DetailRow(
            'Selling Rate',
            '${item.currency} ${item.sellingRate.toStringAsFixed(4)}',
          ),
          _DetailRow('Added', _fmtDate(item.addedAt)),

          // Comment
          if (item.comment != null) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            Text('COMMENT', style: AppTextStyles.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(item.comment!, style: AppTextStyles.bodyMedium),
          ],

          // Linked source
          if (linkedRequest != null || linkedPromotion != null) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.lg),
            Text('SOURCE', style: AppTextStyles.labelMedium),
            const SizedBox(height: AppSpacing.sm),
          ],

          if (linkedRequest != null)
            _SourceCard(
              icon: Icons.swap_horiz_outlined,
              color: AppColors.statusPending,
              title: linkedRequest.customerName,
              subtitle:
                  '${linkedRequest.country}  ·  ${linkedRequest.operator}',
              badge:
                  AppStatusStyles
                      .requestStatus[linkedRequest.status
                          .toString()
                          .split('.')
                          .last]
                      ?.label ??
                  '',
              badgeColor:
                  AppStatusStyles
                      .requestStatus[linkedRequest.status
                          .toString()
                          .split('.')
                          .last]
                      ?.color ??
                  AppColors.textSecondary,
            ),

          if (linkedPromotion != null)
            _SourceCard(
              icon: Icons.campaign_outlined,
              color: AppColors.primary,
              title: linkedPromotion.title,
              subtitle: linkedPromotion.expiryLabel,
              badge: linkedPromotion.status.toString().split('.').last,
              badgeColor: AppColors.primary,
            ),

          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.remove_circle_outline, size: 18),
              label: const Text('Remove from Push List'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await context.read<PushListProvider>().remove(item.id);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
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
      child: SingleChildScrollView(
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
              const _FromRequestForm()
            else if (_source == _AddSource.promotion)
              const _FromPromotionForm()
            else
              const _ManualForm(),
          ],
        ),
      ),
    );
  }
}

// ── From Request form ─────────────────────────────────────────────────────────

class _FromRequestForm extends StatefulWidget {
  const _FromRequestForm();

  @override
  State<_FromRequestForm> createState() => _FromRequestFormState();
}

class _FromRequestFormState extends State<_FromRequestForm> {
  RouteRequest? _selected;
  final _supplierRateCtrl = TextEditingController();
  final _sellingRateCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _supplierRateCtrl.dispose();
    _sellingRateCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  void _onRequestSelected(RouteRequest r) {
    setState(() {
      _selected = r;
      _supplierRateCtrl.text = r.supplierRate?.toStringAsFixed(4) ?? '';
      _sellingRateCtrl.text = r.sellingRate?.toStringAsFixed(4) ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<RequestProvider>().all;
    final currency = _selected?.isSms == true ? 'EUR' : 'USD';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Searchable request picker
          if (_selected == null)
            _SearchableSelect<RouteRequest>(
              items: requests,
              searchLabel: 'Search requests...',
              itemLabel: (r) =>
                  '${r.customerName}  ·  ${r.country}  ·  ${r.operator}',
              itemSub: (r) =>
                  AppStatusStyles
                      .requestStatus[r.status.toString().split('.').last]
                      ?.label ??
                  '',
              onSelected: _onRequestSelected,
            )
          else
            _SelectedChip(
              label:
                  '${_selected!.customerName}  ·  ${_selected!.country}  ·  ${_selected!.operator}',
              onClear: () => setState(() {
                _selected = null;
                _supplierRateCtrl.clear();
                _sellingRateCtrl.clear();
              }),
            ),

          if (_selected != null) ...[
            const SizedBox(height: AppSpacing.md),
            _RateField(
              ctrl: _supplierRateCtrl,
              label: 'Supplier Rate',
              currency: currency,
            ),
            const SizedBox(height: AppSpacing.md),
            _RateField(
              ctrl: _sellingRateCtrl,
              label: 'Selling Rate',
              currency: currency,
            ),
            const SizedBox(height: AppSpacing.md),
            _CommentField(ctrl: _commentCtrl),
          ],

          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: _selected == null ? null : () => _submit(context),
            child: const Text('Add to Push List'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final r = _selected!;
    final error = await context.read<PushListProvider>().add(
      country: r.country,
      operator: r.operator,
      routeType: r.routeType,
      smsRouteType: r.smsRouteType,
      voiceRouteType: r.voiceRouteType,
      supplierName: r.supplierName ?? '',
      supplierRate: double.parse(_supplierRateCtrl.text.trim()),
      sellingRate: double.parse(_sellingRateCtrl.text.trim()),
      comment: _commentCtrl.text.trim().isEmpty
          ? null
          : _commentCtrl.text.trim(),
      sourceType: PushListSource.request,
      sourceId: r.id,
    );
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.of(context).pop();
    }
  }
}

// ── From Promotion form ───────────────────────────────────────────────────────

class _FromPromotionForm extends StatefulWidget {
  const _FromPromotionForm();

  @override
  State<_FromPromotionForm> createState() => _FromPromotionFormState();
}

class _FromPromotionFormState extends State<_FromPromotionForm> {
  Promotion? _selectedPromo;
  PromotionDestination? _selectedDest;
  final _supplierRateCtrl = TextEditingController();
  final _sellingRateCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _supplierRateCtrl.dispose();
    _sellingRateCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final promotions = context.watch<PromotionProvider>().active;
    final currency = _selectedDest?.isSms == true ? 'EUR' : 'USD';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step 1 - pick promotion
          if (_selectedPromo == null)
            _SearchableSelect<Promotion>(
              items: promotions,
              searchLabel: 'Search promotions...',
              itemLabel: (p) => p.title,
              itemSub: (p) => p.expiryLabel,
              onSelected: (p) => setState(() {
                _selectedPromo = p;
                _selectedDest = null;
                _supplierRateCtrl.clear();
                _sellingRateCtrl.clear();
              }),
            )
          else
            _SelectedChip(
              label: _selectedPromo!.title,
              onClear: () => setState(() {
                _selectedPromo = null;
                _selectedDest = null;
                _supplierRateCtrl.clear();
                _sellingRateCtrl.clear();
              }),
            ),

          // Step 2 - pick destination
          if (_selectedPromo != null) ...[
            const SizedBox(height: AppSpacing.md),
            if (_selectedDest == null)
              _SearchableSelect<PromotionDestination>(
                items: _selectedPromo!.destinations,
                searchLabel: 'Search destinations...',
                itemLabel: (d) => '\${d.country}  ·  \${d.operator}',
                itemSub: (d) => d.supplierName,
                onSelected: (d) => setState(() {
                  _selectedDest = d;
                  _supplierRateCtrl.text = d.rate.toStringAsFixed(4);
                  _sellingRateCtrl.text = '';
                }),
              )
            else
              _SelectedChip(
                label:
                    '\${_selectedDest!.country}  ·  \${_selectedDest!.operator}  ·  \${_selectedDest!.supplierName}',
                onClear: () => setState(() {
                  _selectedDest = null;
                  _supplierRateCtrl.clear();
                  _sellingRateCtrl.clear();
                }),
              ),
          ],

          // Step 3 - rates and comment
          if (_selectedDest != null) ...[
            const SizedBox(height: AppSpacing.md),
            _RateField(
              ctrl: _supplierRateCtrl,
              label: 'Supplier Rate',
              currency: currency,
            ),
            const SizedBox(height: AppSpacing.md),
            _RateField(
              ctrl: _sellingRateCtrl,
              label: 'Selling Rate',
              currency: currency,
            ),
            const SizedBox(height: AppSpacing.md),
            _CommentField(ctrl: _commentCtrl),
          ],

          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: _selectedDest == null ? null : () => _submit(context),
            child: const Text('Add to Push List'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final d = _selectedDest!;
    final error = await context.read<PushListProvider>().add(
      country: d.country,
      operator: d.operator,
      routeType: d.routeType,
      smsRouteType: d.smsRouteType,
      voiceRouteType: d.voiceRouteType,
      supplierName: d.supplierName,
      supplierRate: double.parse(_supplierRateCtrl.text.trim()),
      sellingRate: double.parse(_sellingRateCtrl.text.trim()),
      comment: _commentCtrl.text.trim().isEmpty
          ? null
          : _commentCtrl.text.trim(),
      sourceType: PushListSource.promotion,
      sourceId: _selectedPromo!.id,
    );
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.of(context).pop();
    }
  }
}

// ── Manual form ───────────────────────────────────────────────────────────────

class _ManualForm extends StatefulWidget {
  const _ManualForm();

  @override
  State<_ManualForm> createState() => _ManualFormState();
}

class _ManualFormState extends State<_ManualForm> {
  final _formKey = GlobalKey<FormState>();
  final _countryCtrl = TextEditingController();
  final _operatorCtrl = TextEditingController();
  final _supplierCtrl = TextEditingController();
  final _supplierRateCtrl = TextEditingController();
  final _sellingRateCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();

  RouteType _routeType = RouteType.sms;
  SmsRouteType? _smsType;
  VoiceRouteType? _voiceType;

  @override
  void dispose() {
    _countryCtrl.dispose();
    _operatorCtrl.dispose();
    _supplierCtrl.dispose();
    _supplierRateCtrl.dispose();
    _sellingRateCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = _routeType == RouteType.sms ? 'EUR' : 'USD';

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
            label: 'Supplier Name',
            icon: Icons.business_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          _RateField(
            ctrl: _supplierRateCtrl,
            label: 'Supplier Rate',
            currency: currency,
          ),
          const SizedBox(height: AppSpacing.md),
          _RateField(
            ctrl: _sellingRateCtrl,
            label: 'Selling Rate',
            currency: currency,
          ),
          const SizedBox(height: AppSpacing.md),
          _CommentField(ctrl: _commentCtrl),
          const SizedBox(height: AppSpacing.xl),

          FilledButton(
            onPressed: () => _submit(context),
            child: const Text('Add to Push List'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final error = await context.read<PushListProvider>().add(
      country: _countryCtrl.text.trim(),
      operator: _operatorCtrl.text.trim(),
      routeType: _routeType,
      smsRouteType: _smsType,
      voiceRouteType: _voiceType,
      supplierName: _supplierCtrl.text.trim(),
      supplierRate: double.parse(_supplierRateCtrl.text.trim()),
      sellingRate: double.parse(_sellingRateCtrl.text.trim()),
      comment: _commentCtrl.text.trim().isEmpty
          ? null
          : _commentCtrl.text.trim(),
      sourceType: PushListSource.manual,
    );
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.of(context).pop();
    }
  }
}

// ── Shared form widgets ───────────────────────────────────────────────────────

class _RateField extends StatelessWidget {
  const _RateField({
    required this.ctrl,
    required this.label,
    required this.currency,
  });
  final TextEditingController ctrl;
  final String label;
  final String currency;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.attach_money),
      suffixText: currency,
    ),
    validator: (v) {
      if (v == null || v.trim().isEmpty) return '$label is required.';
      if (double.tryParse(v.trim()) == null) return 'Enter a valid number.';
      return null;
    },
  );
}

class _CommentField extends StatelessWidget {
  const _CommentField({required this.ctrl});
  final TextEditingController ctrl;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl,
    maxLines: 2,
    decoration: const InputDecoration(
      labelText: 'Comment (optional)',
      hintText: 'e.g. Good quality, tested on Kenya traffic',
      alignLabelWithHint: true,
      prefixIcon: Icon(Icons.comment_outlined),
    ),
  );
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
  const _Field({required this.ctrl, required this.label, required this.icon});
  final TextEditingController ctrl;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl,
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    validator: (v) =>
        v == null || v.trim().isEmpty ? '$label is required.' : null,
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

// ── Searchable select ─────────────────────────────────────────────────────────

class _SearchableSelect<T> extends StatefulWidget {
  const _SearchableSelect({
    required this.items,
    required this.searchLabel,
    required this.itemLabel,
    required this.itemSub,
    required this.onSelected,
  });

  final List<T> items;
  final String searchLabel;
  final String Function(T) itemLabel;
  final String Function(T) itemSub;
  final ValueChanged<T> onSelected;

  @override
  State<_SearchableSelect<T>> createState() => _SearchableSelectState<T>();
}

class _SearchableSelectState<T> extends State<_SearchableSelect<T>> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((item) {
      if (_query.isEmpty) return true;
      return widget.itemLabel(item).toLowerCase().contains(_query) ||
          widget.itemSub(item).toLowerCase().contains(_query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _ctrl,
          onChanged: (v) => setState(() => _query = v.toLowerCase().trim()),
          decoration: InputDecoration(
            hintText: widget.searchLabel,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _ctrl.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
          ),
        ),
        if (filtered.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: AppRadius.cardRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final item = filtered[i];
                return InkWell(
                  onTap: () => widget.onSelected(item),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.itemLabel(item),
                          style: AppTextStyles.titleMedium,
                        ),
                        if (widget.itemSub(item).isNotEmpty)
                          Text(
                            widget.itemSub(item),
                            style: AppTextStyles.bodySmall,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ] else if (_query.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              'No results for "$_query"',
              style: AppTextStyles.bodySmall,
            ),
          ),
      ],
    );
  }
}

// ── Selected chip (shows selected item with clear button) ─────────────────────

class _SelectedChip extends StatelessWidget {
  const _SelectedChip({required this.label, required this.onClear});
  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryMuted,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, color: AppColors.primary, size: 18),
          ),
        ],
      ),
    );
  }
}

// ── Source badge ──────────────────────────────────────────────────────────────

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

// ── Detail helper widgets ─────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
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

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;

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
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              badge,
              style: AppTextStyles.labelSmall.copyWith(color: badgeColor),
            ),
          ),
        ],
      ),
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
