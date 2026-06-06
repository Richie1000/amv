import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/followup.dart';

class FollowupRepository {
  final _col = FirebaseFirestore.instance.collection('followups');

  Stream<List<Followup>> watchAll() => _col
      .orderBy('scheduledAt')
      .snapshots()
      .map((s) => s.docs.map(Followup.fromFirestore).toList());

  Future<void> create(Followup followup) =>
      _col.doc(followup.id).set(followup.toFirestore());

  Future<void> update(Followup followup) =>
      _col.doc(followup.id).update(followup.toFirestore());

  Future<void> delete(String id) => _col.doc(id).delete();
}
