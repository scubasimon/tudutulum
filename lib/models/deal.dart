import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Deal {
  late int dealsId;
  late bool active;
  String? description;
  List<String> images = [];
  late int siteId;
  late DateTime startDate;
  late DateTime endDate;
  String? terms;
  late String title;
  late String titleShort;
  late String logo;
  late List<int> businesses = [];

  Deal(this.dealsId, this.active, this.description, this.images, this.siteId, this.startDate, this.endDate, this.terms, this.title, this.titleShort, this.logo);

  Deal.from(Map<String, dynamic> data) {
    dealsId = data["dealsid"] as int? ?? 0;
    active = data["active"] as bool? ?? false;
    description = data["description"] as String?;
    images = (data["images"] as List<dynamic>? ?? []).map((e) => e as String).toList();
    var date = data["startdate"] as Timestamp;
    startDate = date.toDate();
    date = data["enddate"] as Timestamp;
    endDate = date.toDate();
    terms = data["terms"] as String?;
    title = data["title"] as String? ?? "";
    titleShort = data["titleshort"] as String? ?? "";
    logo = data["logo"] as String? ?? "";
    businesses = (data["business"] as List<dynamic>? ?? []).map((e) => e as int).toList();
  }
}
