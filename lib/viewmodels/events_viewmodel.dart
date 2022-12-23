import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tudu/models/event.dart';

import '../models/event_type.dart';
import '../repositories/event/event_repository.dart';
import '../services/observable/observable_serivce.dart';
import 'home_viewmodel.dart';
import 'package:location/location.dart' as locationLib;

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

  late bool serviceEnabled;
  locationLib.Location location = locationLib.Location();

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

    print("getDataWithFilterSortSearch $keywordSearch");

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

  void sortWithLocation() async {
    _observableService.homeProgressLoadingController.sink.add(true);
    await checkLocationEnable();
    var currentPosition = await location.getLocation();
    if (currentPosition.latitude != null && currentPosition.longitude != null) {

      List<Event>? listSiteCurrent = (_observableService.listEventsController as BehaviorSubject<List<Event>?>).value;

      if (listSiteCurrent != null) {
        listSiteCurrent.sort((a, b) => getDistance(currentPosition, a).compareTo(getDistance(currentPosition, b)));
        _observableService.listEventsController.sink.add(listSiteCurrent);
        notifyListeners();
      }
    }
    _observableService.homeProgressLoadingController.sink.add(false);
  }

  double getDistance(LocationData location, Event a) {
    if (a.locationLat != null && a.locationLon != null) {
      return Geolocator.distanceBetween(
        location.latitude!,
        location.longitude!,
        a.locationLat!,
        a.locationLon!,
      );
    } else {
      return 0.0;
    }
  }

  Future<void> checkLocationEnable() async {
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        handlerLocationPermissionChanged();
        return;
      }
    }
  }

  void handlerLocationPermissionChanged() {
    // ACTION ON PERMISSION CHANGED
    print("handlerLocationPermissionChanged -> ACTION NOT IMPL YET");
  }

}