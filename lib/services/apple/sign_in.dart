// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/utils/crypto.dart';

// abstract class SignInWithAppleService {
//   Future<AuthorizationCredentialAppleID> signInWithApple(String rawNonce);
// }
//
// class SignInWithAppleServiceImpl extends SignInWithAppleService {
//
//   static final SignInWithAppleServiceImpl _singleton = SignInWithAppleServiceImpl._internal();
//
//   factory SignInWithAppleServiceImpl() {
//     return _singleton;
//   }
//   SignInWithAppleServiceImpl._internal();
//
//   @override
//   Future<AuthorizationCredentialAppleID> signInWithApple(String rawNonce) async {
//     // final rawNonce = generateNonce();
//     final nonce = sha256ofString(rawNonce);
//
//     // Request credential for the currently signed in Apple account.
//
//     try {
//       final appleCredential = await SignInWithApple.getAppleIDCredential(
//         scopes: [
//           AppleIDAuthorizationScopes.email,
//           AppleIDAuthorizationScopes.fullName,
//         ],
//         nonce: nonce,
//       );
//       return appleCredential;
//     } on SignInWithAppleAuthorizationException catch (e) {
//       print(e);
//       throw AuthenticationError.appleException(e.message, {
//         "code": e.code,
//       });
//     } catch (e) {
//       print(e);
//       throw CommonError.serverError;
//     }
//   }
//
// }