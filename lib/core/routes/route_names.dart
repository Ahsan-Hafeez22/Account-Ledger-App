abstract final class RouteEndpoints {
  static const String splash = '/';
  static const String intro = '/intro';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String changePassword = '/change-password';
  static const String otpVerification = '/otp-verification';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String account = '/account';
  static const String transaction = '/transaction';
  static const String transactionDetail = '/transaction-detail';
  static const String transactionHistory = '/transaction-history';
  static const String setting = '/setting';
  static const String notifications = '/notifications';
  static const String editProfile = '/edit-profile';
  static const String chat = '/chat';
  static const String chats = '/chats';

  static String transactionDetailPath(String transactionId) =>
      '$transactionDetail/${Uri.encodeComponent(transactionId)}';

  static String chatPath(String partnerId) =>
      '$chat/${Uri.encodeComponent(partnerId)}';
}
