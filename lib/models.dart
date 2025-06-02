import 'package:cloud_firestore/cloud_firestore.dart';

// User Model
class UserModel {
  final String id;
  final String email;
  final String? fcmToken;
  final DateTime createdAt;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.email,
    this.fcmToken,
    required this.createdAt,
    this.isAdmin = false,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      fcmToken: data['fcmToken'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAdmin': isAdmin,
    };
  }
}

// Custom Field Model - NEW
class CustomFieldModel {
  final String id;
  final String name;
  final CustomFieldType type;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomFieldModel({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomFieldModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomFieldModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: CustomFieldType.values.firstWhere(
            (e) => e.name == data['type'],
        orElse: () => CustomFieldType.source,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CustomFieldModel copyWith({
    String? name,
    DateTime? updatedAt,
  }) {
    return CustomFieldModel(
      id: id,
      name: name ?? this.name,
      type: type,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

// Custom Field Type Enum - NEW
enum CustomFieldType {
  source('Source'),
  project('Project'),
  status('Status');

  const CustomFieldType(this.displayName);
  final String displayName;
}

// Lead Model - Updated to use custom fields
class LeadModel {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String email;
  final String source;
  final String project;
  final String status; // Changed from LeadStatus enum to String
  final String remarks;
  final DateTime? followUp;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeadModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.email,
    required this.source,
    required this.project,
    required this.status,
    required this.remarks,
    this.followUp,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeadModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeadModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      source: data['source'] ?? '',
      project: data['project'] ?? '',
      status: data['status'] ?? 'Untouched Lead',
      remarks: data['remarks'] ?? '',
      followUp: data['followUp'] != null
          ? (data['followUp'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'source': source,
      'project': project,
      'status': status,
      'remarks': remarks,
      'followUp': followUp != null ? Timestamp.fromDate(followUp!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  LeadModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? source,
    String? project,
    String? status,
    String? remarks,
    DateTime? followUp,
    DateTime? updatedAt,
  }) {
    return LeadModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      source: source ?? this.source,
      project: project ?? this.project,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      followUp: followUp ?? this.followUp,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

// Legacy Lead Status Enum - Keep for backward compatibility
enum LeadStatus {
  new_lead('Untouched Lead'),
  contacted('Site Visit Follow-up'),
  qualified('Site Visit Completed'),
  proposal_sent('Proposal Sent'),
  negotiation('Negotiation'),
  closed_won('Closed Won'),
  closed_lost('Not Interested'),
  follow_up('Follow Up');

  const LeadStatus(this.displayName);
  final String displayName;
}

// Activity Log Model
class ActivityLogModel {
  final String id;
  final String leadId;
  final String userId;
  final ActivityType actionType;
  final String description;
  final Map<String, dynamic>? details;
  final DateTime timestamp;

  ActivityLogModel({
    required this.id,
    required this.leadId,
    required this.userId,
    required this.actionType,
    required this.description,
    this.details,
    required this.timestamp,
  });

  factory ActivityLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityLogModel(
      id: doc.id,
      leadId: data['leadId'] ?? '',
      userId: data['userId'] ?? '',
      actionType: ActivityType.values.firstWhere(
            (e) => e.name == data['actionType'],
        orElse: () => ActivityType.edit,
      ),
      description: data['description'] ?? '',
      details: data['details'] as Map<String, dynamic>?,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'leadId': leadId,
      'userId': userId,
      'actionType': actionType.name,
      'description': description,
      'details': details,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory ActivityLogModel.leadCreated({
    required String leadId,
    required String userId,
    required String leadName,
  }) {
    return ActivityLogModel(
      id: '',
      leadId: leadId,
      userId: userId,
      actionType: ActivityType.created,
      description: 'Lead "$leadName" was created',
      timestamp: DateTime.now(),
    );
  }

  factory ActivityLogModel.fieldUpdated({
    required String leadId,
    required String userId,
    required String fieldName,
    required String oldValue,
    required String newValue,
  }) {
    return ActivityLogModel(
      id: '',
      leadId: leadId,
      userId: userId,
      actionType: ActivityType.edit,
      description: '$fieldName updated',
      details: {
        'field': fieldName,
        'oldValue': oldValue,
        'newValue': newValue,
      },
      timestamp: DateTime.now(),
    );
  }

  factory ActivityLogModel.statusChanged({
    required String leadId,
    required String userId,
    required String oldStatus,
    required String newStatus,
  }) {
    return ActivityLogModel(
      id: '',
      leadId: leadId,
      userId: userId,
      actionType: ActivityType.status_change,
      description: 'Status changed from $oldStatus to $newStatus',
      details: {
        'oldStatus': oldStatus,
        'newStatus': newStatus,
      },
      timestamp: DateTime.now(),
    );
  }

  factory ActivityLogModel.callMade({
    required String leadId,
    required String userId,
    required String outcome,
    required String notes,
  }) {
    return ActivityLogModel(
      id: '',
      leadId: leadId,
      userId: userId,
      actionType: ActivityType.call,
      description: 'Call made - $outcome',
      details: {
        'outcome': outcome,
        'notes': notes,
      },
      timestamp: DateTime.now(),
    );
  }

  factory ActivityLogModel.reminderSet({
    required String leadId,
    required String userId,
    required DateTime reminderDate,
  }) {
    return ActivityLogModel(
      id: '',
      leadId: leadId,
      userId: userId,
      actionType: ActivityType.reminder,
      description: 'Follow-up reminder set for ${_formatDateTime(reminderDate)}',
      details: {
        'reminderDate': reminderDate.toIso8601String(),
      },
      timestamp: DateTime.now(),
    );
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Activity Type Enum
enum ActivityType {
  created('Created'),
  edit('Edit'),
  status_change('Status Change'),
  call('Call'),
  reminder('Reminder'),
  note('Note');

  const ActivityType(this.displayName);
  final String displayName;
}

// Notification Model
class NotificationModel {
  final String id;
  final String? userId; // null for broadcast notifications
  final List<String>? sentTo; // for broadcast notifications
  final String title;
  final String message;
  final NotificationType type;
  final DateTime sentAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    this.userId,
    this.sentTo,
    required this.title,
    required this.message,
    required this.type,
    required this.sentAt,
    this.isRead = false,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'],
      sentTo: data['sentTo'] != null ? List<String>.from(data['sentTo']) : null,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: NotificationType.values.firstWhere(
            (e) => e.name == data['type'],
        orElse: () => NotificationType.reminder,
      ),
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'sentTo': sentTo,
      'title': title,
      'message': message,
      'type': type.name,
      'sentAt': Timestamp.fromDate(sentAt),
      'isRead': isRead,
    };
  }
}

// Notification Type Enum
enum NotificationType {
  reminder('Reminder'),
  broadcast('Broadcast'),
  system('System');

  const NotificationType(this.displayName);
  final String displayName;
}