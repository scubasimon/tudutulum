class Amenity {
  int amenityId;
  String title;
  String description;
  String icon;

  Amenity(
      {
        required this.amenityId,
        required this.title,
        required this.description,
        required this.icon,
      });

  Map<String, dynamic> toJson() => {
    "amenityId": amenityId,
    "description": description,
    "icon": icon,
    "title": title
  };
}