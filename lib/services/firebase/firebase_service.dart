import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:tudu/utils/func_utils.dart';
import 'package:tudu/consts/strings/str_const.dart';

abstract class FirebaseService {
  Future<void> createData(List<Map<String, dynamic>> data);

  Future<UserCredential> signUp(String email, String password);

  Future<UserCredential> signIn(String email, String password);

  Future<UserCredential> signInWithGoogle(GoogleSignInAuthentication googleAuth);

  Future<UserCredential> signInWithApple(AuthorizationCredentialAppleID appleCredential, String rawNonce);

  Future<UserCredential> signInWithFacebook(LoginResult loginResult);

  Future<void> sendPasswordResetEmail(String email);

  Future<Map<String, dynamic>> getUser(String id);

  Future<void> addUser(String userId, Map<String, dynamic> data);

  Future<void> updateUser(String userId, Map<String, dynamic> data);

  Future<bool> userExists(String userId);

  Future<User?> authChanged();

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getArticles();

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getSites();

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getEvents();

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getPartners();

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getAmenities();

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getBusinesses();

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getEventTypes();

  Future<void> changeEmail(String email);

  Future<void> changePassword(String newPassword);

  Future<void> signOut();

  Future<void> removeUser(String userId);

  Future<void> deleteAccount();
  
  Future<List<Map<String, dynamic>>> getDeals();
  
  Future<Map<String, dynamic>> getDeal(int id);

  Future<void> redeem(int dealId, String userId, DateTime time);

  Future<Map<String, dynamic>> getRedeem(int dealId, String userId);

  Future<Map<String, dynamic>> getSite(int siteId);

  Future<void> bookmark(int siteId, String userId, DateTime time);

  Future<void> unBookmark(int siteId, String userId);

  Future<List<Map<String, dynamic>>> bookmarks(String userId);

  Future<Map<String, dynamic>> bookmarkDetail(int siteId, String userId);
}

class FirebaseServiceImpl extends FirebaseService {
  static final FirebaseServiceImpl _singleton = FirebaseServiceImpl._internal();

  factory FirebaseServiceImpl() {
    return _singleton;
  }
  FirebaseServiceImpl._internal();

  @override
  Future<void> createData(List<Map<String, dynamic>> data) async {
    try {
      print("createData ${data.length.toString()}");
      for (var element in data) {
        print("createData ${element["eventid"].toString()}");
        await FirebaseFirestore.instance.collection("events").doc(element["eventid"].toString()).set(element);
      }
    } catch (e) {
      print(e);
      throw CommonError.serverError;
    }
  }

  @override
  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      var error = "Bad credentials";
      if (e.code == "weak-password") {
        error = S.current.password_too_weak_error;
      } else if (e.code == "email-already-in-use") {
        error = S.current.account_already_exists_error;
      }
      throw AuthenticationError.badCredentials({"error": e}, message: error);
    } catch (e) {
      print(e);
      throw CommonError.serverError;
    }
  }

  @override
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == "network-request-failed") {
        throw CommonError.serverError;
      }
      throw AuthenticationError.badCredentials({
        "error": e,
      }, message: S.current.account_incorrect_error);
    } catch (e) {
      print(e);
      throw CommonError.serverError;
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

  @override
  Future<UserCredential> signInWithApple(AuthorizationCredentialAppleID appleCredential, String rawNonce) async {
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );
    return _signInWith(oauthCredential);
  }

  @override
  Future<UserCredential> signInWithFacebook(LoginResult loginResult) {
    var facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);
    return _signInWith(facebookAuthCredential);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e);
      throw CommonError.serverError;
    }
  }

  @override
  Future<Map<String, dynamic>> getUser(String id) async {
    DocumentSnapshot<Map<String, dynamic>> result;
    try {
      result = await FirebaseFirestore.instance.collection("users").doc(id).get();
    } catch (e) {
      print(e);
      throw CommonError.serverError;
    }
    if (result.exists) {
      return result.data()!;
    } else {
      throw AuthenticationError.userNotExisted;
    }
  }

  @override
  Future<void> addUser(String userId, Map<String, dynamic> data) async {
    try {
      return await FirebaseFirestore.instance.collection("users").doc(userId).set(data);
    } catch (e) {
      print(e);
      throw CommonError.serverError;
    }
  }

  @override
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      return await FirebaseFirestore
          .instance
          .collection("users")
          .doc(userId).update(data);
    } catch (e) {
      print(e);
      throw CommonError.serverError;
    }
  }

  @override
  Future<User?> authChanged() async {
    var completer = Completer<User?>();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      completer.complete(user);
    });
    return completer.future;
  }

  @override
  Future<void> changeEmail(String email) async {
    try {
      FirebaseAuth.instance.currentUser?.updateEmail(email);
    } on FirebaseAuthException catch (e) {
      print(e);
      throw AuthenticationError.badCredentials({"error": e}, message: e.message ?? "");
    } catch (e) {
      print(e);
      throw CommonError.serverError;
    }
  }

  @override
  Future<void> changePassword(String newPassword) async {
    return await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);
  }

  @override
  Future<bool> userExists(String userId) async {
    try {
      var result = await FirebaseFirestore.instance.collection("users").doc(userId).get();
      return result.exists;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<UserCredential> _signInWith(AuthCredential authCredential) async {
    try {
      return await FirebaseAuth.instance.signInWithCredential(authCredential);
    } on FirebaseAuthException catch (e) {
      print(e);
      throw AuthenticationError.badCredentials({"error": e}, message: e.message ?? "");
    } catch (e) {
      print(e);
      throw CommonError.serverError;
    }
  }

  @override
  Future<void> signOut() {
    return FirebaseAuth.instance.signOut();
  }

  @override
  Future<void> removeUser(String userId) async {
    try {
      return await FirebaseFirestore.instance.collection("users").doc(userId).delete();
    } catch (e) {
      print(e);
      throw CommonError.serverError;
    }
  }

  @override
  Future<void> deleteAccount() {
    if (FirebaseAuth.instance.currentUser == null) {
      throw AuthenticationError.notLogin;
    }
    return FirebaseAuth.instance.currentUser!.delete();
  }

  @override
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getArticles() async {
    bool? netWork = await FuncUlti.NetworkChecking();
    if (netWork == true) {
      var listSiteResult =
          await FirebaseFirestore.instance.collection("articles").orderBy(StrConst.sortTitle, descending: false).get();
      return listSiteResult.docs;
    } else {
      throw S.current.network_fail;
    }
  }

  @override
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getSites() async {
    bool? netWork = await FuncUlti.NetworkChecking();
    if (netWork == true) {
      var listSiteResult =
          await FirebaseFirestore.instance.collection("sites").orderBy(StrConst.sortTitle, descending: false).get();
      return listSiteResult.docs;
    } else {
      throw S.current.network_fail;
    }
  }

  @override
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getEvents() async {
    bool? netWork = await FuncUlti.NetworkChecking();
    if (netWork == true) {
      var listSiteResult =
          await FirebaseFirestore.instance.collection("events").orderBy(StrConst.sortTitle, descending: false).get();
      return listSiteResult.docs;
    } else {
      throw S.current.network_fail;
    }
  }

  @override
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getPartners() async {
    bool? netWork = await FuncUlti.NetworkChecking();
    if (netWork == true) {
      final listSite = await FirebaseFirestore.instance.collection("partners").get();
      return listSite.docs;
    } else {
      throw S.current.network_fail;
    }
  }

  @override
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getAmenities() async {
    bool? netWork = await FuncUlti.NetworkChecking();
    if (netWork == true) {
      final listSite = await FirebaseFirestore.instance.collection("amenities").get();
      return listSite.docs;
    } else {
      throw S.current.network_fail;
    }
  }

  @override
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getBusinesses() async {
    bool? netWork = await FuncUlti.NetworkChecking();
    if (netWork == true) {
      final listSite = await FirebaseFirestore.instance.collection("businesses").get();
      return listSite.docs;
    } else {
      throw S.current.network_fail;
    }
  }

  @override
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getEventTypes() async {
    bool? netWork = await FuncUlti.NetworkChecking();
    if (netWork == true) {
      final listSite = await FirebaseFirestore.instance.collection("eventtypes").get();
      return listSite.docs;
    } else {
      throw S.current.network_fail;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDeals() async {
    try {
      var results = await FirebaseFirestore.instance.collection("deals").get();
      return results.docs.map((e) => e.data()).toList();
    } catch (e) {
      print(e);
      throw CommonError.serverError;
    }
  }

  @override
  Future<Map<String, dynamic>> getDeal(int id) async {
    try {
      var results = await FirebaseFirestore
          .instance
          .collection("deals")
          .where("dealsid", isEqualTo: id).get(); 
      var data = results.docs.map((e) => e.data());
      if (data.isEmpty) {
        throw CommonError.serverError;
      } else {
        return data.first;
      }
    } catch (e) {
      if (e is CustomError) {
        rethrow;
      } else {
        throw CommonError.serverError;
      }
    }
  }

  @override
  Future<void> redeem(int dealId, String userId, DateTime time) async {
    try {
      FirebaseFirestore
          .instance
          .collection("dealsSuccessful")
          .add({
        "dealsid": dealId,
        "userIdentifier": userId,
        "timestamp": time
      });
    } catch (e) {
      print(e);
      throw CommonError.serverError;
    }
  }

  @override
  Future<Map<String, dynamic>> getRedeem(int dealId, String userId) async {
    try {
      var results = await FirebaseFirestore
          .instance
          .collection("dealsSuccessful")
          .where("dealsid", isEqualTo: dealId)
          .where("userIdentifier", isEqualTo: userId).get();
      var data = results.docs.map((e) => e.data());
      if (data.isEmpty) {
        throw CommonError.serverError;
      } else {
        return data.first;
      }
    } catch (e) {
      if (e is CustomError) {
        rethrow;
      } else {
        throw CommonError.serverError;
      }
    }
  }

  @override
  Future<Map<String, dynamic>> getSite(int siteId) async {
    try {
      var results = await FirebaseFirestore
          .instance
          .collection("sites")
          .where("siteid", isEqualTo: siteId).get();
      var data = results.docs.map((e) => e.data());
      if (data.isEmpty) {
        throw CommonError.serverError;
      } else {
        return data.first;
      }
    } catch (e) {
      if (e is CustomError) {
        rethrow;
      } else {
        throw CommonError.serverError;
      }
    }
  }

  @override
  Future<void> bookmark(int siteId, String userId, DateTime time) async {
    try {
      FirebaseFirestore
          .instance
          .collection("bookmarks")
          .add({
        "siteid": siteId,
        "userIdentifier": userId,
        "timestamp": time
      });
    } catch (e) {
      print(e);
      throw CommonError.serverError;
    }
  }

  @override
  Future<void> unBookmark(int siteId, String userId) async {
    try {
      var results = await FirebaseFirestore
          .instance
          .collection("bookmarks")
          .where("siteid", isEqualTo: siteId)
          .where("userIdentifier", isEqualTo: userId).get();
      for (var result in results.docs) {
        await result.reference.delete();
      }
    } catch (e) {
      throw CommonError.serverError;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> bookmarks(String userId) async {
    try {
      var results = await FirebaseFirestore
          .instance
          .collection("bookmarks")
          .where("userIdentifier", isEqualTo: userId)
          .get();
      return results.docs.map((e) => e.data()).toList();
    } catch (e) {
      throw CommonError.serverError;
    }
  }

  @override
  Future<Map<String, dynamic>> bookmarkDetail(int siteId, String userId) async {
    try {
      var results = await FirebaseFirestore
          .instance
          .collection("bookmarks")
          .where("siteid", isEqualTo: siteId)
          .where("userIdentifier", isEqualTo: userId)
          .get();
      var data = results.docs.map((e) => e.data());
      if (data.isEmpty) {
        throw CommonError.serverError;
      } else {
        return data.first;
      }
    } catch (e) {
      if (e is CustomError) {
        rethrow;
      } else {
        throw CommonError.serverError;
      }
    }
  }
}
