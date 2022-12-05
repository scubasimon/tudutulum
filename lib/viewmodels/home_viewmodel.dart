import 'dart:async';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:tudu/models/amenity.dart';

import '../models/partner.dart';
import '../repositories/home/home_repository.dart';
import 'dart:async';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';

class HomeViewModel extends BaseViewModel {

  final HomeRepository _homeRepository = HomeRepositoryImpl();

  static final HomeViewModel _instance =
  HomeViewModel._internal();

  factory HomeViewModel() {
    return _instance;
  }

  HomeViewModel._internal();

  final StreamController<int> _redirectTabController = BehaviorSubject<int>();
  Stream<int> get redirectTabStream => _redirectTabController.stream;

  List<Partner> listPartners = [];
  List<Amenity> listAmenites = [];

  @override
  FutureOr<void> init() {

  }

  void redirectTab(int tabIndex) {
    _redirectTabController.sink.add(tabIndex);
    notifyListeners();
  }

  Partner? getPartnerById(int idInput) {
    for (var element in listPartners) {
      if (element.partnerId == idInput) {
        return element;
      }
    }
    return null;
  }

  Amenity? getAmenityById(int idInput) {
    for (var element in listAmenites) {
      if (element.amenitiyId == idInput) {
        return element;
      }
    }
    return null;
  }

  Future<void> getListPartners() async {
    try {
      listPartners = await _homeRepository.getListPartners();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getListAmenities() async {
    try {
      listAmenites = await _homeRepository.getListAmenities();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}