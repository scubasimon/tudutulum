class Location {
  String location;
  int locationId;
  String logo;

  Location(
      {
        required this.location,
        required this.locationId,
        required this.logo,
      });

  Map<String, dynamic> toJson() => {
    "location": location,
    "locationId": locationId,
    "logo": logo
  };
}