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

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  static Future<UserCredential?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      if (credential.user != null) {
        await _createUserDocument(credential.user!);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(AppHelpers.getFirebaseErrorMessage(e.code));
    }
  }

  // Sign in with email and password
  static Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update FCM token
      if (credential.user != null) {
        await _updateFCMToken(credential.user!.uid);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(AppHelpers.getFirebaseErrorMessage(e.code));
    }
  }

  // Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(AppHelpers.getFirebaseErrorMessage(e.code));
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Create user document in Firestore
  static Future<void> _createUserDocument(User user) async {
    final userModel = UserModel(
      id: user.uid,
      email: user.email!,
      createdAt: DateTime.now(),
      isAdmin: false, // Default to false, can be changed manually in Firestore
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toFirestore());
  }

  // Update FCM token
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

  // Get user data
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
}

// Firestore Service
class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // LEADS OPERATIONS

  // Create lead
  static Future<String> createLead(LeadModel lead) async {
    try {
      final docRef = await _firestore.collection('leads').add(lead.toFirestore());

      // Create activity log for lead creation
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

  // Update lead
  static Future<void> updateLead(String leadId, LeadModel oldLead, LeadModel newLead) async {
    try {
      await _firestore.collection('leads').doc(leadId).update(newLead.toFirestore());

      // Log field changes
      await _logFieldChanges(leadId, oldLead, newLead);
    } catch (e) {
      throw Exception('Failed to update lead: $e');
    }
  }

  // Get user's leads
  static Stream<List<LeadModel>> getUserLeads(String userId) {
    return _firestore
        .collection('leads')
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => LeadModel.fromFirestore(doc))
        .toList());
  }

  // Get all leads (admin only)
  static Stream<List<LeadModel>> getAllLeads() {
    return _firestore
        .collection('leads')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => LeadModel.fromFirestore(doc))
        .toList());
  }

  // Get single lead
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

  // Create activity log
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

  // Get activity logs for a lead
  static Stream<List<ActivityLogModel>> getActivityLogs(String leadId) {
    return _firestore
        .collection('leads')
        .doc(leadId)
        .collection('activity_logs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ActivityLogModel.fromFirestore(doc))
        .toList());
  }

  // Log field changes
  static Future<void> _logFieldChanges(String leadId, LeadModel oldLead, LeadModel newLead) async {
    final String userId = AuthService.currentUser?.uid ?? '';

    // Check each field for changes
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

  // Log call activity
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

  // Create notification
  static Future<void> createNotification(NotificationModel notification) async {
    try {
      await _firestore
          .collection('notifications')
          .add(notification.toFirestore());
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  // Get user notifications
  static Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => NotificationModel.fromFirestore(doc))
        .toList());
  }

  // USER OPERATIONS

  // Get all users (admin only)
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

  // Check if user is admin
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

  // Initialize notifications
  static Future<void> initialize() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  }

  // Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    AppHelpers.debugLog('Foreground message: ${message.notification?.title}');
    // You can show in-app notification here
  }

  // Handle background messages
  static void _handleBackgroundMessage(RemoteMessage message) {
    AppHelpers.debugLog('Background message: ${message.notification?.title}');
    // Handle navigation or other actions
  }

  // Get FCM token
  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}

// Call Service
class CallService {
  // Make phone call
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

  // Send email
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