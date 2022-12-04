import 'package:cloud_firestore/cloud_firestore.dart';

class Site {
  int siteId;
  String banner;
  bool haveDeals;
  String title;
  String subTitle;
  List<int> business;
  GeoPoint location;
  SiteContent siteContent;

  Site(
      {
        required this.banner,
        required this.siteId,
        required this.haveDeals,
        required this.title,
        required this.subTitle,
        required this.business,
        required this.location,
        required this.siteContent,
      });

  Map<String, dynamic> toJson() => {
    // "id": id,
  };
}

class SiteContent {
  String title;
  String description;
  String moreInformation;
  String advisory;
  List<String> openingTimes;
  Map<String, List<String>> fees;
  String capacity;
  List<int> eventsAndExps;
  Map<String, String> getIntouch;
  String logo;
  int partner;

  SiteContent(
      {
        required this.title,
        required this.description,
        required this.moreInformation,
        required this.advisory,
        required this.openingTimes,
        required this.fees,
        required this.capacity,
        required this.eventsAndExps,
        required this.getIntouch,
        required this.logo,
        required this.partner,
      });

  Map<String, dynamic> toJson() => {
    // "id": id,
  };
}