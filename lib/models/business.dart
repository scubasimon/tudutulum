class Business {
  int businessid;
  int locationid;
  String type;
  String icon;
  int order;

  Business(
      {
        required this.businessid,
        required this.locationid,
        required this.type,
        required this.icon,
        required this.order,
      });

  Map<String, dynamic> toJson() => {
    "businessid": businessid,
    "locationid": locationid,
    "type": type,
    "icon": icon,
    "order": order
  };
}