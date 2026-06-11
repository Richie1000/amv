import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/repository/history_repository.dart';
import '../core/repository/promotion_repository.dart';
import '../models/promotion.dart';
import '../models/route_request.dart';

class HistoryProvider extends ChangeNotifier {
  HistoryProvider() {
    _requestSub = _requestRepo.watchClosed().listen(
      (list) {
        _allRequests = list;
        _applyFilters();
        notifyListeners();
      },
      onError: (e) {
        error = e.toString();
        notifyListeners();
      },
    );

    _promotionSub = _promotionRepo.watchAll().listen(
      (list) {
        _allPromotions = list;
        _applyFilters();
        notifyListeners();
      },
      onError: (e) {
        error = e.toString();
        notifyListeners();
      },
    );
  }

  final _requestRepo = HistoryRepository();
  final _promotionRepo = PromotionRepository();

  late final StreamSubscription _requestSub;
  late final StreamSubscription _promotionSub;

  List<RouteRequest> _allRequests = [];
  List<Promotion> _allPromotions = [];

  List<RouteRequest> filteredRequests = [];
  List<Promotion> filteredPromotions = [];

  String query = '';
  RouteType? routeType;
  DateTime? dateFrom;
  DateTime? dateTo;
  String? error;

  bool get isEmpty => filteredRequests.isEmpty && filteredPromotions.isEmpty;

  bool get hasActiveFilters =>
      query.isNotEmpty ||
      routeType != null ||
      dateFrom != null ||
      dateTo != null;

  void search(String q) {
    query = q.toLowerCase().trim();
    _applyFilters();
    notifyListeners();
  }

  void filterByRouteType(RouteType? type) {
    routeType = type;
    _applyFilters();
    notifyListeners();
  }

  void filterByDateRange(DateTime? from, DateTime? to) {
    dateFrom = from;
    dateTo = to;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    query = '';
    routeType = null;
    dateFrom = null;
    dateTo = null;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    filteredRequests = _filterRequests();
    filteredPromotions = _filterPromotions();
  }

  List<RouteRequest> _filterRequests() {
    return _allRequests.where((r) {
      if (query.isNotEmpty) {
        final hit =
            r.country.toLowerCase().contains(query) ||
            r.operator.toLowerCase().contains(query) ||
            r.customerName.toLowerCase().contains(query) ||
            (r.supplierName?.toLowerCase().contains(query) ?? false);
        if (!hit) return false;
      }
      if (routeType != null && r.routeType != routeType) return false;
      if (dateFrom != null && r.updatedAt.isBefore(dateFrom!)) return false;
      if (dateTo != null &&
          r.updatedAt.isAfter(dateTo!.add(const Duration(days: 1)))) {
        return false;
      }
      return true;
    }).toList();
  }

  List<Promotion> _filterPromotions() {
    return _allPromotions.where((p) {
      if (query.isNotEmpty) {
        final matchTitle = p.title.toLowerCase().contains(query);
        final matchDest = p.destinations.any(
          (d) =>
              d.country.toLowerCase().contains(query) ||
              d.operator.toLowerCase().contains(query) ||
              d.supplierName.toLowerCase().contains(query),
        );
        if (!matchTitle && !matchDest) return false;
      }
      if (routeType != null) {
        final hasType = p.destinations.any((d) => d.routeType == routeType);
        if (!hasType) return false;
      }
      if (dateFrom != null && p.createdAt.isBefore(dateFrom!)) return false;
      if (dateTo != null &&
          p.createdAt.isAfter(dateTo!.add(const Duration(days: 1)))) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _requestSub.cancel();
    _promotionSub.cancel();
    super.dispose();
  }
}
