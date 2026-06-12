import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/repository/pushlist_repository.dart';
import '../models/promotion.dart';
import '../models/push_list_item.dart';
import '../models/route_request.dart';

class PushListProvider extends ChangeNotifier {
  PushListProvider() {
    _sub = _repo.watchAll().listen(
      (list) {
        _items = list;
        error = null;
        notifyListeners();
      },
      onError: (e) {
        error = e.toString();
        notifyListeners();
      },
    );
  }

  final _repo = PushListRepository();
  late final StreamSubscription _sub;

  List<PushListItem> _items = [];
  String? error;
  String query = '';

  List<PushListItem> get all => _search(_items);

  Map<String, List<PushListItem>> get groupedSms =>
      _groupBySubType(_search(_items).where((i) => i.isSms).toList());

  Map<String, List<PushListItem>> get groupedVoice =>
      _groupBySubType(_search(_items).where((i) => i.isVoice).toList());

  void search(String q) {
    query = q.toLowerCase().trim();
    notifyListeners();
  }

  // ── Duplicate check ───────────────────────────────────────────────────────

  bool _isDuplicate(
    String country,
    String operator,
    RouteType routeType,
    SmsRouteType? smsRouteType,
    VoiceRouteType? voiceRouteType,
  ) => _items.any(
    (i) =>
        i.country.toLowerCase() == country.toLowerCase() &&
        i.operator.toLowerCase() == operator.toLowerCase() &&
        i.routeType == routeType &&
        i.smsRouteType == smsRouteType &&
        i.voiceRouteType == voiceRouteType,
  );

  // ── Add ───────────────────────────────────────────────────────────────────

  Future<String?> add({
    required String country,
    required String operator,
    required RouteType routeType,
    SmsRouteType? smsRouteType,
    VoiceRouteType? voiceRouteType,
    required String supplierName,
    required double supplierRate,
    required double sellingRate,
    String? comment,
    required PushListSource sourceType,
    String? sourceId,
  }) async {
    if (_isDuplicate(
      country,
      operator,
      routeType,
      smsRouteType,
      voiceRouteType,
    )) {
      return 'This route is already in the push list.';
    }
    await _repo.add(
      PushListItem(
        id: const Uuid().v4(),
        country: country,
        operator: operator,
        routeType: routeType,
        smsRouteType: routeType == RouteType.sms ? smsRouteType : null,
        voiceRouteType: routeType == RouteType.voice ? voiceRouteType : null,
        supplierName: supplierName,
        supplierRate: supplierRate,
        sellingRate: sellingRate,
        comment: comment?.isEmpty == true ? null : comment,
        sourceType: sourceType,
        sourceId: sourceId,
        addedAt: DateTime.now(),
      ),
    );
    return null;
  }

  Future<void> remove(String id) => _repo.remove(id);

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<PushListItem> _search(List<PushListItem> items) {
    if (query.isEmpty) return items;
    return items
        .where(
          (i) =>
              i.country.toLowerCase().contains(query) ||
              i.operator.toLowerCase().contains(query) ||
              i.supplierName.toLowerCase().contains(query),
        )
        .toList();
  }

  Map<String, List<PushListItem>> _groupBySubType(List<PushListItem> items) {
    final map = <String, List<PushListItem>>{};
    for (final item in items) {
      final key = item.isSms
          ? (item.smsRouteType?.toString().split('.').last ?? 'other')
          : (item.voiceRouteType?.toString().split('.').last ?? 'other');
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
