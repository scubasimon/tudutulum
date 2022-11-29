// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `What are you  `
  String get onboard_title_1 {
    return Intl.message(
      'What are you  ',
      name: 'onboard_title_1',
      desc: '',
      args: [],
    );
  }

  /// `Your local directory`
  String get onboard_title_2 {
    return Intl.message(
      'Your local directory',
      name: 'onboard_title_2',
      desc: '',
      args: [],
    );
  }

  /// `Your local calendar`
  String get onboard_title_3 {
    return Intl.message(
      'Your local calendar',
      name: 'onboard_title_3',
      desc: '',
      args: [],
    );
  }

  /// `Your exclusive savings`
  String get onboard_title_4 {
    return Intl.message(
      'Your exclusive savings',
      name: 'onboard_title_4',
      desc: '',
      args: [],
    );
  }

  /// `Your Tulum travel companion`
  String get onboard_description_1 {
    return Intl.message(
      'Your Tulum travel companion',
      name: 'onboard_description_1',
      desc: '',
      args: [],
    );
  }

  /// `Plan your trip\n- what tudu while you're in Tulum -`
  String get onboard_description_2 {
    return Intl.message(
      'Plan your trip\n- what tudu while you\'re in Tulum -',
      name: 'onboard_description_2',
      desc: '',
      args: [],
    );
  }

  /// `What's on in Tulum\n- where go; events, big and small -`
  String get onboard_description_3 {
    return Intl.message(
      'What\'s on in Tulum\n- where go; events, big and small -',
      name: 'onboard_description_3',
      desc: '',
      args: [],
    );
  }

  /// `Sign-in to view\n local deals & discounts`
  String get onboard_description_4 {
    return Intl.message(
      'Sign-in to view\n local deals & discounts',
      name: 'onboard_description_4',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get skip {
    return Intl.message(
      'Skip',
      name: 'skip',
      desc: '',
      args: [],
    );
  }

  /// `Get Started`
  String get get_started {
    return Intl.message(
      'Get Started',
      name: 'get_started',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Welcome back,\nSign in to view the deal`
  String get login_description {
    return Intl.message(
      'Welcome back,\nSign in to view the deal',
      name: 'login_description',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Forgot password?`
  String get forgot_password {
    return Intl.message(
      'Forgot password?',
      name: 'forgot_password',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account?`
  String get account_not_exist {
    return Intl.message(
      'Don\'t have an account?',
      name: 'account_not_exist',
      desc: '',
      args: [],
    );
  }

  /// `Create account`
  String get create_account {
    return Intl.message(
      'Create account',
      name: 'create_account',
      desc: '',
      args: [],
    );
  }

  /// `Or sign up/in with`
  String get sign_in_other {
    return Intl.message(
      'Or sign up/in with',
      name: 'sign_in_other',
      desc: '',
      args: [],
    );
  }

  /// `Maybe later`
  String get maybe_later {
    return Intl.message(
      'Maybe later',
      name: 'maybe_later',
      desc: '',
      args: [],
    );
  }

  /// `Please complete the short for below`
  String get register_message {
    return Intl.message(
      'Please complete the short for below',
      name: 'register_message',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Mobile`
  String get mobile {
    return Intl.message(
      'Mobile',
      name: 'mobile',
      desc: '',
      args: [],
    );
  }

  /// `*Email and password is required`
  String get required_message {
    return Intl.message(
      '*Email and password is required',
      name: 'required_message',
      desc: '',
      args: [],
    );
  }

  /// `Term and Conditions`
  String get term_and_conditions {
    return Intl.message(
      'Term and Conditions',
      name: 'term_and_conditions',
      desc: '',
      args: [],
    );
  }

  /// `I agree with our`
  String get agree_message {
    return Intl.message(
      'I agree with our',
      name: 'agree_message',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account?`
  String get account_exist_message {
    return Intl.message(
      'Already have an account?',
      name: 'account_exist_message',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get sign_in {
    return Intl.message(
      'Sign In',
      name: 'sign_in',
      desc: '',
      args: [],
    );
  }

  /// `You have not agreed to the terms and conditions.`
  String get not_agree_term_and_conditions_error {
    return Intl.message(
      'You have not agreed to the terms and conditions.',
      name: 'not_agree_term_and_conditions_error',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred, please try again`
  String get server_error {
    return Intl.message(
      'An error occurred, please try again',
      name: 'server_error',
      desc: '',
      args: [],
    );
  }

  /// `Name must be not empty`
  String get name_empty_error {
    return Intl.message(
      'Name must be not empty',
      name: 'name_empty_error',
      desc: '',
      args: [],
    );
  }

  /// `Phone must be not empty`
  String get mobile_empty_error {
    return Intl.message(
      'Phone must be not empty',
      name: 'mobile_empty_error',
      desc: '',
      args: [],
    );
  }

  /// `Email must be not empty`
  String get email_empty_error {
    return Intl.message(
      'Email must be not empty',
      name: 'email_empty_error',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email`
  String get email_invalid_error {
    return Intl.message(
      'Invalid email',
      name: 'email_invalid_error',
      desc: '',
      args: [],
    );
  }

  /// `Password must be not empty`
  String get password_empty_error {
    return Intl.message(
      'Password must be not empty',
      name: 'password_empty_error',
      desc: '',
      args: [],
    );
  }

  /// `Password must be longer than 6 characters`
  String get password_short_error {
    return Intl.message(
      'Password must be longer than 6 characters',
      name: 'password_short_error',
      desc: '',
      args: [],
    );
  }

  /// `The password provided is too weak`
  String get password_too_weak_error {
    return Intl.message(
      'The password provided is too weak',
      name: 'password_too_weak_error',
      desc: '',
      args: [],
    );
  }

  /// `The account already exists for that email`
  String get account_already_exists_error {
    return Intl.message(
      'The account already exists for that email',
      name: 'account_already_exists_error',
      desc: '',
      args: [],
    );
  }

  /// `User not approve. Please try again`
  String get user_not_approved_error {
    return Intl.message(
      'User not approve. Please try again',
      name: 'user_not_approved_error',
      desc: '',
      args: [],
    );
  }

  /// `Failed`
  String get failed {
    return Intl.message(
      'Failed',
      name: 'failed',
      desc: '',
      args: [],
    );
  }

  /// `Password reset link has been sent successfully`
  String get reset_password_message {
    return Intl.message(
      'Password reset link has been sent successfully',
      name: 'reset_password_message',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
