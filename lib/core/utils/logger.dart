import 'package:logger/logger.dart' as pkg;

final logger = pkg.Logger(
  printer: pkg.PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
  ),
);
void log(String tag, String message) {
  logger.d("[$tag] $message");
}


/*

logger.d("Debug message");
logger.i("Info message");
logger.w("Warning message");
logger.e("Error message");


try {
  // some code
} catch (e, stackTrace) {
  logger.e("Something failed", error: e, stackTrace: stackTrace);
}
*/