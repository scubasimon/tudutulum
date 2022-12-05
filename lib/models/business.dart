class Business {
  int businessid;
  int locationid;
  String type;

  Business(
      {
        required this.businessid,
        required this.locationid,
        required this.type,
      });

  Map<String, dynamic> toJson() => {
    "businessid": businessid,
    "locationid": locationid,
    "type": type
  };
}