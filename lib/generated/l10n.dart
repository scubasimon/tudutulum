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

  /// `Your local exclusive savings`
  String get onboard_title_4 {
    return Intl.message(
      'Your local exclusive savings',
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

  /// `What's on in Tulum\n- where goto; events, big and small -`
  String get onboard_description_3 {
    return Intl.message(
      'What\'s on in Tulum\n- where goto; events, big and small -',
      name: 'onboard_description_3',
      desc: '',
      args: [],
    );
  }

  /// `Sign-in to view local deals & discounts`
  String get onboard_description_4 {
    return Intl.message(
      'Sign-in to view local deals & discounts',
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
