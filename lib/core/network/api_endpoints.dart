abstract final class ApiEndpoints {
  // Auth
  static const String googleWebClientId =
      '782026035417-d7qje8jmfqgti1hgjfh93v6k827sqtni.apps.googleusercontent.com';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String googleAuth = '/auth/google-auth';
  static const String getUser = '/auth/user';
  static const String refreshToken = '/auth/refresh-token';
  static const String deleteAccount = '/auth/delete-user';
  static const String resendOtp = '/auth/resend-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String verifyResetOtp = '/auth/verify-reset-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String registerDevice = '/auth/register-device';

  // Notification
  static const String getNotification = '/notifications/get-notification';
  static String markNotificationRead(String notificationId) =>
      '/notifications/${Uri.encodeComponent(notificationId)}/read';
  static const String markAllNotificationsRead =
      '/notifications/mark-all-as-read';
  static const String unreadNotificationCount =
      '/notifications/unread-notifications';
  static const String deleteManyNotifications =
      '/notifications/delete-many-notification';
  static String deleteNotification(String notificationId) =>
      '/notifications/${Uri.encodeComponent(notificationId)}';

  // Account
  static const String createAccount = '/account/create-account';
  static const String getAccount = '/account/account';
  static String changeAccountStatus(String status) =>
      '/account/change-account-status/${Uri.encodeComponent(status)}';
  static const String changePin = '/account/change-pin';

  // Transaction (mount should match server, e.g. app.use('/api/transaction', router))
  static const String createTransaction = '/transaction/create-transaction';
  static String getTransactionDetail(String transactionId) =>
      '/transaction/${Uri.encodeComponent(transactionId)}';
  static const String listTransactions = '/transaction/transactions';
  static const String checkTransactionStatus = '/transaction/check-status';
  static const String verifyPin = '/transaction/verify-pin';
}
