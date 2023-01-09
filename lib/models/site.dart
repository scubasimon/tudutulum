
import '../utils/func_utils.dart';

class Site {
  late int siteId;
  late bool active;
  late String title;
  late List<String> images;
  int? dealId;
  late String subTitle;
  List<int> business = [];
  double? locationLat;
  double? locationLon;
  late SiteContent siteContent;

  Site(
      {
        this.dealId,
        required this.title,
        required this.active,
        required this.images,
        required this.siteId,
        required this.subTitle,
        required this.business,
        this.locationLat,
        this.locationLon,
        required this.siteContent,
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
      "locationLat": locationLat,
      "locationLon": locationLon,
    };

    var siteContentJson = siteContent.toJson();
    for (var data in siteContentJson.keys.toList()) {
      result[data] = siteContentJson[data];
    }

    return result;
  }

  Site.from(Map<String, dynamic> data) {
    images = FuncUlti.getListStringFromListDynamic(data["image"]);
    active = data["active"];
    siteId = data["siteid"];
    dealId = (data["dealId"] != null) ? data["dealId"] : null;
    title = data["title"];
    subTitle = data["subTitle"] as String;
    business = FuncUlti.getListIntFromListDynamic(data["business"]);
    locationLat = (data["locationLat"] != null) ? data["locationLat"]: null;
    locationLon = (data["locationLon"] != null) ? data["locationLon"]: null;
    siteContent = SiteContent(
    description: (data["contentDescription"] != null) ? data["contentDescription"] : null,
    moreInformation: (data["moreInformation"] != null) ? data["moreInformation"] : null,
    advisory: (data["advisory"] != null) ? data["advisory"] : null,
    amenities: (data["amenities"] != null)
    ? FuncUlti.getListIntFromListDynamic(data["amenities"])
        : null,
    amentityDescriptions: (data["amentityDescriptions"] != null)
    ? FuncUlti.getListStringFromListDynamic(data["amentityDescriptions"])
        : null,
    openingTimes: (data["openingTimes"] != null)
    ? FuncUlti.getMapStringStringFromStringDynamic(data["openingTimes"])
        : null,
    fees:
    (data["fees"] != null) ? FuncUlti.getMapStringListFromStringDynamic(data["fees"]) : null,
    capacity: (data["capacity"] != null) ? data["capacity"] : data["capacity"],
    eventIcons: (data["eventIcons"] != null)
    ? FuncUlti.getListStringFromListDynamic(data["eventIcons"])
        : null,
    eventLinks: (data["eventLinks"] != null)
    ? FuncUlti.getListStringFromListDynamic(data["eventLinks"])
        : null,
    getIntouch: (data["getIntouch"] != null)
    ? FuncUlti.getMapStringStringFromStringDynamic(data["getIntouch"])
        : null,
    logo: (data["logo"] != null) ? data["logo"] : null,
    partner: (data["partner"] != null) ? data["partner"] : null,
    );
  }
}

class SiteContent {
  String? description;
  String? moreInformation;
  String? advisory;
  List<int>? amenities;
  List<String>? amentityDescriptions;
  Map<String, String>? openingTimes;
  Map<String, List<String>>? fees;
  String? capacity;
  List<String>? eventIcons;
  List<String>? eventLinks;
  Map<String, String>? getIntouch;
  String? logo;
  int? partner;

  SiteContent(
      {
        this.description,
        this.moreInformation,
        this.advisory,
        this.amenities,
        this.amentityDescriptions,
        this.openingTimes,
        this.fees,
        this.capacity,
        this.eventIcons,
        this.eventLinks,
        this.getIntouch,
        this.logo,
        this.partner,
      });

  Map<String, dynamic> toJson() => {
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