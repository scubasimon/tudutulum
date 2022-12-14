import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tudu/models/site.dart';

class Deal {
  late int dealsId;
  late bool active;
  String? description;
  List<String> images = [];
  late Site site;
  late DateTime startDate;
  late DateTime endDate;
  String? terms;
  late String title;
  late String titleShort;
  late String logo;
  late List<int> businesses = [];

  Deal(this.dealsId, this.active, this.description, this.images, this.site, this.startDate, this.endDate, this.terms, this.title, this.titleShort, this.logo);

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
    var site = data["site"] as Map<String, dynamic>? ?? {};

    this.site = Site(
        active: true,
        images: [],
        siteId: site["siteid"] as int,
        title: site["title"] as String,
        subTitle: "",
        business: [],
        siteContent: SiteContent(),
        locationLat: site["locationLat"] as double?,
        locationLon: site["locationLon"] as double?,
    );
  }
}
