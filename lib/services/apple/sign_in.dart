import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/utils/crypto.dart';
import 'package:tudu/generated/l10n.dart';

abstract class SignInWithAppleService {
  Future<AuthorizationCredentialAppleID> signInWithApple(String rawNonce);
}

class SignInWithAppleServiceImpl extends SignInWithAppleService {

  static final SignInWithAppleServiceImpl _singleton = SignInWithAppleServiceImpl._internal();

  factory SignInWithAppleServiceImpl() {
    return _singleton;
  }
  SignInWithAppleServiceImpl._internal();

  @override
  Future<AuthorizationCredentialAppleID> signInWithApple(String rawNonce) async {
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      return appleCredential;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw AuthenticationError.appleException(S.current.user_not_approved_error, {
          "error": e,
        });
      } else {
        print(e);
        throw AuthenticationError.appleException(S.current.server_error, {
          "error": e,
        });
      }
    } catch (e) {
      throw CommonError.serverError;
    }
  }

}