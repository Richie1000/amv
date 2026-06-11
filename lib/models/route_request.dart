import 'package:cloud_firestore/cloud_firestore.dart';

enum RouteType { sms, voice }

enum SmsRouteType { direct, hq, localBypass, sim, casino, spam, local, ss7 }

enum VoiceRouteType { cli, nonCli, cc, tdm }

enum RequestStatus {
  pending,
  searchingSupplier,
  supplierFound,
  sentToCustomer,
  trafficConfirmed,
  noTraffic,
  closed,
}

enum RequestPriority { low, medium, high }

class RouteRequest {
  final String id;
  final String customerName;
  final String accountManager;
  final String country;
  final String operator;
  final RouteType routeType;
  final SmsRouteType? smsRouteType;
  final VoiceRouteType? voiceRouteType;
  final double? targetRate;
  final double? supplierRate;
  final String? supplierName;
  final double? sellingRate;
  final String? promotionId;
  final String? promotionComment;
  final RequestStatus status;
  final RequestPriority priority;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RouteRequest({
    required this.id,
    required this.customerName,
    required this.accountManager,
    required this.country,
    required this.operator,
    required this.routeType,
    this.smsRouteType,
    this.voiceRouteType,
    this.targetRate,
    this.supplierRate,
    this.supplierName,
    this.sellingRate,
    this.promotionId,
    this.promotionComment,
    required this.status,
    required this.priority,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isSms => routeType == RouteType.sms;
  bool get isVoice => routeType == RouteType.voice;

  factory RouteRequest.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final routeType = RouteType.values.byName(d['routeType'] as String);
    return RouteRequest(
      id: doc.id,
      customerName: d['customerName'] as String,
      accountManager: d['accountManager'] as String,
      country: d['country'] as String,
      operator: d['operator'] as String,
      routeType: routeType,
      smsRouteType: routeType == RouteType.sms && d['smsRouteType'] != null
          ? SmsRouteType.values.byName(d['smsRouteType'] as String)
          : null,
      voiceRouteType:
          routeType == RouteType.voice && d['voiceRouteType'] != null
          ? VoiceRouteType.values.byName(d['voiceRouteType'] as String)
          : null,
      targetRate: (d['targetRate'] as num?)?.toDouble(),
      supplierRate: (d['supplierRate'] as num?)?.toDouble(),
      supplierName: d['supplierName'] as String?,
      sellingRate: (d['sellingRate'] as num?)?.toDouble(),
      promotionId: d['promotionId'] as String?,
      promotionComment: d['promotionComment'] as String?,
      status: RequestStatus.values.byName(d['status'] as String),
      priority: RequestPriority.values.byName(d['priority'] as String),
      notes: d['notes'] as String?,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'customerName': customerName,
    'accountManager': accountManager,
    'country': country,
    'operator': operator,
    'routeType': routeType.toString().split('.').last,
    'smsRouteType': smsRouteType?.toString().split('.').last,
    'voiceRouteType': voiceRouteType?.toString().split('.').last,
    'targetRate': targetRate,
    'supplierRate': supplierRate,
    'supplierName': supplierName,
    'sellingRate': sellingRate,
    'promotionId': promotionId,
    'promotionComment': promotionComment,
    'status': status.toString().split('.').last,
    'priority': priority.toString().split('.').last,
    'notes': notes,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  RouteRequest copyWith({
    String? customerName,
    String? accountManager,
    String? country,
    String? operator,
    RouteType? routeType,
    SmsRouteType? smsRouteType,
    VoiceRouteType? voiceRouteType,
    double? targetRate,
    double? supplierRate,
    String? supplierName,
    double? sellingRate,
    String? promotionId,
    String? promotionComment,
    RequestStatus? status,
    RequestPriority? priority,
    String? notes,
    DateTime? updatedAt,
  }) => RouteRequest(
    id: id,
    customerName: customerName ?? this.customerName,
    accountManager: accountManager ?? this.accountManager,
    country: country ?? this.country,
    operator: operator ?? this.operator,
    routeType: routeType ?? this.routeType,
    smsRouteType: smsRouteType ?? this.smsRouteType,
    voiceRouteType: voiceRouteType ?? this.voiceRouteType,
    targetRate: targetRate ?? this.targetRate,
    supplierRate: supplierRate ?? this.supplierRate,
    supplierName: supplierName ?? this.supplierName,
    sellingRate: sellingRate ?? this.sellingRate,
    promotionId: promotionId ?? this.promotionId,
    promotionComment: promotionComment ?? this.promotionComment,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    notes: notes ?? this.notes,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
  );
}
