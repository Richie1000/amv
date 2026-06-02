import 'package:cloud_firestore/cloud_firestore.dart';

enum RouteType { sms, voice }

enum SmsRouteType { p2p, a2p, greyRoute }

enum VoiceRouteType { cli, nonCli, tollfree, premium }

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
  final SmsRouteType? smsRouteType; // set when routeType == sms
  final VoiceRouteType? voiceRouteType; // set when routeType == voice
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
    'routeType': routeType.name,
    'smsRouteType': smsRouteType?.name,
    'voiceRouteType': voiceRouteType?.name,
    'status': status.name,
    'priority': priority.name,
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
    status: status ?? this.status,
    priority: priority ?? this.priority,
    notes: notes ?? this.notes,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
  );
}
