import 'package:google_sign_in/google_sign_in.dart';

import 'package:tudu/models/error.dart';

abstract class SignInGoogleService {
  Future<GoogleSignInAuthentication> signIn();
}

class SignInGoogleServiceImpl extends SignInGoogleService {

  static final SignInGoogleServiceImpl _singleton = SignInGoogleServiceImpl._internal();

  factory SignInGoogleServiceImpl() {
    return _singleton;
  }
  SignInGoogleServiceImpl._internal();

  @override
  Future<GoogleSignInAuthentication> signIn() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw AuthenticationError.userRejected;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    return googleAuth;
  }

}