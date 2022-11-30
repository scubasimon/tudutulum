import 'dart:async';
import 'package:tudu/base/base_viewmodel.dart';

class ProfileViewModel extends BaseViewModel {
  static final ProfileViewModel _instance =
  ProfileViewModel._internal();

  factory ProfileViewModel() {
    return _instance;
  }

  ProfileViewModel._internal();

  @override
  FutureOr<void> init() {

  }
}