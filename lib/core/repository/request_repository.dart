import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/route_request.dart';

class RequestRepository {
  final _col = FirebaseFirestore.instance.collection('route_requests');

  // Real-time stream of all requests
  Stream<List<RouteRequest>> watchAll() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(RouteRequest.fromFirestore).toList());
  }

  Future<void> create(RouteRequest request) =>
      _col.doc(request.id).set(request.toFirestore());

  Future<void> update(RouteRequest request) =>
      _col.doc(request.id).update(request.toFirestore());

  Future<void> delete(String id) => _col.doc(id).delete();
}
