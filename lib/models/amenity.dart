class Amenity {
  int amenitiyId;
  String title;
  String description;
  String icon;

  Amenity(
      {
        required this.amenitiyId,
        required this.title,
        required this.description,
        required this.icon,
      });

  Map<String, dynamic> toJson() => {
    "amenitiesid": amenitiyId,
    "description": description,
    "icon": icon,
    "title": title
  };
}