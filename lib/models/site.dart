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