import 'package:cloud_firestore/cloud_firestore.dart';

import 'route_request.dart';

String _n(Enum e) => e.toString().split('.').last;

enum PushListSource { request, promotion, manual }

class PushListItem {
  final String id;
  final String country;
  final String operator;
  final RouteType routeType;
  final SmsRouteType? smsRouteType;
  final VoiceRouteType? voiceRouteType;
  final String supplierName;
  final double supplierRate;
  final double sellingRate;
  final String? comment;
  final PushListSource sourceType;
  final String? sourceId;
  final DateTime addedAt;

  const PushListItem({
    required this.id,
    required this.country,
    required this.operator,
    required this.routeType,
    this.smsRouteType,
    this.voiceRouteType,
    required this.supplierName,
    required this.supplierRate,
    required this.sellingRate,
    this.comment,
    required this.sourceType,
    this.sourceId,
    required this.addedAt,
  });

  bool get isSms => routeType == RouteType.sms;
  bool get isVoice => routeType == RouteType.voice;
  String get currency => isSms ? 'EUR' : 'USD';

  factory PushListItem.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final rt = RouteType.values.byName(d['routeType'] as String);
    return PushListItem(
      id: doc.id,
      country: d['country'] as String,
      operator: d['operator'] as String,
      routeType: rt,
      smsRouteType: rt == RouteType.sms && d['smsRouteType'] != null
          ? SmsRouteType.values.byName(d['smsRouteType'] as String)
          : null,
      voiceRouteType: rt == RouteType.voice && d['voiceRouteType'] != null
          ? VoiceRouteType.values.byName(d['voiceRouteType'] as String)
          : null,
      supplierName: d['supplierName'] as String,
      supplierRate: (d['supplierRate'] as num).toDouble(),
      sellingRate: (d['sellingRate'] as num).toDouble(),
      comment: d['comment'] as String?,
      sourceType: PushListSource.values.byName(d['sourceType'] as String),
      sourceId: d['sourceId'] as String?,
      addedAt: (d['addedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'country': country,
    'operator': operator,
    'routeType': _n(routeType),
    'smsRouteType': smsRouteType != null ? _n(smsRouteType!) : null,
    'voiceRouteType': voiceRouteType != null ? _n(voiceRouteType!) : null,
    'supplierName': supplierName,
    'supplierRate': supplierRate,
    'sellingRate': sellingRate,
    'comment': comment,
    'sourceType': _n(sourceType),
    'sourceId': sourceId,
    'addedAt': Timestamp.fromDate(addedAt),
  };
}
