import 'package:account_ledger/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:account_ledger/app.dart';
import 'package:account_ledger/core/dependency_injection/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await initServiceLocator();
    runApp(const AccountLedger());
  } catch (e) {
    debugPrint("Initialization error: $e");
  }
}
