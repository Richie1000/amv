import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/push_list_item.dart';

class PushListRepository {
  final _col = FirebaseFirestore.instance.collection('push_list');

  Stream<List<PushListItem>> watchAll() => _col
      .orderBy('addedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(PushListItem.fromFirestore).toList());

  Future<void> add(PushListItem item) =>
      _col.doc(item.id).set(item.toFirestore());

  Future<void> remove(String id) => _col.doc(id).delete();
}
