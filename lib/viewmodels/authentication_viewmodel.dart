import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:tudu/models/auth.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/repositories/auth/auth_repository.dart';
import 'package:tudu/utils/func_utils.dart';

class AuthenticationViewModel with ChangeNotifier {

  final AuthRepository _authRepository = AuthRepositoryImpl();

  Future<void> register(String name, String email, String password) async {
    _validateEmail(email);
    _validatePassword(password, true);

    var auth = Authentication(
        AuthType.email,
        name: name.isEmpty ? null : name,
        email: email,
        password: password,
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
    if (!FuncUlti.validateEmail(email)) {
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