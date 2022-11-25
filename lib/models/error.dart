import 'package:tudu/generated/l10n.dart';

class CustomError extends Error {
  String? message;
  String code;
  Map<String, dynamic> data = {};

  CustomError(this.code, {this.message, this.data = const {}});
}

// start with E_AUTH_
class AuthenticationError {
  static CustomError nameEmpty = CustomError(
      "E_AUTH_101",
      message: S.current.name_empty_error,
  );

  static CustomError mobileEmpty = CustomError(
    "E_AUTH_102",
    message: S.current.mobile_empty_error,
  );

  static CustomError emailEmpty = CustomError(
    "E_AUTH_103",
    message: S.current.email_empty_error,
  );

  static CustomError emailInvalid = CustomError(
    "E_AUTH_104",
    message: S.current.email_invalid_error,
  );

  static CustomError passwordEmpty = CustomError(
    "E_AUTH_105",
    message: S.current.password_empty_error
  );
}
