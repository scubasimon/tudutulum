import 'package:tudu/models/user.dart';

class Site {
  late String siteId;
  late int locationId;
  late String title;
  List<String> businessId = [];
  List<String> images = [];
  late String logo;
  late String description;
  late String moreInfo;
  late String advisory;
  List<int> amenities = [];
  late String amenitiesDescription;
  Map<WeekDays, String> times = {};
  late String timeOther;
  late String timeOtherDescription;
  List<Fee> fees = [];
  late String capacity;
  late String eventIcon;
  late String eventLink;
  late Location location;
  late String email;
  late String telephone;
  late String whatsapp;
  late String instagram;
  late String facebook;
  late String website;
  late String google;
  late bool visible;
  late String partnerId;

  Site(
      this.siteId,
      this.locationId,
      this.title,
      this.businessId,
      this.images,
      this.logo,
      this.description,
      this.moreInfo,
      this.advisory,
      this.amenities,
      this.amenitiesDescription,
      this.times,
      this.timeOther,
      this.timeOtherDescription,
      this.fees,
      this.capacity,
      this.eventIcon,
      this.eventLink,
      this.location,
      this.email,
      this.telephone,
      this.whatsapp,
      this.instagram,
      this.facebook,
      this.website,
      this.google,
      this.visible,
      this.partnerId,
      );

  Site.from(Map<String, dynamic> data) {
    siteId = data["siteid"] as String;
    locationId = data["locationid"] as int? ?? defaultLocationId;
    title = data["title"] as String? ?? "";
    images = data["images"] as List<String>? ?? [];
    logo = data["logo"] as String? ?? "";
    description = data["description"] as String? ?? "";
    moreInfo = data["moreinfo"] as String? ?? "";
    advisory = data["advisory"] as String? ?? "";

  }
}

enum WeekDays {
 monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

class Fee {
  String title;
  String description;

  Fee(this.title, this.description);
}

class Location {
  double latitude;
  double longitude;

  Location(this.latitude, this.longitude);
}