import 'dart:async';
import 'dart:ffi';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tudu/repositories/auth/auth_repository.dart';
import 'package:tudu/models/user.dart';

class DealsViewModel extends BaseViewModel {

  AuthRepository _authRepository = AuthRepositoryImpl();
  final StreamController<List<String>> _listDealsController = BehaviorSubject<List<String>>();
  Stream<List<String>> get listDealsStream => _listDealsController.stream;
  final _userLogin = BehaviorSubject<bool>();
  Stream<bool> get userLoginStream => _userLogin.stream;

  @override
  FutureOr<void> init() async {
    Profile? user;
    try {
      user = await _authRepository.getCurrentUser();
    } catch (e) {
      print(e);
    }
    _userLogin.sink.add(user != null);
    if (user == null) {
      return;
    }


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