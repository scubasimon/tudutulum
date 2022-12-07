import 'package:cloud_firestore/cloud_firestore.dart';

class Site {
  bool active;
  int siteId;
  List<String> images;
  int? dealId;
  String title;
  String subTitle;
  List<int> business;
  GeoPoint location;
  SiteContent siteContent;
  double rating;

  Site(
      {
        this.dealId,
        required this.active,
        required this.images,
        required this.siteId,
        required this.title,
        required this.subTitle,
        required this.business,
        required this.location,
        required this.siteContent,
        required this.rating,
      });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      "dealId": dealId,
      "active": active,
      "image": images,
      "siteid": siteId,
      "title": title,
      "subTitle": subTitle,
      "business": business,
      "location": location,
      "rating": rating,
    };

    var siteContentJson = siteContent.toJson();
    for (var data in siteContentJson.keys.toList()) {
      result[data] = siteContentJson[data];
    }

    return result;
  }
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
    "contentTitle": title,
    "contentDescription": description,
    "moreInformation": moreInformation,
    "advisory": advisory,
    "amenities": amenities,
    "amentityDescriptions": amentityDescriptions,
    "openingTimes": openingTimes,
    "fees": fees,
    "capacity": capacity,
    "eventIcons": eventIcons,
    "eventLinks": eventLinks,
    "getIntouch": getIntouch,
    "logo": logo,
    "partner": partner,
  };
}