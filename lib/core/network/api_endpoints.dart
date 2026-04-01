abstract final class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String googleAuth = '/auth/googleAuth';

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
