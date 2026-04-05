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

  // // Dashboard
  // static const String balance = '/dashboard/balance';
  // static const String spendingCategories = '/dashboard/spending-categories';
  // static const String upcomingBills = '/dashboard/upcoming-bills';
  // static const String aiInsights = '/dashboard/ai-insights';

  // // Transactions
  // static const String transactions = '/transactions';
  // static String transactionById(String id) => '/transactions/$id';

  // // Analytics
  // static const String analyticsSummary = '/analytics/summary';
  // static const String categorySpending = '/analytics/category-spending';
  // static const String savingsTrend = '/analytics/savings-trend';

  // // Profile
  // static const String profile = '/profile';
  // static const String updateProfile = '/profile/update';
}
