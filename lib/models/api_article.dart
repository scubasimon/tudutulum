class APIArticle {
  late String sId;
  late String lastUpdated;
  late String createdOn;
  late String name;
  late String slug;
  late String singularName;

  APIArticle(
      {
        required this.sId,
        required this.lastUpdated,
        required this.createdOn,
        required this.name,
        required this.slug,
        required this.singularName});

  APIArticle.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    lastUpdated = json['lastUpdated'];
    createdOn = json['createdOn'];
    name = json['name'];
    slug = json['slug'];
    singularName = json['singularName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['lastUpdated'] = this.lastUpdated;
    data['createdOn'] = this.createdOn;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['singularName'] = this.singularName;
    return data;
  }
}