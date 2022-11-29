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

class EventsViewModel extends BaseViewModel {
  static final EventsViewModel _instance =
  EventsViewModel._internal();

  factory EventsViewModel() {
    return _instance;
  }

  EventsViewModel._internal();

  final StreamController<List<EventData>> _listEventsController = BehaviorSubject<List<EventData>>();
  Stream<List<EventData>> get listEventsStream => _listEventsController.stream;

  @override
  FutureOr<void> init() {

  }

  void showData() {
    _listEventsController.sink.add(
        [
          EventData(
            date: 'Daily',
            timestart: '19:00',
            event: 'Temazcalli Ceremony',
            eventSite: 'Casa Nawal Alkal',
            cost: '\$200',
            currency: 'MXN'
          ),
          EventData(
              date: 'Daily',
              timestart: '19:00',
              event: 'Temazcalli Ceremony',
              eventSite: 'Casa Nawal Alkal',
              cost: '\$300',
              currency: 'MXN'
          ),
          EventData(
              date: 'Daily',
              timestart: '19:00',
              event: 'Temazcalli Ceremony',
              eventSite: 'Casa Nawal Alkal',
              cost: '\$400',
              currency: 'MXN'
          ),
          EventData(
              date: 'Daily',
              timestart: '19:00',
              event: 'Temazcalli Ceremony',
              eventSite: 'Casa Nawal Alkal',
              cost: '\$500',
              currency: 'MXN'
          ),
          EventData(
              date: 'Daily',
              timestart: '19:00',
              event: 'Temazcalli Ceremony',
              eventSite: 'Casa Nawal Alkal',
              cost: '\$600',
              currency: 'MXN'
          ),
          EventData(
              date: 'Daily',
              timestart: '19:00',
              event: 'Temazcalli Ceremony',
              eventSite: 'Casa Nawal Alkal',
              cost: '\$700',
              currency: 'MXN'
          ),
          EventData(
              date: 'Daily',
              timestart: '19:00',
              event: 'Temazcalli Ceremony',
              eventSite: 'Casa Nawal Alkal',
              cost: '\$700',
              currency: 'MXN'
          ),
          EventData(
              date: 'Daily',
              timestart: '19:00',
              event: 'Temazcalli Ceremony',
              eventSite: 'Casa Nawal Alkal',
              cost: '\$700',
              currency: 'MXN'
          ),
          EventData(
              date: 'Daily',
              timestart: '19:00',
              event: 'Temazcalli Ceremony',
              eventSite: 'Casa Nawal Alkal',
              cost: '\$700',
              currency: 'MXN'
          ),
          EventData(
              date: 'Daily',
              timestart: '19:00',
              event: 'Temazcalli Ceremony',
              eventSite: 'Casa Nawal Alkal',
              cost: '\$700',
              currency: 'MXN'
          ),
          EventData(
              date: 'Daily',
              timestart: '19:00',
              event: 'Temazcalli Ceremony',
              eventSite: 'Casa Nawal Alkal',
              cost: '\$700',
              currency: 'MXN'
          ),
          EventData(
              date: 'Daily',
              timestart: '19:00',
              event: 'Temazcalli Ceremony',
              eventSite: 'Casa Nawal Alkal',
              cost: '\$700',
              currency: 'MXN'
          ),
          EventData(
              date: 'Daily',
              timestart: '19:00',
              event: 'Temazcalli Ceremony',
              eventSite: 'Casa Nawal Alkal',
              cost: '\$700',
              currency: 'MXN'
          )
        ]
    );
    notifyListeners();
  }
}

class EventData {
  String date;
  String timestart;
  String event;
  String eventSite;
  String cost;
  String currency;

  EventData({
    required this.date,
    required this.timestart,
    required this.event,
    required this.eventSite,
    required this.cost,
    required this.currency
  });
}