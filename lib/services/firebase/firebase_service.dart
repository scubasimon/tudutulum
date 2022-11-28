import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/generated/l10n.dart';

abstract class FirebaseService {
  Future<UserCredential> signUp(String email, String password);

  Future<UserCredential> signIn(String email, String password);

  Future<UserCredential> signInWithGoogle(GoogleSignInAuthentication googleAuth);

  // Future<UserCredential> signInWithApple(AuthorizationCredentialAppleID appleCredential, String rawNonce);

  Future<UserCredential> signInWithFacebook(LoginResult loginResult);

  Future<void> addUser(String userId, Map<String, dynamic> data);

  Future<bool> userExists(String userId);

  Future<User?> authChanged();
}

class FirebaseServiceImpl extends FirebaseService {

  static final FirebaseServiceImpl _singleton = FirebaseServiceImpl._internal();

  factory FirebaseServiceImpl() {
    return _singleton;
  }
  FirebaseServiceImpl._internal();

  @override
  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await FirebaseAuth
          .instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print(e);
      var error = "Bad credentials";
      if (e.code == "weak-password") {
        error = S.current.password_too_weak_error;
      } else if (e.code == "email-already-in-use") {
        error = S.current.account_already_exists_error;
      }
      throw AuthenticationError.badCredentials({
        "error": error
      });
    } catch (e) {
      print(e);
      throw CommonError.serverError;
    }
  }

  @override
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await FirebaseAuth
          .instance
          .signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw AuthenticationError
          .badCredentials({
        "error": e.toString(),
      });
    }
  }

  @override
  Future<UserCredential> signInWithGoogle(GoogleSignInAuthentication googleAuth) async {
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _signInWith(credential);
  }

  // @override
  // Future<UserCredential> signInWithApple(AuthorizationCredentialAppleID appleCredential, String rawNonce) async {
  //   final oauthCredential = OAuthProvider("apple.com").credential(
  //     idToken: appleCredential.identityToken,
  //     rawNonce: rawNonce,
  //   );
  //   return _signInWith(oauthCredential);
  // }

  @override
  Future<UserCredential> signInWithFacebook(LoginResult loginResult) {
    var facebookAuthCredential = FacebookAuthProvider
        .credential(loginResult.accessToken!.token);
    return _signInWith(facebookAuthCredential);
  }

  @override
  Future<void> addUser(String userId, Map<String, dynamic> data) async {
    try {
      return await FirebaseFirestore
          .instance
          .collection("users")
          .doc(userId)
          .set(data);
    } catch (e) {
      print(e);
      throw CommonError.serverError;
    }
  }

  @override
  Future<User?> authChanged() async {
    var completer = Completer<User?>();
    FirebaseAuth
        .instance
        .authStateChanges()
        .listen((user) {
          completer.complete(user);
        });
    return completer.future;
  }

  @override
  Future<bool> userExists(String userId) async {
    try {
      var result = await FirebaseFirestore
          .instance
          .collection("users")
          .doc(userId)
          .get();
      return result.exists;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<UserCredential> _signInWith(AuthCredential authCredential) async {
    try {
      return await FirebaseAuth.instance.signInWithCredential(authCredential);
    }  on FirebaseAuthException catch (e) {
      print(e);
      throw AuthenticationError.badCredentials({
        "error": e.message
      });
    } catch (e) {
      print(e);
      throw CommonError.serverError;
    }
  }

}