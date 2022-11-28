import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:tudu/models/error.dart';

abstract class SignInWithFacebookService {
  Future<LoginResult> signIn();
}

class SignInWithFacebookServiceImpl extends SignInWithFacebookService {

  static final SignInWithFacebookServiceImpl _singleton = SignInWithFacebookServiceImpl._internal();

  factory SignInWithFacebookServiceImpl() {
    return _singleton;
  }
  SignInWithFacebookServiceImpl._internal();

  @override
  Future<LoginResult> signIn() async {
    try {
      return await FacebookAuth.instance.login();
    } catch (e) {
      print(e);
      throw CustomError("-1");
    }
  }

}