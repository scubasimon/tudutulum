import 'package:cloud_firestore/cloud_firestore.dart';

class Site {
  int siteId;
  List<String> images;
  bool haveDeals;
  String title;
  String subTitle;
  List<int> business;
  GeoPoint location;
  SiteContent siteContent;

  Site(
      {
        required this.images,
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
  List<int> amenities;
  List<String> amentityDescriptions;
  Map<String, String> openingTimes;
  Map<String, List<String>> fees;
  String capacity;
  List<String> eventIcons;
  List<String> eventLinks;
  Map<String, String> getIntouch;
  String logo;
  int partner;

  SiteContent(
      {
        required this.title,
        required this.description,
        required this.moreInformation,
        required this.advisory,
        required this.amenities,
        required this.amentityDescriptions,
        required this.openingTimes,
        required this.fees,
        required this.capacity,
        required this.eventIcons,
        required this.eventLinks,
        required this.getIntouch,
        required this.logo,
        required this.partner,
      });

  Map<String, dynamic> toJson() => {
    // "id": id,
  };
}