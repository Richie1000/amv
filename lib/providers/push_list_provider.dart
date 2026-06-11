import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/repository/pushlist_repository.dart';
import '../models/promotion.dart';
import '../models/route_request.dart';
import '../models/push_list_item.dart';

class PushListProvider extends ChangeNotifier {
  PushListProvider() {
    _sub = _repo.watchAll().listen(
      (list) {
        _items = list.cast<PushListItem>();
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

  List<PushListItem> get all => _items;

  // ── Grouped: SMS → subtype → items ───────────────────────────────────────

  Map<String, List<PushListItem>> get groupedSms {
    final smsItems = _items.where((i) => i.isSms).toList();
    return _groupBySubType(smsItems);
  }

  Map<String, List<PushListItem>> get groupedVoice {
    final voiceItems = _items.where((i) => i.isVoice).toList();
    return _groupBySubType(voiceItems);
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

  // ── Add from request ──────────────────────────────────────────────────────

  Future<void> addFromRequest(RouteRequest request) async {
    final item = PushListItem(
      id: const Uuid().v4(),
      country: request.country,
      operator: request.operator,
      routeType: request.routeType,
      smsRouteType: request.smsRouteType,
      voiceRouteType: request.voiceRouteType,
      rate: request.supplierRate ?? request.targetRate,
      supplierName: request.supplierName,
      sourceType: PushListSource.request,
      sourceId: request.id,
      addedAt: DateTime.now(),
    );
    await _repo.add(item);
  }

  // ── Add from promotion destination ────────────────────────────────────────

  Future<void> addFromPromotion(
    PromotionDestination dest,
    String promotionId,
  ) async {
    final item = PushListItem(
      id: const Uuid().v4(),
      country: dest.country,
      operator: dest.operator,
      routeType: dest.routeType,
      smsRouteType: dest.smsRouteType,
      voiceRouteType: dest.voiceRouteType,
      rate: dest.rate,
      supplierName: dest.supplierName,
      sourceType: PushListSource.promotion,
      sourceId: promotionId,
      addedAt: DateTime.now(),
    );
    await _repo.add(item);
  }

  // ── Add manually ──────────────────────────────────────────────────────────

  Future<void> addManual({
    required String country,
    required String operator,
    required RouteType routeType,
    SmsRouteType? smsRouteType,
    VoiceRouteType? voiceRouteType,
    double? rate,
    String? supplierName,
  }) async {
    final item = PushListItem(
      id: const Uuid().v4(),
      country: country,
      operator: operator,
      routeType: routeType,
      smsRouteType: routeType == RouteType.sms ? smsRouteType : null,
      voiceRouteType: routeType == RouteType.voice ? voiceRouteType : null,
      rate: rate,
      supplierName: supplierName,
      sourceType: PushListSource.manual,
      addedAt: DateTime.now(),
    );
    await _repo.add(item);
  }

  Future<void> remove(String id) => _repo.remove(id);

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
