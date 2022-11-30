import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:tudu/models/auth.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/repositories/auth/auth_repository.dart';

class AuthenticationViewModel with ChangeNotifier {

  final AuthRepository _authRepository = AuthRepositoryImpl();

  Future<void> register(String name, String email, String mobile, String password) async {
    _validateEmail(email);
    _validatePassword(password, true);

    var auth = Authentication(
        AuthType.email,
        name: name.isEmpty ? null : name,
        email: email,
        password: password,
        phone: mobile.isEmpty ? null : mobile
    );
    return _authRepository.signUp(auth);
  }

  Future<void> signIn(Authentication authentication) async {
    if (authentication.type == AuthType.email) {
      _validateEmail(authentication.email);
      _validatePassword(authentication.password, false);
    }
    return _authRepository.signIn(authentication);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      throw AuthenticationError.emailEmpty;
    }
    await _authRepository.sendPasswordResetEmail(email);
  }

  void _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      throw AuthenticationError.emailEmpty;
    }
    RegExp emailRegex = RegExp(r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$");
    if (!emailRegex.hasMatch(email)) {
      throw AuthenticationError.emailInvalid;
    }
  }

  void _validatePassword(String? password, bool register) {
    if (password == null || password.isEmpty) {
      throw AuthenticationError.passwordEmpty;
    }
    if (register && password.length < 6) {
      throw AuthenticationError.passwordShort;
    }
  }
}