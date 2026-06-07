import 'package:cloud_firestore/cloud_firestore.dart';

import 'route_request.dart';

String _n(Enum e) => e.toString().split('.').last;

enum PromotionStatus { draft, active, paused, expired, closed }

enum PromotionPriority { low, medium, high }

// ── Destination ───────────────────────────────────────────────────────────────

class PromotionDestination {
  final String id;
  final String country;
  final String operator;
  final String supplierName;
  final RouteType routeType;
  final SmsRouteType? smsRouteType;
  final VoiceRouteType? voiceRouteType;
  final double rate;

  const PromotionDestination({
    required this.id,
    required this.country,
    required this.operator,
    required this.supplierName,
    required this.routeType,
    this.smsRouteType,
    this.voiceRouteType,
    required this.rate,
  });

  // Currency derived from route type
  String get currency => routeType == RouteType.sms ? 'EUR' : 'USD';

  bool get isSms => routeType == RouteType.sms;
  bool get isVoice => routeType == RouteType.voice;

  factory PromotionDestination.fromMap(Map<String, dynamic> m) {
    final rt = RouteType.values.byName(m['routeType'] as String);
    return PromotionDestination(
      id: m['id'] as String,
      country: m['country'] as String,
      operator: m['operator'] as String,
      supplierName: m['supplierName'] as String,
      routeType: rt,
      smsRouteType: rt == RouteType.sms && m['smsRouteType'] != null
          ? SmsRouteType.values.byName(m['smsRouteType'] as String)
          : null,
      voiceRouteType: rt == RouteType.voice && m['voiceRouteType'] != null
          ? VoiceRouteType.values.byName(m['voiceRouteType'] as String)
          : null,
      rate: (m['rate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'country': country,
    'operator': operator,
    'supplierName': supplierName,
    'routeType': _n(routeType),
    'smsRouteType': smsRouteType != null ? _n(smsRouteType!) : null,
    'voiceRouteType': voiceRouteType != null ? _n(voiceRouteType!) : null,
    'rate': rate,
  };
}

// ── Promotion ─────────────────────────────────────────────────────────────────

class Promotion {
  final String id;
  final String title;
  final String? qualityDescription;
  final String? notes;
  final DateTime startDate;
  final DateTime expiryDate;
  final PromotionPriority priority;
  final PromotionStatus status;
  final List<PromotionDestination> destinations;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Promotion({
    required this.id,
    required this.title,
    this.qualityDescription,
    this.notes,
    required this.startDate,
    required this.expiryDate,
    required this.priority,
    required this.status,
    required this.destinations,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get isExpiringSoon =>
      !isExpired && expiryDate.difference(DateTime.now()).inHours <= 48;

  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;

  int get hoursUntilExpiry => expiryDate.difference(DateTime.now()).inHours;

  String get expiryLabel {
    if (isExpired) return 'Expired';
    if (hoursUntilExpiry < 1) return 'Expires soon';
    if (hoursUntilExpiry < 24) return 'Expires in ${hoursUntilExpiry}h';
    return 'Expires in ${daysUntilExpiry}d';
  }

  factory Promotion.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Promotion(
      id: doc.id,
      title: d['title'] as String,
      qualityDescription: d['qualityDescription'] as String?,
      notes: d['notes'] as String?,
      startDate: (d['startDate'] as Timestamp).toDate(),
      expiryDate: (d['expiryDate'] as Timestamp).toDate(),
      priority: PromotionPriority.values.byName(d['priority'] as String),
      status: PromotionStatus.values.byName(d['status'] as String),
      destinations: (d['destinations'] as List<dynamic>)
          .map((e) => PromotionDestination.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'qualityDescription': qualityDescription,
    'notes': notes,
    'startDate': Timestamp.fromDate(startDate),
    'expiryDate': Timestamp.fromDate(expiryDate),
    'priority': _n(priority),
    'status': _n(status),
    'destinations': destinations.map((d) => d.toMap()).toList(),
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  Promotion copyWith({
    String? title,
    String? qualityDescription,
    String? notes,
    DateTime? startDate,
    DateTime? expiryDate,
    PromotionPriority? priority,
    PromotionStatus? status,
    List<PromotionDestination>? destinations,
    DateTime? updatedAt,
  }) => Promotion(
    id: id,
    title: title ?? this.title,
    qualityDescription: qualityDescription ?? this.qualityDescription,
    notes: notes ?? this.notes,
    startDate: startDate ?? this.startDate,
    expiryDate: expiryDate ?? this.expiryDate,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    destinations: destinations ?? this.destinations,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
  );
}
