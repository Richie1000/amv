import 'package:cloud_firestore/cloud_firestore.dart';

import 'route_request.dart';

// SMS-specific rate fields
class SmsRateDetails {
  final double ratePerSms; // cost per SMS message
  final String senderIdType; // 'numeric' | 'alphanumeric' | 'shortcode'
  final bool dlrSupported; // delivery receipt support
  final int? validityPeriod; // hours

  const SmsRateDetails({
    required this.ratePerSms,
    required this.senderIdType,
    required this.dlrSupported,
    this.validityPeriod,
  });

  factory SmsRateDetails.fromMap(Map<String, dynamic> m) => SmsRateDetails(
    ratePerSms: (m['ratePerSms'] as num).toDouble(),
    senderIdType: m['senderIdType'] as String,
    dlrSupported: m['dlrSupported'] as bool? ?? false,
    validityPeriod: m['validityPeriod'] as int?,
  );

  Map<String, dynamic> toMap() => {
    'ratePerSms': ratePerSms,
    'senderIdType': senderIdType,
    'dlrSupported': dlrSupported,
    'validityPeriod': validityPeriod,
  };
}

// Voice-specific rate fields
class VoiceRateDetails {
  final double ratePerMinute;
  final String billingIncrement; // e.g. "6/6", "1/1", "30/6"
  final bool cliSupported;
  final String? prefix; // specific dialing prefix if any

  const VoiceRateDetails({
    required this.ratePerMinute,
    required this.billingIncrement,
    required this.cliSupported,
    this.prefix,
  });

  factory VoiceRateDetails.fromMap(Map<String, dynamic> m) => VoiceRateDetails(
    ratePerMinute: (m['ratePerMinute'] as num).toDouble(),
    billingIncrement: m['billingIncrement'] as String,
    cliSupported: m['cliSupported'] as bool? ?? false,
    prefix: m['prefix'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'ratePerMinute': ratePerMinute,
    'billingIncrement': billingIncrement,
    'cliSupported': cliSupported,
    'prefix': prefix,
  };
}

class SupplierRate {
  final String id;
  final String requestId;
  final RouteType routeType;
  final String supplierName;
  final String supplierContact;
  final SmsRateDetails? smsDetails; // set when routeType == sms
  final VoiceRateDetails? voiceDetails; // set when routeType == voice
  final String? qualityNotes;
  final bool isPreferred;
  final DateTime submittedAt;

  // EUR for SMS, USD for Voice
  String get currency => routeType == RouteType.sms ? 'EUR' : 'USD';

  const SupplierRate({
    required this.id,
    required this.requestId,
    required this.routeType,
    required this.supplierName,
    required this.supplierContact,
    this.smsDetails,
    this.voiceDetails,
    this.qualityNotes,
    this.isPreferred = false,
    required this.submittedAt,
  });

  // Convenience: the "main" rate regardless of type
  double get displayRate => routeType == RouteType.sms
      ? (smsDetails?.ratePerSms ?? 0)
      : (voiceDetails?.ratePerMinute ?? 0);

  String get rateLabel => routeType == RouteType.sms ? 'per SMS' : 'per min';

  factory SupplierRate.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final routeType = RouteType.values.byName(d['routeType'] as String);
    return SupplierRate(
      id: doc.id,
      requestId: d['requestId'] as String,
      routeType: routeType,
      supplierName: d['supplierName'] as String,
      supplierContact: d['supplierContact'] as String,
      smsDetails: routeType == RouteType.sms && d['smsDetails'] != null
          ? SmsRateDetails.fromMap(d['smsDetails'] as Map<String, dynamic>)
          : null,
      voiceDetails: routeType == RouteType.voice && d['voiceDetails'] != null
          ? VoiceRateDetails.fromMap(d['voiceDetails'] as Map<String, dynamic>)
          : null,
      qualityNotes: d['qualityNotes'] as String?,
      isPreferred: d['isPreferred'] as bool? ?? false,
      submittedAt: (d['submittedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'requestId': requestId,
    'routeType': routeType.name,
    'supplierName': supplierName,
    'supplierContact': supplierContact,
    'smsDetails': smsDetails?.toMap(),
    'voiceDetails': voiceDetails?.toMap(),
    'qualityNotes': qualityNotes,
    'isPreferred': isPreferred,
    'submittedAt': Timestamp.fromDate(submittedAt),
  };

  SupplierRate copyWith({
    bool? isPreferred,
    String? qualityNotes,
    SmsRateDetails? smsDetails,
    VoiceRateDetails? voiceDetails,
  }) => SupplierRate(
    id: id,
    requestId: requestId,
    routeType: routeType,
    supplierName: supplierName,
    supplierContact: supplierContact,
    smsDetails: smsDetails ?? this.smsDetails,
    voiceDetails: voiceDetails ?? this.voiceDetails,
    qualityNotes: qualityNotes ?? this.qualityNotes,
    isPreferred: isPreferred ?? this.isPreferred,
    submittedAt: submittedAt,
  );
}
