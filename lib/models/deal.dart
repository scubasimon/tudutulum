import 'package:tudu/models/site.dart';

class Deal {
  late String id;
  late Site site;
  late String title;
  late String description;
  late String terms;
  late List<String> images;

  Deal(this.id, this.site, this.title, this.description, this.terms, this.images);

  Deal.from(Map<String, dynamic> data) {
    id = data["id"] as String;
    title = data["title"] as String;
    description = data["description"] as String;
    terms = data["terms"] as String;
    images = data["images"] as List<String>;
  }
}