import 'package:intl/intl.dart';

// Input Validators
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }
}

// App Constants - Updated (removed dynamic fields)
class AppConstants {
  // Call Outcomes
  static const List<String> callOutcomes = [
    'Interested',
    'Not Interested',
    'Call Back Later',
    'Wrong Number',
    'No Answer',
    'Busy',
    'Voicemail',
    'Meeting Scheduled',
  ];

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd/MM/yyyy hh:mm a';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;

  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Check your internet connection.';
  static const String authError = 'Authentication failed. Please try again.';
}

// Helper Functions
class AppHelpers {
  // Date Formatting
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat(AppConstants.timeFormat).format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat(AppConstants.dateTimeFormat).format(date);
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Text Utilities
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String initials(String name) {
    if (name.isEmpty) return '';
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  // Phone Utilities
  static String formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length == 10) {
      // Format as (XXX) XXX-XXXX
      return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
    } else if (digitsOnly.length == 11 && digitsOnly.startsWith('1')) {
      // Format as +1 (XXX) XXX-XXXX
      return '+1 (${digitsOnly.substring(1, 4)}) ${digitsOnly.substring(4, 7)}-${digitsOnly.substring(7)}';
    }

    return phone; // Return original if no standard format matches
  }

  // Color Utilities
  static String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'untouched lead':
        return '#2196F3'; // Blue
      case 'site visit follow-up':
        return '#FF9800'; // Orange
      case 'site visit completed':
        return '#4CAF50'; // Green
      case 'not interested':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  // Validation Utilities
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length >= 10 && digitsOnly.length <= 15;
  }

  // URL Utilities
  static String getCallUrl(String phoneNumber) {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    return 'tel:$cleanPhone';
  }

  static String getEmailUrl(String email) {
    return 'mailto:$email';
  }

  // Search Utilities
  static bool matchesSearch(String text, String query) {
    if (query.isEmpty) return true;
    return text.toLowerCase().contains(query.toLowerCase());
  }

  // List Utilities
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  // Error Handling
  static String getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return AppConstants.genericError;
    }
  }

  // Permission Utilities
  static bool canEditLead(String currentUserId, String leadUserId, bool isAdmin) {
    return isAdmin || currentUserId == leadUserId;
  }

  static bool canDeleteLead(bool isAdmin) {
    return isAdmin; // Only admins can delete (per MVP spec, users cannot delete)
  }

  // Debug Utilities
  static void debugLog(String message) {
    // Only log in debug mode
    assert(() {
      print('🐛 [DEBUG] $message');
      return true;
    }());
  }
}