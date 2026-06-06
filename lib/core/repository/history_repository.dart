import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/route_request.dart';

class HistoryRepository {
  final _col = FirebaseFirestore.instance.collection('route_requests');

  Stream<List<RouteRequest>> watchClosed() => _col
      .where('status', isEqualTo: 'closed')
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(RouteRequest.fromFirestore).toList());
}
