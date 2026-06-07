import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/promotion.dart';

class PromotionRepository {
  final _col = FirebaseFirestore.instance.collection('promotions');

  Stream<List<Promotion>> watchAll() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Promotion.fromFirestore).toList());

  Future<void> create(Promotion promotion) =>
      _col.doc(promotion.id).set(promotion.toFirestore());

  Future<void> update(Promotion promotion) =>
      _col.doc(promotion.id).update(promotion.toFirestore());

  Future<void> delete(String id) => _col.doc(id).delete();
}
