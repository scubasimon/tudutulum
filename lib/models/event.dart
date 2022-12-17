import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  int eventid;
  bool active;
  String? image;
  String title;
  String description;
  String cost;
  String currency;
  Timestamp dateend;
  Timestamp datestart;
  String? booking;
  String primaryType;
  List<int>? eventTypes;
  Map<String, String>? contacts;
  double? locationLat;
  double? locationLon;


  Event(
      {
        required this.eventid,
        required this.active,
        this.image,
        required this.title,
        required this.description,
        required this.cost,
        required this.currency,
        required this.dateend,
        required this.datestart,
        this.booking,
        required this.primaryType,
        this.eventTypes,
        this.contacts,
        this.locationLat,
        this.locationLon,
      });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      "eventid": eventid,
      "active": active,
      "image": image,
      "title": title,
      "description": description,
      "cost": cost,
      "currency": currency,
      "dateend": dateend,
      "datestart": datestart,
      "booking": booking,
      "primaryType": primaryType,
      "eventTypes": eventTypes,
      "contacts": contacts,
      "locationLat": locationLat,
      "locationLon": locationLon,
    };

    return result;
  }
}