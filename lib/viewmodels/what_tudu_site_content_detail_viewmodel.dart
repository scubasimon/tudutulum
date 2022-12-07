import 'dart:async';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';

import '../models/site.dart';

class WhatTuduSiteContentDetailViewModel extends BaseViewModel {
  static final WhatTuduSiteContentDetailViewModel _instance =
  WhatTuduSiteContentDetailViewModel._internal();

  factory WhatTuduSiteContentDetailViewModel() {
    return _instance;
  }

  WhatTuduSiteContentDetailViewModel._internal();

  final StreamController<Site> _siteContentDetailController = BehaviorSubject<Site>();
  Stream<Site> get siteContentDetailStream => _siteContentDetailController.stream;

  late Site siteContentDetail;

  @override
  FutureOr<void> init() {

  }

  void setSiteContentDetailCover(Site input) {
    siteContentDetail = input;
    notifyListeners();
  }
}