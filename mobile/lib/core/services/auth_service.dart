import 'package:google_sign_in/google_sign_in.dart';

/// Centralized Authentication Service for handling Google OAuth sessions.
class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  static const String serverClientId =
      '1047047792857-idood18l4f3m7lpr4klqedl0rid9dm6c.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: serverClientId,
    scopes: ['email', 'profile'],
  );

  GoogleSignIn get googleSignIn => _googleSignIn;

  /// Sign in with Google.
  /// Calls [signOut] first to ensure that any cached session or default account
  /// is reset so Google Play Services / iOS will prompt the user to pick an account
  /// rather than automatically logging into the previous account.
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore if no user was previously signed in or if platform throws
    }
    return await _googleSignIn.signIn();
  }

  /// Explicitly signs out the user from Google Sign-In.
  /// Resets the current user session so subsequent logins trigger the account chooser.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore errors during sign-out
    }
  }
}
