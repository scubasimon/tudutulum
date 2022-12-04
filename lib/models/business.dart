class Business {
  int businessId;
  int locationid;
  String type;

  Business(
      {
        required this.businessId,
        required this.locationid,
        required this.type,
      });

  Map<String, dynamic> toJson() => {
    "businessId": businessId,
    "locationid": locationid,
    "type": type
  };
}