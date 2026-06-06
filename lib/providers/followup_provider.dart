import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/repository/followup_repository.dart';
import '../core/services/notification_service.dart';
import '../models/followup.dart';
import '../models/route_request.dart';

class FollowupProvider extends ChangeNotifier {
  FollowupProvider() {
    _sub = _repo.watchAll().listen((list) {
      _followups = list;
      _markOverdue();
      notifyListeners();
    });
  }

  final _repo = FollowupRepository();
  late final StreamSubscription _sub;

  List<Followup> _followups = [];
  bool isLoading = false;
  String? error;

  // ── Getters ────────────────────────────────────────────────────────────────

  List<Followup> get overdue =>
      _followups.where((f) => f.status == FollowupStatus.overdue).toList();

  List<Followup> get today => _followups.where((f) => f.isToday).toList();

  List<Followup> get upcoming => _followups.where((f) {
    final now = DateTime.now();
    return f.status == FollowupStatus.pending &&
        f.scheduledAt.isAfter(now) &&
        !f.isToday;
  }).toList();

  List<Followup> get completed =>
      _followups.where((f) => f.status == FollowupStatus.completed).toList();

  int get overdueCount => overdue.length;

  // ── Create ─────────────────────────────────────────────────────────────────

  Future<void> createForRequest({
    required RouteRequest request,
    required DateTime scheduledAt,
    FollowupType type = FollowupType.customerCheck,
  }) async {
    final followup = Followup(
      id: const Uuid().v4(),
      requestId: request.id,
      customerName: request.customerName,
      type: type,
      scheduledAt: scheduledAt,
      status: FollowupStatus.pending,
      createdAt: DateTime.now(),
    );

    await _repo.create(followup);

    // Schedule local notification
    await NotificationService.instance.scheduleFollowup(
      id: followup.id.hashCode,
      customerName: request.customerName,
      followupId: followup.id,
      scheduledAt: scheduledAt,
    );
  }

  // ── Quick Actions ──────────────────────────────────────────────────────────

  Future<void> handleAction({
    required Followup followup,
    required FollowupAction action,
    required RouteRequest request,
    NoTrafficReason? noTrafficReason,
  }) async {
    // Cancel the notification
    await NotificationService.instance.cancel(followup.id.hashCode);

    switch (action) {
      case FollowupAction.trafficStarted:
        // Complete this followup
        await _repo.update(
          followup.copyWith(
            status: FollowupStatus.completed,
            lastAction: action,
          ),
        );
        // Auto-schedule stability check in 24hrs
        await createForRequest(
          request: request,
          scheduledAt: DateTime.now().add(const Duration(hours: 24)),
          type: FollowupType.trafficStability,
        );

      case FollowupAction.customerTesting:
        // Reschedule +4hrs
        final reschedule = DateTime.now().add(const Duration(hours: 4));
        await _repo.update(
          followup.copyWith(
            scheduledAt: reschedule,
            lastAction: action,
            status: FollowupStatus.pending,
          ),
        );
        await NotificationService.instance.scheduleFollowup(
          id: followup.id.hashCode,
          customerName: followup.customerName,
          followupId: followup.id,
          scheduledAt: reschedule,
        );

      case FollowupAction.noFeedbackYet:
        // Mark overdue
        await _repo.update(
          followup.copyWith(status: FollowupStatus.overdue, lastAction: action),
        );

      case FollowupAction.customerRejected:
        // Complete + store reason + caller handles request status update
        await _repo.update(
          followup.copyWith(
            status: FollowupStatus.completed,
            lastAction: action,
            noTrafficReason: noTrafficReason,
          ),
        );

      case FollowupAction.rescheduled:
        // Caller provides new scheduledAt via reschedule()
        break;
    }
  }

  Future<void> reschedule(Followup followup, DateTime newTime) async {
    await NotificationService.instance.cancel(followup.id.hashCode);
    await _repo.update(
      followup.copyWith(
        scheduledAt: newTime,
        status: FollowupStatus.pending,
        lastAction: FollowupAction.rescheduled,
      ),
    );
    await NotificationService.instance.scheduleFollowup(
      id: followup.id.hashCode,
      customerName: followup.customerName,
      followupId: followup.id,
      scheduledAt: newTime,
    );
  }

  Future<void> delete(String id) async {
    await NotificationService.instance.cancel(id.hashCode);
    await _repo.delete(id);
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  void _markOverdue() {
    final now = DateTime.now();
    for (final f in _followups) {
      if (f.status == FollowupStatus.pending && f.scheduledAt.isBefore(now)) {
        _repo.update(f.copyWith(status: FollowupStatus.overdue));
      }
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
