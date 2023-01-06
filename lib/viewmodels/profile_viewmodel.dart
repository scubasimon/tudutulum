import 'dart:async';
import 'package:localstore/localstore.dart';
import 'package:notification_center/notification_center.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/models/user.dart';
import 'package:tudu/repositories/auth/auth_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tudu/utils/func_utils.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:tudu/utils/pref_util.dart';

class ProfileViewModel extends BaseViewModel {

  final AuthRepository _authRepository = AuthRepositoryImpl();
  final _profile = BehaviorSubject<Profile>();
  final StreamController<CustomError> _error = BehaviorSubject<CustomError>();
  final StreamController<bool> _loading = BehaviorSubject();
  final StreamController<void> _updateSuccessful = BehaviorSubject();
  final _subscription = BehaviorSubject<String>();

  Stream<Profile> get profile => _profile.stream;
  Stream<CustomError> get error => _error.stream;
  Stream<bool> get loading => _loading.stream;
  Stream<void> get updateSuccessful => _updateSuccessful.stream;
  Stream<String> get subscription => _subscription;

  ProfileViewModel(): super();


  @override
  FutureOr<void> init() async {
    _loading.sink.add(true);
    try {
      var profile = await _authRepository.getCurrentUser();
      _profile.sink.add(profile);
      _loading.sink.add(false);
    } catch (e) {
      _loading.sink.add(false);
      CustomError error = e as CustomError;
      _error.sink.add(error);
    }

    try {
      var customerInfo = await Purchases.getCustomerInfo();
      final active = customerInfo.entitlements.all["Pro"]?.isActive == true;
      _updateSubscriber(active);
      if (active) {
        _subscription.add(S.current.account_type(S.current.pro));
      } else {
        _subscription.add(S.current.account_type(S.current.free));
      }
    } catch (e) {
      print(e);
      _updateSubscriber(false);
      _subscription.add(S.current.account_type(S.current.free));
    }

    NotificationCenter().subscribe(StrConst.purchaseSuccess, _updateAccount);
  }

  Future<void> signOut() async {
    try {
      PrefUtil.setValue(StrConst.isBookmarkBind, false);
      Purchases.logOut();
      await _removeDataOneByOne("bookmarks");
      await _authRepository.signOut();
    } catch (e) {
      print(e);

    }
  }

  Future<void> forgotPassword(String email) async {
    if (email.isEmpty) {
      throw AuthenticationError.emailEmpty;
    }
    try {
      await _authRepository.sendPasswordResetEmail(email);
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteAccount() {
    PrefUtil.setValue(StrConst.isBookmarkBind, false);
    Purchases.logOut();
    _removeDataOneByOne("bookmarks");
    return _authRepository
        .deleteAccount();
  }

  Future<void> update(
      String firstName,
      String familyName,
      String email,
      String telephone,
      String newPassword,
      String confirmPassword,
      bool isReceiveNewOffer,
      bool isReceiveMonthlyNewsletter
      ) async {
    if (_profile.valueOrNull == null) {
      return;
    }
    _loading.sink.add(true);
    try {
      await _changeEmail(email);
      await _changePassword(newPassword, confirmPassword);
      await _updateProfile(firstName, familyName, email, telephone, isReceiveNewOffer, isReceiveMonthlyNewsletter);
      _updateSuccessful.sink.add(_loading.sink.add(false));
    } catch (e) {
      _loading.sink.add(false);
      _error.sink.add(e as CustomError);
    }
  }

  Future<void> _updateProfile(
        String firstName,
        String familyName,
        String email,
        String telephone,
        bool isReceiveNewOffer,
        bool isReceiveMonthlyNewsletter
      ) async {
    if (email.isNotEmpty && !FuncUlti.validateEmail(email)) {
      throw AuthenticationError.emailInvalid;
    }
    var profile = _profile.valueOrNull!;
    profile.email = email.isEmpty ? null : email;
    profile.telephone = telephone.isEmpty ? null : telephone;
    profile.firstName = firstName.isEmpty ? null : firstName;
    profile.familyName = familyName.isEmpty ? null : familyName;
    profile.newsOffer = isReceiveNewOffer;
    profile.newsMonthly = isReceiveMonthlyNewsletter;
    await _authRepository.updateProfile(profile);
  }

  Future<void> _changePassword(
      String newPassword,
      String confirmPassword
      ) async {
    if (newPassword.isEmpty && confirmPassword.isEmpty) {
      return;
    }
    if (newPassword.isEmpty) {
      throw AuthenticationError.newPasswordEmpty;
    }
    if (newPassword.length < 6) {
      throw AuthenticationError.passwordShort;
    }
    if (confirmPassword.isEmpty) {
      throw AuthenticationError.repeatPasswordEmpty;
    }
    if (newPassword != confirmPassword) {
      throw AuthenticationError.passwordNotMatch;
    }
    await _authRepository.changePassword(newPassword);
  }

  Future<void> _changeEmail(String email) async {
    if (_profile.valueOrNull!.provider == "password") {
      if (email.isEmpty) {
        throw AuthenticationError.emailEmpty;
      }
      if (!FuncUlti.validateEmail(email)) {
        throw AuthenticationError.emailInvalid;
      }
      if (email != _profile.valueOrNull!.email!) {
        await _authRepository.changeEmail(email);
      }
    }
  }

  _updateAccount() {
    _subscription.add(S.current.account_type(S.current.pro));
  }

  Future<void> _removeDataOneByOne(String collectionName) async {
    int i = 0;
    bool keepFetching = true;
    while (keepFetching) {
      final listSitesResult = await Localstore.instance.collection(collectionName).doc(i.toString()).get();
      if (listSitesResult != null) {
        Localstore.instance.collection(collectionName).doc(i.toString()).delete();
        i++;
      } else {
        keepFetching = false;
      }
    }
  }

  _updateSubscriber(bool value) async {
    final user = _profile.valueOrNull;
    if (user == null) { return; }
    if (user.subscriber == value) {
      return;
    }
    user.subscriber = value;
    try {
      await _authRepository.updateProfile(user);
    } catch (e) {
      if (e is CustomError) {
        print(e.message);
      }
    }
  }
}