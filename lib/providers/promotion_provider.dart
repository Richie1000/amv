import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/repository/promotion_repository.dart';
import '../models/promotion.dart';

class PromotionProvider extends ChangeNotifier {
  final _repo = PromotionRepository();
  late final StreamSubscription _sub;

  List<Promotion> _promotions = [];
  bool isLoading = false;
  String? error;

  PromotionProvider() {
    _sub = _repo.watchAll().listen(
      (list) {
        _promotions = list;
        error = null;
        _autoExpire();
        notifyListeners();
      },
      onError: (e) {
        error = e.toString();
        notifyListeners();
      },
    );
  }

  List<Promotion> get all => _promotions;
  List<Promotion> get active => _byStatus(PromotionStatus.active);
  List<Promotion> get draft => _byStatus(PromotionStatus.draft);
  List<Promotion> get paused => _byStatus(PromotionStatus.paused);
  List<Promotion> get expired => _byStatus(PromotionStatus.expired);
  List<Promotion> get expiring =>
      active.where((p) => p.isExpiringSoon).toList();
  List<Promotion> get highPriority =>
      active.where((p) => p.priority == PromotionPriority.high).toList();

  List<Promotion> _byStatus(PromotionStatus s) =>
      _promotions.where((p) => p.status == s).toList();

  Future<bool> create({
    required String title,
    String? qualityDescription,
    String? notes,
    required DateTime startDate,
    required DateTime expiryDate,
    required PromotionPriority priority,
    required List<PromotionDestination> destinations,
    PromotionStatus status = PromotionStatus.draft,
  }) async {
    _set(loading: true, error: null);
    try {
      final now = DateTime.now();
      final promotion = Promotion(
        id: const Uuid().v4(),
        title: title,
        qualityDescription: qualityDescription,
        notes: notes,
        startDate: startDate,
        expiryDate: expiryDate,
        priority: priority,
        status: status,
        destinations: destinations,
        createdAt: now,
        updatedAt: now,
      );
      await _repo.create(promotion);
      return true;
    } catch (e) {
      _set(error: 'Failed to create promotion.');
      return false;
    } finally {
      _set(loading: false);
    }
  }

  Future<bool> updateStatus(Promotion promotion, PromotionStatus status) async {
    try {
      await _repo.update(promotion.copyWith(status: status));
      return true;
    } catch (e) {
      _set(error: 'Failed to update status.');
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _repo.delete(id);
      return true;
    } catch (e) {
      _set(error: 'Failed to delete promotion.');
      return false;
    }
  }

  // Auto-mark expired promotions
  void _autoExpire() {
    for (final p in _promotions) {
      if (p.isExpired && p.status == PromotionStatus.active) {
        _repo.update(p.copyWith(status: PromotionStatus.expired));
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
