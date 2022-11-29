import 'dart:async';
import '../base/base_viewmodel.dart';
import 'dart:ffi';
import 'package:rxdart/rxdart.dart';
import '../utils/colors_const.dart';
import '../utils/dimens_const.dart';
import '../utils/font_size_const.dart';
import '../utils/image_path.dart';
import '../utils/pref_util.dart';
import '../utils/str_const.dart';

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