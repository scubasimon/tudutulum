import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String eventid;
  bool active;
  String? image;
  String title;
  String description;
  List<String>? eventDescriptions;
  String cost;
  String currency;
  String moreInfo;
  Timestamp dateend;
  Timestamp datestart;
  String? booking;
  String primaryType;
  List<int>? eventTypes;
  Map<String, bool>? listEventDayInWeek;
  bool? repeating;
  Map<String, String>? contacts;
  double? locationLat;
  double? locationLon;
  List<int>? sites;


  Event(
      {
        required this.eventid,
        required this.active,
        this.image,
        required this.title,
        required this.description,
        this.eventDescriptions,
        required this.cost,
        required this.currency,
        required this.moreInfo,
        required this.dateend,
        required this.datestart,
        this.booking,
        required this.primaryType,
        this.eventTypes,
        this.listEventDayInWeek,
        this.repeating,
        this.contacts,
        this.locationLat,
        this.locationLon,
        this.sites,
      });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      "eventid": eventid,
      "active": active,
      "image": image,
      "title": title,
      "description": description,
      "tableDescriptions": eventDescriptions,
      "cost": cost,
      "currency": currency,
      "moreinfo": moreInfo,
      "dateend": dateend.millisecondsSinceEpoch,
      "datestart": datestart.millisecondsSinceEpoch,
      "booking": booking,
      "primarytype": primaryType,
      "eventtypes": eventTypes,
      "listEventDayInWeek": listEventDayInWeek,
      "repeating": repeating,
      "contacts": contacts,
      "locationLat": locationLat,
      "locationLon": locationLon,
      "sites": sites,
    };

    return result;
  }
}