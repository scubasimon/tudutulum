import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/generated/l10n.dart';

import '../../consts/strings/str_const.dart';

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


  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getArticlesFilterSort(
      int? businessId,
      String? keyword,
      String? orderType,
      bool? isDescending,);

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getSitesFilterSort(
      int? businessId,
      String? keyword,
      String? orderType,
      bool? isDescending,
      int startAt,);

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getPartners();

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getAmenities();

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getBusinesses();

  Future<void> changeEmail(String email);

  Future<void> changePassword(String newPassword);

  Future<void> signOut();

  Future<void> removeUser(String userId);

  Future<void> deleteAccount();
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
      for (var element in data) {
        await FirebaseFirestore.instance.collection("sites").doc(element["siteid"].toString()).set(element);
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
    var result = await FirebaseFirestore.instance.collection("users").doc(id).get();
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
      return await FirebaseFirestore.instance.collection("users").doc(userId).update(data);
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
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getArticlesFilterSort(
      int? businessId,
      String? keyword,
      String? orderType,
      bool? isDescending,
      ) async {
    try {
      var listSiteResult = FirebaseFirestore.instance.collection("article");
      Query<Map<String, dynamic>>? listSiteFilterBusiness = null;
      Query<Map<String, dynamic>>? listSiteFilterTitle = null;
      Query<Map<String, dynamic>>? listSiteFilterResult = null;

      print("businessId ${businessId}");
      if (businessId != null) {
        if (businessId != -1) {
          listSiteFilterBusiness = listSiteResult
              .where(StrConst.sortBusiness, arrayContains: businessId);
        }
      }

      print("keyword ${keyword}");
      if (keyword != null) {
        if (listSiteFilterBusiness == null) {
          listSiteFilterTitle = listSiteResult
              .where(StrConst.sortTitle, isGreaterThanOrEqualTo: keyword)
              .where(StrConst.sortTitle, isLessThanOrEqualTo: '$keyword\uf8ff');
        } else {
          listSiteFilterTitle = listSiteFilterBusiness
              .where(StrConst.sortTitle, isGreaterThanOrEqualTo: keyword)
              .where(StrConst.sortTitle, isLessThanOrEqualTo: '$keyword\uf8ff');
        }
      }

      print("orderType ${orderType}");
      if (orderType == null) {
        if (listSiteFilterTitle != null) {
          listSiteFilterResult = listSiteFilterTitle.orderBy(StrConst.sortTitle, descending: false);
        } else if (listSiteFilterBusiness != null) {
          listSiteFilterResult = listSiteFilterBusiness.orderBy(StrConst.sortBusiness, descending: false);
        } else {
          listSiteFilterResult = listSiteResult.orderBy(StrConst.sortTitle, descending: false);
        }
      } else {
        if (listSiteFilterTitle != null) {
          if (orderType == StrConst.sortTitle) {
            listSiteFilterResult = listSiteFilterTitle.orderBy(orderType, descending: isDescending!);
          } else {
            listSiteFilterResult = listSiteFilterTitle.orderBy(StrConst.sortTitle);
            listSiteFilterResult = listSiteFilterTitle.orderBy(orderType, descending: isDescending!);
          }
        } else if (listSiteFilterBusiness != null) {
          if (orderType == StrConst.sortBusiness) {
            listSiteFilterResult = listSiteFilterBusiness.orderBy(orderType, descending: isDescending!);
          } else {
            listSiteFilterResult = listSiteFilterBusiness.orderBy(StrConst.sortBusiness);
            listSiteFilterResult = listSiteFilterBusiness.orderBy(orderType, descending: isDescending!);
          }
        } else {
          listSiteFilterResult = listSiteResult.orderBy(orderType, descending: isDescending!);
        }
      }

      var dataResult = await listSiteFilterResult.get();
      return dataResult.docs;

    } catch (e) {
      print("getArticlesFilterSort -> QueryDocumentSnapshot -> ERROR: $e");
    }
  }

  @override
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getSitesFilterSort(
      int? businessId,
      String? keyword,
      String? orderType,
      bool? isDescending,
      int startAt,
  ) async {
    try {
      var listSiteResult = FirebaseFirestore.instance.collection("sites");
      Query<Map<String, dynamic>>? listSiteFilterBusiness = null;
      Query<Map<String, dynamic>>? listSiteFilterTitle = null;
      Query<Map<String, dynamic>>? listSiteFilterResult = null;

      print("businessId ${businessId}");
      if (businessId != null) {
        if (businessId != -1) {
          listSiteFilterBusiness = listSiteResult
              .where(StrConst.sortBusiness, arrayContains: businessId);
        }
      }

      print("keyword ${keyword}");
      if (keyword != null) {
        if (listSiteFilterBusiness == null) {
          listSiteFilterTitle = listSiteResult
              .where(StrConst.sortTitle, isGreaterThanOrEqualTo: keyword)
              .where(StrConst.sortTitle, isLessThanOrEqualTo: '$keyword\uf8ff');
        } else {
          listSiteFilterTitle = listSiteFilterBusiness
              .where(StrConst.sortTitle, isGreaterThanOrEqualTo: keyword)
              .where(StrConst.sortTitle, isLessThanOrEqualTo: '$keyword\uf8ff');
        }
      }

      print("orderType ${orderType}");
      if (orderType == null) {
        if (listSiteFilterTitle != null) {
          listSiteFilterResult = listSiteFilterTitle.orderBy(StrConst.sortTitle, descending: false);
        } else if (listSiteFilterBusiness != null) {
          listSiteFilterResult = listSiteFilterBusiness.orderBy(StrConst.sortBusiness, descending: false);
        } else {
          listSiteFilterResult = listSiteResult.orderBy(StrConst.sortTitle, descending: false);
        }
      } else {
        if (listSiteFilterTitle != null) {
          if (orderType == StrConst.sortTitle) {
            listSiteFilterResult = listSiteFilterTitle.orderBy(orderType, descending: isDescending!);
          } else {
            listSiteFilterResult = listSiteFilterTitle.orderBy(StrConst.sortTitle);
            listSiteFilterResult = listSiteFilterTitle.orderBy(orderType, descending: isDescending!);
          }
        } else if (listSiteFilterBusiness != null) {
          if (orderType == StrConst.sortBusiness) {
            listSiteFilterResult = listSiteFilterBusiness.orderBy(orderType, descending: isDescending!);
          } else {
            listSiteFilterResult = listSiteFilterBusiness.orderBy(StrConst.sortBusiness);
            listSiteFilterResult = listSiteFilterBusiness.orderBy(orderType, descending: isDescending!);
          }
        } else {
          listSiteFilterResult = listSiteResult.orderBy(orderType, descending: isDescending!);
        }
      }

      print("startAt ${startAt}");
      if (startAt == 0) {
        var dataResult = await listSiteFilterResult.limit(10).get();
        return dataResult.docs;
      } else {
        var listSiteCurrent = await listSiteFilterResult
            .limit(10)
            .get();

        print("listSiteCurrent ${listSiteCurrent.docs.length}");

        final lastVisible = listSiteCurrent.docs[listSiteCurrent.size - 1];

        final listSiteResult = await listSiteFilterResult
            .startAfter([lastVisible.data()[orderType]])
            .limit(10)
            .get();

        return listSiteResult.docs;
      }

    } catch (e) {
      print("getSitesFilterSort -> QueryDocumentSnapshot -> ERROR: $e");
    }
  }


  @override
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getPartners() async {
    try {
      final listSite = await FirebaseFirestore.instance.collection("partners").get();

      return listSite.docs;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getAmenities() async {
    try {
      final listSite = await FirebaseFirestore.instance.collection("amenities").get();

      return listSite.docs;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getBusinesses() async {
    try {
      final listSite = await FirebaseFirestore.instance.collection("businesses").get();

      return listSite.docs;
    } catch (e) {
      return null;
    }
  }
}
