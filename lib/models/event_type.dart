class EventType {
  int eventId;
  String icon;
  int locationId;
  String type;
  int order;

  EventType(
      {
        required this.eventId,
        required this.icon,
        required this.locationId,
        required this.type,
        required this.order,
      });

  Map<String, dynamic> toJson() => {
    "eventid": eventId,
    "icon": icon,
    "locationid": locationId,
    "type": type,
    "order": order,
  };
}