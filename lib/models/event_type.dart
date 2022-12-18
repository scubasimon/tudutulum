class EventType {
  int eventId;
  String icon;
  int locationId;
  String type;

  EventType(
      {
        required this.eventId,
        required this.icon,
        required this.locationId,
        required this.type,
      });

  Map<String, dynamic> toJson() => {
    "eventid": eventId,
    "icon": icon,
    "locationid": locationId,
    "type": type,
  };
}