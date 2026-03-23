import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract interface class InternetChecker {
  Future<bool> get isConnected;
}

class InternetCheckerImpl implements InternetChecker {
  final InternetConnection internetConnection;
  InternetCheckerImpl(this.internetConnection);
  @override
  Future<bool> get isConnected async {
    return await internetConnection.hasInternetAccess;
  }
}
