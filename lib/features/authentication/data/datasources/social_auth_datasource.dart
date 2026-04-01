import 'package:account_ledger/core/error/exceptions.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

bool _isGoogleSignInDeveloperError(Object e) {
  if (e is! PlatformException || e.code != 'sign_in_failed') return false;
  final msg = e.message ?? '';
  return msg.contains('ApiException: 10') || msg.contains('10:');
}

const String _googleDeveloperErrorMessage =
    'Google Sign-In error 10: use the Web application OAuth client ID as serverClientId (not the Android client). Your app package name + SHA-1 must be on the Android OAuth client in the same Google Cloud project.';

class SocialAuthData {
  final String provider; // 'google'
  final String idToken; // Google ID token (JWT)

  const SocialAuthData({required this.provider, required this.idToken});

  Map<String, dynamic> toJson() {
    return {'provider': provider, 'idToken': idToken};
  }
}

abstract interface class SocialAuthDataSource {
  Future<SocialAuthData> signInWithGoogle();

  Future<void> signOut();
}

class SocialAuthDataSourceImpl implements SocialAuthDataSource {
  final GoogleSignIn _googleSignIn;

  SocialAuthDataSourceImpl({GoogleSignIn? googleSignIn})
    : _googleSignIn =
          googleSignIn ?? GoogleSignIn(scopes: ['email', 'profile']);

  @override
  Future<SocialAuthData> signInWithGoogle() async {
    try {
      // Step 1: let user pick Google account (ApiException 10 often surfaces here)
      final GoogleSignInAccount? googleUser;
      try {
        googleUser = await _googleSignIn.signIn();
      } catch (e) {
        if (e is AppException) rethrow;
        if (_isGoogleSignInDeveloperError(e)) {
          throw AuthException(
            message: _googleDeveloperErrorMessage,
            code: 'developer-error',
            details: e.toString(),
          );
        }
        throw ServerException(
          message: 'Google sign-in failed: $e',
          code: 'google-sign-in-error',
          details: e.toString(),
        );
      }

      if (googleUser == null) {
        throw const CancelledException(
          message: 'Google sign-in cancelled by user',
          code: 'sign-in-cancelled',
        );
      }

      // Step 2: get authentication tokens (can throw if serverClientId missing on mobile)
      GoogleSignInAuthentication googleAuth;
      try {
        googleAuth = await googleUser.authentication;
      } catch (e) {
        if (e is AppException) rethrow;
        // ApiException: 10 = DEVELOPER_ERROR: wrong SHA-1 or OAuth client config in Google Cloud
        if (_isGoogleSignInDeveloperError(e)) {
          throw AuthException(
            message: _googleDeveloperErrorMessage,
            code: 'developer-error',
            details: e.toString(),
          );
        }
        throw ServerException(
          message: 'Google sign-in failed: $e',
          code: 'google-auth-error',
          details: e.toString(),
        );
      }

      if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
        throw const AuthException(
          message:
              'Google sign-in failed: No idToken. On Android/iOS, add serverClientId (Web client ID from Google Cloud) to GoogleSignIn.',
          code: 'no-id-token',
        );
      }

      // Step 3: create simple auth data with idToken + userType
      return SocialAuthData(provider: 'google', idToken: googleAuth.idToken!);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(
        message: 'Google sign-in failed: $e',
        code: 'google-sign-in-error',
        details: e.toString(),
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      throw ServerException(message: 'Sign out failed', details: e.toString());
    }
  }
}
