import 'dart:async';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/models/user.dart';
import 'package:tudu/repositories/auth/auth_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tudu/utils/func_utils.dart';

class ProfileViewModel extends BaseViewModel {

  final AuthRepository _authRepository = AuthRepositoryImpl();
  final _profile = BehaviorSubject<Profile>();
  final StreamController<CustomError> _error = BehaviorSubject<CustomError>();
  final StreamController<bool> _loading = BehaviorSubject();
  final StreamController<void> _updateSuccessful = BehaviorSubject();

  Stream<Profile> get profile => _profile.stream;
  Stream<CustomError> get error => _error.stream;
  Stream<bool> get loading => _loading.stream;
  Stream<void> get updateSuccessful => _updateSuccessful.stream;

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
  }

  Future<void> signOut() async {
    // _loading.sink.add(true);
    try {
      await _authRepository.signOut();
    } catch (e) {
      print(e);

    }
    // _loading.sink.add(false);
  }

  void forgotPassword(String email) {
    if (email.isEmpty) {
      throw AuthenticationError.emailEmpty;
    }
    _loading.sink.add(true);
    _authRepository.sendPasswordResetEmail(email)
    .then((_){
      _loading.sink.add(false);
    })
    .catchError((e, stackTrace) {
      _error.add(e as CustomError);
    });

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
}