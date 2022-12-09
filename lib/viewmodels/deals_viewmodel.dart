import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tudu/models/deal.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/repositories/auth/auth_repository.dart';
import 'package:tudu/models/user.dart';
import 'package:tudu/repositories/deal/deal_repository.dart';
import 'package:tudu/models/param.dart' as Param;

class DealsViewModel extends BaseViewModel {

  final AuthRepository _authRepository = AuthRepositoryImpl();
  final DealRepository _dealRepository = DealRepositoryImpl();

  List<Deal> _data = [];

  final _param = BehaviorSubject<Param.Param>();

  final _userLogin = BehaviorSubject<bool>();
  Stream<bool> get userLoginStream => _userLogin.stream;

  final _listDeals = BehaviorSubject<List<Deal>>();
  Stream<List<Deal>> get deals => _listDeals.stream;

  final _isLoading = BehaviorSubject<bool>();
  Stream<bool> get loading => _isLoading.stream;

  final _exception = BehaviorSubject<CustomError>();
  Stream<CustomError> get error => _exception.stream;

  @override
  FutureOr<void> init() async {
    Profile? user;
    _isLoading.sink.add(true);
    try {
      user = await _authRepository.getCurrentUser();
    } catch (e) {
      print(e);
    }
    _userLogin.sink.add(user != null);
    if (user == null) {
      return;
    }

    await _getDataFromFirebase();
    _param.add(Param.Param());
    _searchData();
  }

  void searchWithParam({String? title, int? businessId, Param.Order? order}) {
    var value = _param.valueOrNull;
    if (value == null) {
      value = Param.Param(
        title: title,
        businessId: businessId,
        order: order ?? Param.Order.alphabet,
      );
    } else {
      if (title != null) {
        value.title = title;
      }
      if (businessId != null) {
        value.businessId = businessId;
      }
      if (order != null) {
        value.order = order;
      }
    }
    _param.sink.add(value);
  }

  Future<void> refresh() async {
    List<Deal> deals = [];
    try {
      deals = await _dealRepository.getDeals();
    } catch (e) {
      _exception.sink.add(e as CustomError);
    }
    _data = deals;
    _param.sink.add(_param.value);
  }

  void resetParam() {
    _isLoading.sink.add(true);
    _param.add(Param.Param());
  }


  Future<void> _getDataFromFirebase() async {
    List<Deal> deals = [];
    try {
      deals = await _dealRepository.getDeals();
      _isLoading.sink.add(false);
    } catch (e) {
      _isLoading.sink.add(false);
      _exception.sink.add(e as CustomError);
    }
    _data = deals;
    _param.add(Param.Param());

  }

  void _searchData() {
    _param.listen((value) {
      var results = _data.where((element){
        if (value.title == null) {
          return true;
        } else {
          return element.title.contains(value.title!);
        }
      }).where((element) {
        if (value.businessId == null){
          return true;
        } else {
          return element.businesses.contains(value.businessId!);
        }
      }).toList();
      results.sort((a, b){
        switch (value.order) {
          case Param.Order.alphabet: return a.title.compareTo(b.title);
          case Param.Order.distance: return 1;
        }
      });
      _listDeals.sink.add(results);
    });
  }
}