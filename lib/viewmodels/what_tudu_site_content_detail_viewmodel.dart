import 'dart:async';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';

class WhatTuduSiteContentDetailViewModel extends BaseViewModel {
  static final WhatTuduSiteContentDetailViewModel _instance =
  WhatTuduSiteContentDetailViewModel._internal();

  factory WhatTuduSiteContentDetailViewModel() {
    return _instance;
  }

  WhatTuduSiteContentDetailViewModel._internal();

  final StreamController<String?> _siteContentDetailCoverController = BehaviorSubject<String?>();
  Stream<String?> get siteContentDetailCoverStream => _siteContentDetailCoverController.stream;

  String? siteContentDetailCover = "";

  List<String> listOpenTimes = [
    "9:30 - 17:30 Monday",
    "9:30 - 17:30 Tuesday",
    "9:30 - 17:30 Wednesday",
    "9:30 - 17:30 Thursday",
    "9:30 - 17:30 Friday",
    "9:30 - 17:30 Saturday",
    "9:30 - 17:30 Sunday",
  ];

  List<String> listFees = [
    "'FeesTitle1': 'FeesDetail'1'",
    "'FeesTitle2': 'FeesDetail'2'",
    "'FeesTitle3': 'FeesDetail'3'",
  ];

  @override
  FutureOr<void> init() {

  }

  void setSiteContentDetailCover(String input) {
    siteContentDetailCover = input;
    notifyListeners();
  }

  void showData() {
    _siteContentDetailCoverController.sink.add(siteContentDetailCover);
    notifyListeners();
  }
}