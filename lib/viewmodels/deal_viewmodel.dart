import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:tudu/models/deal.dart';
import 'package:tudu/repositories/deal/deal_repository.dart';
import 'package:tudu/models/error.dart';

class DealViewModel extends BaseViewModel {

  final deal = BehaviorSubject<Deal>();
  final DealRepository _dealRepository = DealRepositoryImpl();

  final _isLoading = BehaviorSubject<bool>();
  Stream<bool> get loading => _isLoading.stream;

  final _exception = BehaviorSubject<CustomError>();
  Stream<CustomError> get error => _exception.stream;

  @override
  FutureOr<void> init() {
    deal
        .where((event) => event.titleShort.isEmpty)
        .listen((event) async {
          _isLoading.add(true);
          try {
            await _loadData(event.dealsId);
            _isLoading.add(false);
          } catch (e) {
            _isLoading.add(false);
            _exception.add(e as CustomError);
          }
    });
  }

  void redeem() async {
    _isLoading.add(true);
    try {
      await _dealRepository
          .redeem(deal.value.dealsId);
      _isLoading.add(false);
    } catch (e) {
      _isLoading.add(false);
      _exception.add(e as CustomError);
    }
  }

  Future<void> refresh() async {
    _isLoading.add(true);
    try {
      await _loadData(deal.value.dealsId);
      _isLoading.add(false);
    } catch (e) {
      _isLoading.add(false);
      _exception.add(e as CustomError);
    }
  }

  Future<void> _loadData(int dealId) async {
    var result = await _dealRepository.getDeal(dealId);
    deal.add(result);
  }


}