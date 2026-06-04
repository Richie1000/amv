import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/repository/request_repository.dart';
import '../models/route_request.dart';

class RequestProvider extends ChangeNotifier {
  RequestProvider() {
    _sub = _repo.watchAll().listen((requests) {
      _requests = requests;
      notifyListeners();
    });
  }

  final _repo = RequestRepository();
  late final StreamSubscription _sub;

  List<RouteRequest> _requests = [];
  bool isLoading = false;
  String? error;

  List<RouteRequest> get all => _requests;

  // Grouped by status — preserves display order
  Map<RequestStatus, List<RouteRequest>> get groupedByStatus {
    final map = <RequestStatus, List<RouteRequest>>{};
    for (final status in RequestStatus.values) {
      final group = _requests.where((r) => r.status == status).toList();
      if (group.isNotEmpty) map[status] = group;
    }
    return map;
  }

  Future<bool> create({
    required String customerName,
    required String accountManager,
    required String country,
    required String operator,
    required RouteType routeType,
    SmsRouteType? smsRouteType,
    VoiceRouteType? voiceRouteType,
    RequestPriority priority = RequestPriority.medium,
    double? targetRate,
    String? notes,
  }) async {
    _set(loading: true, error: null);
    try {
      final now = DateTime.now();
      final request = RouteRequest(
        id: const Uuid().v4(),
        customerName: customerName,
        accountManager: accountManager,
        country: country,
        operator: operator,
        routeType: routeType,
        smsRouteType: routeType == RouteType.sms ? smsRouteType : null,
        voiceRouteType: routeType == RouteType.voice ? voiceRouteType : null,
        targetRate: targetRate,
        supplierRate: null,
        sellingRate: null,
        status: RequestStatus.pending,
        priority: priority,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );
      await _repo.create(request);
      return true;
    } catch (e) {
      _set(error: 'Failed to create request. Please try again.');
      return false;
    } finally {
      _set(loading: false);
    }
  }

  Future<bool> updateStatus(RouteRequest request, RequestStatus status) async {
    _set(error: null);
    try {
      await _repo.update(request.copyWith(status: status));
      return true;
    } catch (e) {
      _set(error: 'Failed to update status.');
      return false;
    }
  }

  Future<bool> delete(String id) async {
    _set(error: null);
    try {
      await _repo.delete(id);
      return true;
    } catch (e) {
      _set(error: 'Failed to delete request.');
      return false;
    }
  }

  void _set({bool? loading, String? error}) {
    if (loading != null) isLoading = loading;
    this.error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
