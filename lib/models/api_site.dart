class APISite {
  late String sId;
  late String createdOn;
  late String name;
  late String shortName;
  late String lastPublished;
  late String previewUrl;
  late String timezone;
  late String database;

  APISite(
      {
        required this.sId,
        required this.createdOn,
        required this.name,
        required this.shortName,
        required this.lastPublished,
        required this.previewUrl,
        required this.timezone,
        required this.database
      }
      );

  APISite.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    createdOn = json['createdOn'];
    name = json['name'];
    shortName = json['shortName'];
    lastPublished = json['lastPublished'];
    previewUrl = json['previewUrl'];
    timezone = json['timezone'];
    database = json['database'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['createdOn'] = this.createdOn;
    data['name'] = this.name;
    data['shortName'] = this.shortName;
    data['lastPublished'] = this.lastPublished;
    data['previewUrl'] = this.previewUrl;
    data['timezone'] = this.timezone;
    data['database'] = this.database;
    return data;
  }
}