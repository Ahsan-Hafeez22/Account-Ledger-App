import 'package:flutter/material.dart';
import 'package:account_ledger/app.dart';
import 'package:account_ledger/core/dependency_injection/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServiceLocator();
  runApp(const AccountLedger());
}
