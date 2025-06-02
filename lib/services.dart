import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models.dart';
import 'utils.dart';

// Authentication Service
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _createUserDocument(credential.user!);
        await _initializeDefaultCustomFields();
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(AppHelpers.getFirebaseErrorMessage(e.code));
    }
  }

  static Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _updateFCMToken(credential.user!.uid);
        await _initializeDefaultCustomFields();
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(AppHelpers.getFirebaseErrorMessage(e.code));
    }
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(AppHelpers.getFirebaseErrorMessage(e.code));
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static Future<void> _createUserDocument(User user) async {
    final userModel = UserModel(
      id: user.uid,
      email: user.email!,
      createdAt: DateTime.now(),
      isAdmin: false,
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toFirestore());
  }

  static Future<void> _updateFCMToken(String userId) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': fcmToken,
        });
      }
    } catch (e) {
      AppHelpers.debugLog('Error updating FCM token: $e');
    }
  }

  static Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (e) {
      AppHelpers.debugLog('Error getting user data: $e');
    }
    return null;
  }

  // Initialize default custom fields - NEW
  static Future<void> _initializeDefaultCustomFields() async {
    try {
      // Check if fields already exist
      final existingSources = await _firestore
          .collection('custom_fields')
          .where('type', isEqualTo: 'source')
          .limit(1)
          .get();

      if (existingSources.docs.isEmpty) {
        // Create default sources
        final defaultSources = ['Facebook', 'Google', 'Reference', 'Other'];
        for (final source in defaultSources) {
          final field = CustomFieldModel(
            id: '',
            name: source,
            type: CustomFieldType.source,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _firestore.collection('custom_fields').add(field.toFirestore());
        }

        // Create default projects
        final defaultProjects = ['Villas', 'Apartments', 'Open Plots', 'Investment'];
        for (final project in defaultProjects) {
          final field = CustomFieldModel(
            id: '',
            name: project,
            type: CustomFieldType.project,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _firestore.collection('custom_fields').add(field.toFirestore());
        }

        // Create default statuses
        final defaultStatuses = [
          'Untouched Lead',
          'Site Visit Follow-up',
          'Site Visit Completed',
          'Not Interested'
        ];
        for (final status in defaultStatuses) {
          final field = CustomFieldModel(
            id: '',
            name: status,
            type: CustomFieldType.status,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _firestore.collection('custom_fields').add(field.toFirestore());
        }
      }
    } catch (e) {
      AppHelpers.debugLog('Error initializing default custom fields: $e');
    }
  }
}

// Firestore Service
class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CUSTOM FIELDS OPERATIONS - NEW

  static Stream<List<CustomFieldModel>> getCustomFields(CustomFieldType type) {
    return _firestore
        .collection('custom_fields')
        .where('type', isEqualTo: type.name)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CustomFieldModel.fromFirestore(doc))
        .toList());
  }

  static Future<void> createCustomField(CustomFieldModel field) async {
    try {
      await _firestore.collection('custom_fields').add(field.toFirestore());
    } catch (e) {
      throw Exception('Failed to create custom field: $e');
    }
  }

  static Future<void> updateCustomField(String fieldId, String newName) async {
    try {
      await _firestore.collection('custom_fields').doc(fieldId).update({
        'name': newName,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update custom field: $e');
    }
  }

  // LEADS OPERATIONS

  static Future<String> createLead(LeadModel lead) async {
    try {
      final docRef = await _firestore.collection('leads').add(lead.toFirestore());

      await _createActivityLog(
        ActivityLogModel.leadCreated(
          leadId: docRef.id,
          userId: lead.userId,
          leadName: lead.name,
        ),
      );

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create lead: $e');
    }
  }

  static Future<void> updateLead(String leadId, LeadModel oldLead, LeadModel newLead) async {
    try {
      await _firestore.collection('leads').doc(leadId).update(newLead.toFirestore());
      await _logFieldChanges(leadId, oldLead, newLead);
    } catch (e) {
      throw Exception('Failed to update lead: $e');
    }
  }

  static Stream<List<LeadModel>> getUserLeads(String userId) {
    return _firestore
        .collection('leads')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final leads = snapshot.docs
          .map((doc) => LeadModel.fromFirestore(doc))
          .toList();
      leads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return leads;
    });
  }

  static Stream<List<LeadModel>> getAllLeads() {
    return _firestore
        .collection('leads')
        .snapshots()
        .map((snapshot) {
      final leads = snapshot.docs
          .map((doc) => LeadModel.fromFirestore(doc))
          .toList();
      leads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return leads;
    });
  }

  static Future<LeadModel?> getLead(String leadId) async {
    try {
      final doc = await _firestore.collection('leads').doc(leadId).get();
      if (doc.exists) {
        return LeadModel.fromFirestore(doc);
      }
    } catch (e) {
      AppHelpers.debugLog('Error getting lead: $e');
    }
    return null;
  }

  // ACTIVITY LOG OPERATIONS

  static Future<void> _createActivityLog(ActivityLogModel log) async {
    try {
      await _firestore
          .collection('leads')
          .doc(log.leadId)
          .collection('activity_logs')
          .add(log.toFirestore());
    } catch (e) {
      AppHelpers.debugLog('Error creating activity log: $e');
    }
  }

  static Stream<List<ActivityLogModel>> getActivityLogs(String leadId) {
    return _firestore
        .collection('leads')
        .doc(leadId)
        .collection('activity_logs')
        .snapshots()
        .map((snapshot) {
      final logs = snapshot.docs
          .map((doc) => ActivityLogModel.fromFirestore(doc))
          .toList();
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return logs;
    });
  }

  static Future<void> _logFieldChanges(String leadId, LeadModel oldLead, LeadModel newLead) async {
    final String userId = AuthService.currentUser?.uid ?? '';

    if (oldLead.name != newLead.name) {
      await _createActivityLog(ActivityLogModel.fieldUpdated(
        leadId: leadId,
        userId: userId,
        fieldName: 'Name',
        oldValue: oldLead.name,
        newValue: newLead.name,
      ));
    }

    if (oldLead.phone != newLead.phone) {
      await _createActivityLog(ActivityLogModel.fieldUpdated(
        leadId: leadId,
        userId: userId,
        fieldName: 'Phone',
        oldValue: oldLead.phone,
        newValue: newLead.phone,
      ));
    }

    if (oldLead.email != newLead.email) {
      await _createActivityLog(ActivityLogModel.fieldUpdated(
        leadId: leadId,
        userId: userId,
        fieldName: 'Email',
        oldValue: oldLead.email,
        newValue: newLead.email,
      ));
    }

    if (oldLead.source != newLead.source) {
      await _createActivityLog(ActivityLogModel.fieldUpdated(
        leadId: leadId,
        userId: userId,
        fieldName: 'Source',
        oldValue: oldLead.source,
        newValue: newLead.source,
      ));
    }

    if (oldLead.project != newLead.project) {
      await _createActivityLog(ActivityLogModel.fieldUpdated(
        leadId: leadId,
        userId: userId,
        fieldName: 'Project',
        oldValue: oldLead.project,
        newValue: newLead.project,
      ));
    }

    if (oldLead.status != newLead.status) {
      await _createActivityLog(ActivityLogModel.statusChanged(
        leadId: leadId,
        userId: userId,
        oldStatus: oldLead.status,
        newStatus: newLead.status,
      ));
    }

    if (oldLead.remarks != newLead.remarks) {
      await _createActivityLog(ActivityLogModel.fieldUpdated(
        leadId: leadId,
        userId: userId,
        fieldName: 'Remarks',
        oldValue: oldLead.remarks,
        newValue: newLead.remarks,
      ));
    }

    if (oldLead.followUp != newLead.followUp) {
      await _createActivityLog(ActivityLogModel.reminderSet(
        leadId: leadId,
        userId: userId,
        reminderDate: newLead.followUp ?? DateTime.now(),
      ));
    }
  }

  static Future<void> logCallActivity({
    required String leadId,
    required String outcome,
    required String notes,
  }) async {
    final userId = AuthService.currentUser?.uid ?? '';

    await _createActivityLog(ActivityLogModel.callMade(
      leadId: leadId,
      userId: userId,
      outcome: outcome,
      notes: notes,
    ));
  }

  // NOTIFICATION OPERATIONS

  static Future<void> createNotification(NotificationModel notification) async {
    try {
      await _firestore
          .collection('notifications')
          .add(notification.toFirestore());
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  static Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final notifications = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
      notifications.sort((a, b) => b.sentAt.compareTo(a.sentAt));
      return notifications;
    });
  }

  // USER OPERATIONS

  static Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  static Future<bool> isUserAdmin(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['isAdmin'] ?? false;
      }
    } catch (e) {
      AppHelpers.debugLog('Error checking admin status: $e');
    }
    return false;
  }
}

// Notification Service
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    AppHelpers.debugLog('Foreground message: ${message.notification?.title}');
  }

  static void _handleBackgroundMessage(RemoteMessage message) {
    AppHelpers.debugLog('Background message: ${message.notification?.title}');
  }

  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}

// Call Service
class CallService {
  static Future<bool> makeCall(String phoneNumber) async {
    try {
      final url = AppHelpers.getCallUrl(phoneNumber);
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
      return false;
    } catch (e) {
      AppHelpers.debugLog('Error making call: $e');
      return false;
    }
  }

  static Future<bool> sendEmail(String email) async {
    try {
      final url = AppHelpers.getEmailUrl(email);
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
      return false;
    } catch (e) {
      AppHelpers.debugLog('Error sending email: $e');
      return false;
    }
  }
}