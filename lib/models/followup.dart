import 'package:cloud_firestore/cloud_firestore.dart';

enum FollowupType { customerCheck, trafficStability }

enum FollowupStatus { pending, overdue, completed }

enum FollowupAction {
  trafficStarted,
  customerTesting,
  noFeedbackYet,
  customerRejected,
  rescheduled,
}

enum NoTrafficReason {
  rateTooHigh,
  qualityConcern,
  customerDisappeared,
  supplierIssue,
  unknown,
}

String _n(Enum e) => e.toString().split('.').last;

class Followup {
  final String id;
  final String requestId;
  final String customerName; // denormalised for display
  final FollowupType type;
  final DateTime scheduledAt;
  final FollowupStatus status;
  final FollowupAction? lastAction;
  final NoTrafficReason? noTrafficReason;
  final String? notes;
  final DateTime createdAt;

  const Followup({
    required this.id,
    required this.requestId,
    required this.customerName,
    required this.type,
    required this.scheduledAt,
    required this.status,
    this.lastAction,
    this.noTrafficReason,
    this.notes,
    required this.createdAt,
  });

  bool get isOverdue => status == FollowupStatus.overdue;
  bool get isToday {
    final now = DateTime.now();
    return scheduledAt.year == now.year &&
        scheduledAt.month == now.month &&
        scheduledAt.day == now.day &&
        status == FollowupStatus.pending;
  }

  factory Followup.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Followup(
      id: doc.id,
      requestId: d['requestId'] as String,
      customerName: d['customerName'] as String,
      type: FollowupType.values.byName(d['type'] as String),
      scheduledAt: (d['scheduledAt'] as Timestamp).toDate(),
      status: FollowupStatus.values.byName(d['status'] as String),
      lastAction: d['lastAction'] != null
          ? FollowupAction.values.byName(d['lastAction'] as String)
          : null,
      noTrafficReason: d['noTrafficReason'] != null
          ? NoTrafficReason.values.byName(d['noTrafficReason'] as String)
          : null,
      notes: d['notes'] as String?,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'requestId': requestId,
    'customerName': customerName,
    'type': _n(type),
    'scheduledAt': Timestamp.fromDate(scheduledAt),
    'status': _n(status),
    'lastAction': lastAction != null ? _n(lastAction!) : null,
    'noTrafficReason': noTrafficReason != null ? _n(noTrafficReason!) : null,
    'notes': notes,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  Followup copyWith({
    DateTime? scheduledAt,
    FollowupStatus? status,
    FollowupAction? lastAction,
    NoTrafficReason? noTrafficReason,
    String? notes,
  }) => Followup(
    id: id,
    requestId: requestId,
    customerName: customerName,
    type: type,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    status: status ?? this.status,
    lastAction: lastAction ?? this.lastAction,
    noTrafficReason: noTrafficReason ?? this.noTrafficReason,
    notes: notes ?? this.notes,
    createdAt: createdAt,
  );
}
