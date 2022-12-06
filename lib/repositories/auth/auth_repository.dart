import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tudu/models/auth.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/services/apple/sign_in.dart';
import 'package:tudu/services/facebook/sign_in.dart';
import 'package:tudu/services/firebase/firebase_service.dart';
import 'package:tudu/models/user.dart';
import 'package:tudu/services/google/sign_in.dart';

abstract class AuthRepository {
  Future<void> signUp(Authentication authentication);

  Future<void> signIn(Authentication authentication);

  Future<void> sendPasswordResetEmail(String email);

  Future<Profile> getCurrentUser();

  Future<void> changeEmail(String email);

  Future<void> updateProfile(Profile profile);

  Future<void> signOut();

  Future<void> changePassword(String newPassword);

  Future<void> deleteAccount();
}

class AuthRepositoryImpl extends AuthRepository {

  final FirebaseService _firebaseService = FirebaseServiceImpl();
  final SignInGoogleService _signInGoogleService = SignInGoogleServiceImpl();
  final SignInWithAppleService _signInWithAppleService = SignInWithAppleServiceImpl();
  final SignInWithFacebookService _signInWithFacebookService = SignInWithFacebookServiceImpl();

  @override
  Future<void> signUp(Authentication authentication) async {
    if (authentication.type != AuthType.email) {
      throw CustomError("-1", message: "Authenticate not support");
    }
    if (authentication.email == null || authentication.password == null) {
      throw CustomError("-1", message: "Sign up with email requires email and password");
    }

    var userCredentials = await _firebaseService.signUp(authentication.email!, authentication.password!);

    if (userCredentials.user == null && userCredentials.additionalUserInfo == null) {
      throw AuthenticationError.badCredentials({});
    }

    String? firstName, familyName;
    if (authentication.name != null) {
      var array = authentication.name!.split(" ");
      if (array.length == 1) {
        firstName = authentication.name;
      } else if (array.length == 2) {
        firstName = array[0];
        familyName = array[1];
      } else {
        firstName = array[0];
        array.removeAt(0);
        familyName = array.join(" ");
      }
    }

    var user = Profile(
      userCredentials.user!.uid,
      userCredentials.additionalUserInfo!.providerId!,
      email: authentication.email,
      firstName: firstName,
      familyName: familyName,
      telephone: authentication.phone,
    );
    return _firebaseService
        .addUser(userCredentials.user!.uid, user.toJson());
  }

  @override
  Future<void> signIn(Authentication authentication) async {
    UserCredential? userCredentials;
    switch (authentication.type) {
      case AuthType.email:
        if (authentication.email == null || authentication.password == null) {
          throw CustomError("-1", message: "Sign in with email requires email and password");
        }
         userCredentials = await _firebaseService
            .signIn(authentication.email!, authentication.password!);
        break;
      case AuthType.google:
        var googleAuth = await _signInGoogleService.signIn();
        userCredentials = await _firebaseService.signInWithGoogle(googleAuth);
        break;
      case AuthType.apple:
        var rawNonce = generateNonce();
        var appleAuth = await _signInWithAppleService.signInWithApple(rawNonce);
        userCredentials = await _firebaseService.signInWithApple(appleAuth, rawNonce);
        break;
      case AuthType.facebook:
        var loginResult = await _signInWithFacebookService.signIn();
        if (loginResult.accessToken == null) {
          throw AuthenticationError.userRejected;
        }
        userCredentials = await _firebaseService.signInWithFacebook(loginResult);
        break;
    }

    if (userCredentials?.user == null && userCredentials?.additionalUserInfo == null) {
      throw AuthenticationError.badCredentials({});
    }
    if (await _firebaseService.userExists(userCredentials!.user!.uid)) {
      return;
    } else {
      String? firstName, familyName;
      if (userCredentials.user?.displayName != null) {
        var array = userCredentials.user!.displayName!.split(" ");
        if (array.length == 1) {
          firstName = userCredentials.user!.displayName;
        } else if (array.length == 2) {
          firstName = array[0];
          familyName = array[1];
        } else {
          firstName = array[0];
          array.removeAt(0);
          familyName = array.join(" ");
        }
      }
      var user = Profile(
        userCredentials.user!.uid,
        userCredentials.additionalUserInfo!.providerId!,
        email: userCredentials.user!.email,
        firstName: firstName,
        familyName: familyName,
        telephone: userCredentials.user!.phoneNumber,
      );
      return _firebaseService
          .addUser(userCredentials.user!.uid, user.toJson());
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseService.sendPasswordResetEmail(email);
  }

  @override
  Future<Profile> getCurrentUser() async {
    if (FirebaseAuth.instance.currentUser == null) {
      throw AuthenticationError.unAuthorized;
    }
    var data = await _firebaseService
        .getUser(FirebaseAuth.instance.currentUser!.uid);
    return Profile.from(data);
  }

  Future<bool> userChangedState() {
    return _firebaseService.authChanged().then((value) => value != null);
  }

  @override
  Future<void> changeEmail(String email) {
    return _firebaseService.changeEmail(email);
  }

  @override
  Future<void> updateProfile(Profile profile) {
    return _firebaseService.updateUser(profile.id, profile.toJson());
  }

  @override
  Future<void> signOut() {
    return _firebaseService.signOut();
  }

  @override
  Future<void> changePassword(String newPassword) {
    return _firebaseService.changePassword(newPassword);
  }

  @override
  Future<void> deleteAccount() async {
    if (FirebaseAuth.instance.currentUser == null){
      throw AuthenticationError.notLogin;
    }

    await _firebaseService.removeUser(FirebaseAuth.instance.currentUser!.uid);
    await _firebaseService.deleteAccount();
  }
}