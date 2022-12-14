class Param {
  String? title;
  int? businessId;
  Order? order = Order.distance;
  bool refresh = false;

  Param({this.title, this.businessId, this.order = Order.distance, this.refresh = false});
}

enum Order {
  alphabet, distance
}