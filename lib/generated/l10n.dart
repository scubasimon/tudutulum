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

  /// `What's on in Tulum\n- where to go; events, big and small -`
  String get onboard_description_3 {
    return Intl.message(
      'What\'s on in Tulum\n- where to go; events, big and small -',
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

  /// `Welcome back,\nPlease sign in`
  String get login_description {
    return Intl.message(
      'Welcome back,\nPlease sign in',
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

  /// `Please complete the short form below`
  String get register_message {
    return Intl.message(
      'Please complete the short form below',
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

  /// `*Email and password are required`
  String get required_message {
    return Intl.message(
      '*Email and password are required',
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

  /// `Warning`
  String get warning {
    return Intl.message(
      'Warning',
      name: 'warning',
      desc: '',
      args: [],
    );
  }

  /// `Do you really want to exit?`
  String get exit_app_message {
    return Intl.message(
      'Do you really want to exit?',
      name: 'exit_app_message',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `User not found`
  String get user_not_existed_error {
    return Intl.message(
      'User not found',
      name: 'user_not_existed_error',
      desc: '',
      args: [],
    );
  }

  /// `UnAuthorized`
  String get un_authorized_error {
    return Intl.message(
      'UnAuthorized',
      name: 'un_authorized_error',
      desc: '',
      args: [],
    );
  }

  /// `What tudu?`
  String get what_tudu {
    return Intl.message(
      'What tudu?',
      name: 'what_tudu',
      desc: '',
      args: [],
    );
  }

  /// `Events`
  String get events {
    return Intl.message(
      'Events',
      name: 'events',
      desc: '',
      args: [],
    );
  }

  /// `Deals`
  String get deals {
    return Intl.message(
      'Deals',
      name: 'deals',
      desc: '',
      args: [],
    );
  }

  /// `Bookmarks`
  String get bookmarks {
    return Intl.message(
      'Bookmarks',
      name: 'bookmarks',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Sort`
  String get sort {
    return Intl.message(
      'Sort',
      name: 'sort',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get filter {
    return Intl.message(
      'Filter',
      name: 'filter',
      desc: '',
      args: [],
    );
  }

  /// `'Business Type'`
  String get business_type {
    return Intl.message(
      '\'Business Type\'',
      name: 'business_type',
      desc: '',
      args: [],
    );
  }

  /// `Beach Clubs`
  String get beach_clubs {
    return Intl.message(
      'Beach Clubs',
      name: 'beach_clubs',
      desc: '',
      args: [],
    );
  }

  /// `Workspots`
  String get work_spots {
    return Intl.message(
      'Workspots',
      name: 'work_spots',
      desc: '',
      args: [],
    );
  }

  /// `All 'Location`
  String get all_location {
    return Intl.message(
      'All \'Location',
      name: 'all_location',
      desc: '',
      args: [],
    );
  }

  /// `Search here or use the filter above`
  String get search_placeholder {
    return Intl.message(
      'Search here or use the filter above',
      name: 'search_placeholder',
      desc: '',
      args: [],
    );
  }

  /// `All Location Articles`
  String get all_location_articles {
    return Intl.message(
      'All Location Articles',
      name: 'all_location_articles',
      desc: '',
      args: [],
    );
  }

  /// `Explore All Location`
  String get explore_all_location {
    return Intl.message(
      'Explore All Location',
      name: 'explore_all_location',
      desc: '',
      args: [],
    );
  }

  /// `Map`
  String get map {
    return Intl.message(
      'Map',
      name: 'map',
      desc: '',
      args: [],
    );
  }

  /// `•  Navigate the App`
  String get navigate_the_app {
    return Intl.message(
      '•  Navigate the App',
      name: 'navigate_the_app',
      desc: '',
      args: [],
    );
  }

  /// `•  Travel to Tulum`
  String get travel_to_tulum {
    return Intl.message(
      '•  Travel to Tulum',
      name: 'travel_to_tulum',
      desc: '',
      args: [],
    );
  }

  /// `•  Transport Locally`
  String get transport_locally {
    return Intl.message(
      '•  Transport Locally',
      name: 'transport_locally',
      desc: '',
      args: [],
    );
  }

  /// `•  About Tudu Tulum`
  String get about {
    return Intl.message(
      '•  About Tudu Tulum',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `•  Coming soon`
  String get coming_soon {
    return Intl.message(
      '•  Coming soon',
      name: 'coming_soon',
      desc: '',
      args: [],
    );
  }

  /// `•  Follow us to see our latest deals`
  String get follow_us {
    return Intl.message(
      '•  Follow us to see our latest deals',
      name: 'follow_us',
      desc: '',
      args: [],
    );
  }

  /// `•  Please rate Us`
  String get rate_us {
    return Intl.message(
      '•  Please rate Us',
      name: 'rate_us',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get setting {
    return Intl.message(
      'Settings',
      name: 'setting',
      desc: '',
      args: [],
    );
  }

  /// `•  The Legal stuff`
  String get the_legal_stuff {
    return Intl.message(
      '•  The Legal stuff',
      name: 'the_legal_stuff',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `More Information`
  String get more_information {
    return Intl.message(
      'More Information',
      name: 'more_information',
      desc: '',
      args: [],
    );
  }

  /// `Opening times`
  String get open_times {
    return Intl.message(
      'Opening times',
      name: 'open_times',
      desc: '',
      args: [],
    );
  }

  /// `Fees`
  String get fees {
    return Intl.message(
      'Fees',
      name: 'fees',
      desc: '',
      args: [],
    );
  }

  /// `Capacity`
  String get capacity {
    return Intl.message(
      'Capacity',
      name: 'capacity',
      desc: '',
      args: [],
    );
  }

  /// `Events and Experiences`
  String get events_and_experiences {
    return Intl.message(
      'Events and Experiences',
      name: 'events_and_experiences',
      desc: '',
      args: [],
    );
  }

  /// `You can also follow Title on:`
  String get follow_title {
    return Intl.message(
      'You can also follow Title on:',
      name: 'follow_title',
      desc: '',
      args: [],
    );
  }

  /// `With thanks to our trusted partner:`
  String get thanks_to_our_trusted_partner {
    return Intl.message(
      'With thanks to our trusted partner:',
      name: 'thanks_to_our_trusted_partner',
      desc: '',
      args: [],
    );
  }

  /// `Your Account`
  String get your_account {
    return Intl.message(
      'Your Account',
      name: 'your_account',
      desc: '',
      args: [],
    );
  }

  /// `Hello '{name}'`
  String hello_name(Object name) {
    return Intl.message(
      'Hello \'$name\'',
      name: 'hello_name',
      desc: '',
      args: [name],
    );
  }

  /// `Update Details`
  String get update_details {
    return Intl.message(
      'Update Details',
      name: 'update_details',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get first_name {
    return Intl.message(
      'First Name',
      name: 'first_name',
      desc: '',
      args: [],
    );
  }

  /// `Family Name`
  String get family_name {
    return Intl.message(
      'Family Name',
      name: 'family_name',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get change_password {
    return Intl.message(
      'Change Password',
      name: 'change_password',
      desc: '',
      args: [],
    );
  }

  /// `Current Password`
  String get current_password {
    return Intl.message(
      'Current Password',
      name: 'current_password',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get new_password {
    return Intl.message(
      'New Password',
      name: 'new_password',
      desc: '',
      args: [],
    );
  }

  /// `Repeat New Password`
  String get repeat_new_password {
    return Intl.message(
      'Repeat New Password',
      name: 'repeat_new_password',
      desc: '',
      args: [],
    );
  }

  /// `Receive new offer notification emails`
  String get receive_new_offer_notification_email {
    return Intl.message(
      'Receive new offer notification emails',
      name: 'receive_new_offer_notification_email',
      desc: '',
      args: [],
    );
  }

  /// `Receive monthly newsletter email`
  String get receive_monthly_newsletter_email {
    return Intl.message(
      'Receive monthly newsletter email',
      name: 'receive_monthly_newsletter_email',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get save_changes {
    return Intl.message(
      'Save Changes',
      name: 'save_changes',
      desc: '',
      args: [],
    );
  }

  /// `Or deactivate your account`
  String get delete_account {
    return Intl.message(
      'Or deactivate your account',
      name: 'delete_account',
      desc: '',
      args: [],
    );
  }

  /// `here`
  String get here {
    return Intl.message(
      'here',
      name: 'here',
      desc: '',
      args: [],
    );
  }

  /// `Sign out`
  String get sign_out {
    return Intl.message(
      'Sign out',
      name: 'sign_out',
      desc: '',
      args: [],
    );
  }

  /// `Current password must be not empty`
  String get current_password_empty_error {
    return Intl.message(
      'Current password must be not empty',
      name: 'current_password_empty_error',
      desc: '',
      args: [],
    );
  }

  /// `New password must be not empty`
  String get new_password_empty_error {
    return Intl.message(
      'New password must be not empty',
      name: 'new_password_empty_error',
      desc: '',
      args: [],
    );
  }

  /// `Repeat password must be not empty`
  String get repeat_password_empty_error {
    return Intl.message(
      'Repeat password must be not empty',
      name: 'repeat_password_empty_error',
      desc: '',
      args: [],
    );
  }

  /// `New password and Repeat password do not match`
  String get password_not_match_error {
    return Intl.message(
      'New password and Repeat password do not match',
      name: 'password_not_match_error',
      desc: '',
      args: [],
    );
  }

  /// `Update successful`
  String get update_successful {
    return Intl.message(
      'Update successful',
      name: 'update_successful',
      desc: '',
      args: [],
    );
  }

  /// `Notification`
  String get notification {
    return Intl.message(
      'Notification',
      name: 'notification',
      desc: '',
      args: [],
    );
  }

  /// `Requires login`
  String get not_login_error {
    return Intl.message(
      'Requires login',
      name: 'not_login_error',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect email or password`
  String get account_incorrect_error {
    return Intl.message(
      'Incorrect email or password',
      name: 'account_incorrect_error',
      desc: '',
      args: [],
    );
  }

  /// `Explore Deals`
  String get explore_deals {
    return Intl.message(
      'Explore Deals',
      name: 'explore_deals',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to delete your account?`
  String get confirm_delete_account_message {
    return Intl.message(
      'Do you want to delete your account?',
      name: 'confirm_delete_account_message',
      desc: '',
      args: [],
    );
  }

  /// `You are not logged in. please log in`
  String get login_message {
    return Intl.message(
      'You are not logged in. please log in',
      name: 'login_message',
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
