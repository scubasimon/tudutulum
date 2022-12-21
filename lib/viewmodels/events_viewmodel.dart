import 'dart:async';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tudu/models/event.dart';

import '../models/event_type.dart';
import '../repositories/event/event_repository.dart';
import '../services/observable/observable_serivce.dart';
import 'home_viewmodel.dart';

class EventsViewModel extends BaseViewModel {
  static final EventsViewModel _instance =
  EventsViewModel._internal();

  factory EventsViewModel() {
    return _instance;
  }

  EventsViewModel._internal();

  final EventRepository _eventRepository = EventRepositoryImpl();
  HomeViewModel _homeViewModel = HomeViewModel();
  ObservableService _observableService = ObservableService();

  int? fromSite;

  @override
  FutureOr<void> init() {
  }

  void setEvetRedirectedFromSite(int input) {
    fromSite = input;
    notifyListeners();
  }

  void getDataWithFilterSortSearch(
      EventType? evenTypeFilter,
      String? keywordSort,
      String? keywordSearch) {
    try {
      List<Event> listSitesResult = _eventRepository.getEventsWithFilterSortSearch(
        _homeViewModel.listEvents,
        (evenTypeFilter != null) ? evenTypeFilter.eventId : -1,
        keywordSort,
        keywordSearch,
      );

      _observableService.listEventsController.sink.add(listSitesResult);
    } catch (e) {
      rethrow;
    }
  }
}