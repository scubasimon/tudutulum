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

class DealsViewModel extends BaseViewModel {
  static final DealsViewModel _instance =
  DealsViewModel._internal();

  factory DealsViewModel() {
    return _instance;
  }

  DealsViewModel._internal();

  final StreamController<List<String>> _listDealsController = BehaviorSubject<List<String>>();
  Stream<List<String>> get listDealsStream => _listDealsController.stream;

  @override
  FutureOr<void> init() {

  }

  void showData() {
    _listDealsController.sink.add(
        [
          "https://image.thanhnien.vn/w1024/Uploaded/2022/pwivoviu/2022_09_16/cau-vang--1-anh-nt-739.jpg"
        ]
    );
    notifyListeners();
  }
}