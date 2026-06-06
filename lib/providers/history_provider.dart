import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/repository/history_repository.dart';
import '../models/route_request.dart';

class HistoryProvider extends ChangeNotifier {
  HistoryProvider() {
    _sub = _repo.watchClosed().listen(
      (list) {
        _all   = list;
        error  = null;
        _applyFilters();
        notifyListeners();
      },
      onError: (e) {
        error = e.toString();
        notifyListeners();
      },
    );
  }

  final _repo = HistoryRepository();
  late final StreamSubscription _sub;

  List<RouteRequest> _all      = [];
  List<RouteRequest> _filtered = [];
  String?            error;

  // Filters
  String     query     = '';
  RouteType? routeType;
  DateTime?  dateFrom;
  DateTime?  dateTo;

  List<RouteRequest> get results => _filtered;
  bool get isEmpty => _filtered.isEmpty;

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
    dateTo   = to;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    query     = '';
    routeType = null;
    dateFrom  = null;
    dateTo    = null;
    _applyFilters();
    notifyListeners();
  }

  bool get hasActiveFilters =>
      query.isNotEmpty || routeType != null ||
      dateFrom != null || dateTo != null;

  void _applyFilters() {
    _filtered = _all.where((r) {
      // Text search — country, operator, supplier name, customer
      if (query.isNotEmpty) {
        final hit = r.country.toLowerCase().contains(query)      ||
                    r.operator.toLowerCase().contains(query)     ||
                    r.customerName.toLowerCase().contains(query) ||
                    (r.supplierName?.toLowerCase().contains(query) ?? false);
        if (!hit) return false;
      }

      // Route type filter
      if (routeType != null && r.routeType != routeType) return false;

      // Date range filter
      if (dateFrom != null && r.updatedAt.isBefore(dateFrom!)) return false;
      if (dateTo   != null && r.updatedAt.isAfter(dateTo!.add(const Duration(days: 1)))) return false;

      return true;
    }).toList();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}