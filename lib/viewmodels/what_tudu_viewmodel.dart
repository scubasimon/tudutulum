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

class WhatTuduViewModel extends BaseViewModel {
  static final WhatTuduViewModel _instance =
  WhatTuduViewModel._internal();

  factory WhatTuduViewModel() {
    return _instance;
  }

  WhatTuduViewModel._internal();

  final StreamController<List<String>> _listBusinessController = BehaviorSubject<List<String>>();
  Stream<List<String>> get listBusinessStream => _listBusinessController.stream;

  @override
  FutureOr<void> init() {

  }

  void showData() {
    _listBusinessController.sink.add(["https://image.thanhnien.vn/w1024/Uploaded/2022/pwivoviu/2022_09_16/cau-vang--1-anh-nt-739.jpg",
      "https://www.dulichxanh.com.vn/uploads/plugin/products/2348/1661830269-645812250-t-t-d-ng-l-ch-tour-du-l-ch-phu-qu-c-4-ngay-3-em-kh-i-hanh-t-ha-n-i.jpg",
      "https://nld.mediacdn.vn/291774122806476800/2021/10/28/3-anh-chot-32910-16353728564007125658.jpg"]);
    notifyListeners();
  }
}