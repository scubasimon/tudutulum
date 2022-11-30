import 'dart:async';
import 'package:tudu/base/base_viewmodel.dart';

class HomeViewModel extends BaseViewModel {
  static final HomeViewModel _instance =
  HomeViewModel._internal();

  factory HomeViewModel() {
    return _instance;
  }

  HomeViewModel._internal();

  @override
  FutureOr<void> init() {

  }
}