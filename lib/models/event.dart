import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tudu/models/site.dart';

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
  Map<String, dynamic>? contacts;
  double? locationLat;
  double? locationLon;
  List<Site>? sites;

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
      "sites": sites?.map((e) => e.toJson()),
    };

    return result;
  }

  factory Event.fromClone(Event objectClone){
    return Event(
      eventid: objectClone.eventid,
      active: objectClone.active,
      image: objectClone.image,
      title: objectClone.title,
      description: objectClone.description,
      eventDescriptions: objectClone.eventDescriptions,
      cost: objectClone.cost,
      currency: objectClone.currency,
      moreInfo: objectClone.moreInfo,
      dateend: objectClone.dateend,
      datestart: objectClone.datestart,
      booking: objectClone.booking,
      primaryType: objectClone.primaryType,
      eventTypes: objectClone.eventTypes,
      listEventDayInWeek: objectClone.listEventDayInWeek,
      repeating: objectClone.repeating,
      contacts: objectClone.contacts,
      locationLat: objectClone.locationLat,
      locationLon: objectClone.locationLon,
      sites: objectClone.sites
    );
  }

  Map<int, bool>? getEventDayInWeek() {
    return listEventDayInWeek?.map((key, value) {
      int k = -1;
      switch (key.toLowerCase()) {
        case "monday":
          k = DateTime.monday;
          break;
        case "tuesday":
          k = DateTime.tuesday;
          break;
        case "wednesday":
          k = DateTime.wednesday;
          break;
        case "thursday":
          k = DateTime.thursday;
          break;
        case "friday":
          k = DateTime.friday;
          break;
        case "saturday":
          k = DateTime.saturday;
          break;
        case "sunday":
          k = DateTime.sunday;
      }
      return MapEntry(k, value);
    });
  }
}