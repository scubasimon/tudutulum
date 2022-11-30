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