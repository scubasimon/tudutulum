import 'package:tudu/generated/l10n.dart';

class CustomError extends Error {
  String? message;
  String code;
  Map<String, dynamic> data = {};

  CustomError(this.code, {this.message, this.data = const {}});
}

class CommonError {
  static CustomError serverError = CustomError(
    "E_101",
    message: S.current.server_error,
  );
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

  static CustomError passwordShort = CustomError(
    "E_AUTH_106",
    message: S.current.password_short_error
  );

  static CustomError badCredentials(Map<String, dynamic> data, {String message = "Bad Credentials"}) {
    return CustomError(
      "E_AUTH_107",
      message: message,
      data: data,
    );
  }

  static CustomError userRejected = CustomError(
    "E_AUTH_108",
    message: S.current.user_not_approved_error,
  );

  static CustomError appleException(String message, Map<String, dynamic> data) {
    return CustomError(
      "E_AUTH_109",
      message: message,
      data: data
    );
  }
}
