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

class BookmarksViewModel extends BaseViewModel {
  static final BookmarksViewModel _instance =
  BookmarksViewModel._internal();

  factory BookmarksViewModel() {
    return _instance;
  }

  BookmarksViewModel._internal();

  final StreamController<List<String>> _listBookmarksController = BehaviorSubject<List<String>>();
  Stream<List<String>> get listBookmarksStream => _listBookmarksController.stream;

  @override
  FutureOr<void> init() {

  }

  void showData() {
    _listBookmarksController.sink.add(
        [
          "https://image.thanhnien.vn/w1024/Uploaded/2022/pwivoviu/2022_09_16/cau-vang--1-anh-nt-739.jpg"
        ]
    );
    notifyListeners();
  }
}