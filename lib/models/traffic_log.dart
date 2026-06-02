import 'package:cloud_firestore/cloud_firestore.dart';

import 'route_request.dart';

enum TrafficStatus {
  testing,
  lowTraffic,
  stableTraffic,
  highTraffic,
  noTraffic,
}

class TrafficLog {
  final String id;
  final String requestId;
  final RouteType routeType;
  final TrafficStatus status;

  // SMS traffic fields
  final int? messagesPerDay;
  final double? deliveryRate; // percentage 0–100

  // Voice traffic fields
  final double? minutesPerDay;
  final double? asr; // Answer Seizure Ratio %
  final double? acd; // Average Call Duration (seconds)

  final double? estimatedRevenue;
  final String? notes;
  final DateTime updatedAt;

  const TrafficLog({
    required this.id,
    required this.requestId,
    required this.routeType,
    required this.status,
    this.messagesPerDay,
    this.deliveryRate,
    this.minutesPerDay,
    this.asr,
    this.acd,
    this.estimatedRevenue,
    this.notes,
    required this.updatedAt,
  });

  bool get isSms => routeType == RouteType.sms;
  bool get isVoice => routeType == RouteType.voice;

  factory TrafficLog.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final routeType = RouteType.values.byName(d['routeType'] as String);
    return TrafficLog(
      id: doc.id,
      requestId: d['requestId'] as String,
      routeType: routeType,
      status: TrafficStatus.values.byName(d['status'] as String),
      messagesPerDay: d['messagesPerDay'] as int?,
      deliveryRate: (d['deliveryRate'] as num?)?.toDouble(),
      minutesPerDay: (d['minutesPerDay'] as num?)?.toDouble(),
      asr: (d['asr'] as num?)?.toDouble(),
      acd: (d['acd'] as num?)?.toDouble(),
      estimatedRevenue: (d['estimatedRevenue'] as num?)?.toDouble(),
      notes: d['notes'] as String?,
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'requestId': requestId,
    'routeType': routeType.name,
    'status': status.name,
    'messagesPerDay': messagesPerDay,
    'deliveryRate': deliveryRate,
    'minutesPerDay': minutesPerDay,
    'asr': asr,
    'acd': acd,
    'estimatedRevenue': estimatedRevenue,
    'notes': notes,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
