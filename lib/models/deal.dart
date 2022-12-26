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
    if (data["startdate"].runtimeType == int) {
      startDate = DateTime.fromMillisecondsSinceEpoch(data["startdate"] as int);
    } else {
      startDate = (data["startdate"] as Timestamp).toDate();
    }
    if (data["enddate"].runtimeType == int) {
      endDate = DateTime.fromMillisecondsSinceEpoch(data["enddate"] as int);
    } else {
      endDate = (data["enddate"] as Timestamp).toDate();
    }
    terms = data["terms"] as String?;
    title = data["title"] as String? ?? "";
    titleShort = data["titleshort"] as String? ?? "";
    logo = data["logo"] as String? ?? "";
    businesses = (data["business"] as List<dynamic>? ?? []).map((e) => e as int).toList();

    var site = data["site"] as Map<String, dynamic>? ?? {};
    final siteContent = site["siteContent"] as Map<String, dynamic>? ?? {};
    if (site["titles"] != null) {
      this.site = Site(
        active: site["active"],
        images: (site["image"] as List<dynamic>? ?? []).map((e) => e as String).toList(),
        siteId: site["siteid"] as int,
        titles: site["titles"],
        subTitle: site["subTitle"],
        business:  (site["business"] as List<dynamic>? ?? []).map((e) => e as int).toList(),
        siteContent: SiteContent(
          description: siteContent["contentDescription"],
          moreInformation: siteContent["moreInformation"],
          advisory: siteContent["advisory"],
          amenities: (siteContent["amenities"] as List<dynamic>? ??[]).map((e) => e as int).toList(),
          amentityDescriptions: (siteContent["amentityDescriptions"] as List<dynamic>? ?? []).map((e) => e as String).toList(),
          openingTimes: siteContent["openingTimes"],
          fees: siteContent["fees"],
          capacity: siteContent["capacity"],
          eventIcons: (siteContent["eventIcons"] as List<dynamic>? ?? []).map((e) => e as String).toList(),
          eventLinks: (siteContent["eventLinks"] as List<dynamic>? ?? []).map((e) => e as String).toList(),
          getIntouch: siteContent["getIntouch"],
          logo: siteContent["logo"],
          partner: siteContent["partner"]
        ),
        locationLat: site["locationLat"] as double?,
        locationLon: site["locationLon"] as double?,
      );
    } else {
      this.site = Site(
        active: true,
        images: [],
        siteId: site["siteid"] as int,
        titles: {"title": site["title"] as String? ?? "", "contentTitle": site["contentTitle"] as String? ?? ""},
        subTitle: "",
        business: [],
        siteContent: SiteContent(),
        locationLat: site["locationLat"] as double?,
        locationLon: site["locationLon"] as double?,
      );
    }

  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> siteMap = {
      "dealId": site.dealId,
      "active": site.active,
      "image": site.images,
      "siteid": site.siteId,
      "titles": site.titles,
      "subTitle": site.subTitle,
      "business": site.business,
      "locationLat": site.locationLat,
      "locationLon": site.locationLon,
      "rating": site.rating,
      "siteContent": site.siteContent.toJson(),
    };
    Map<String, dynamic> result = {
      "dealsid": dealsId,
      "active": active,
      "description": description,
      "images": images,
      "startdate": startDate.millisecondsSinceEpoch,
      "enddate": endDate.millisecondsSinceEpoch,
      "terms": terms,
      "title": title,
      "titleshort": titleShort,
      "logo": logo,
      "business": businesses,
      "site": siteMap,
    };
    return result;
  }
}
