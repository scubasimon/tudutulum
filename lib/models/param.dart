class Param {
  String? title;
  int? businessId;
  Order order = Order.alphabet;

  Param({this.title, this.businessId, this.order = Order.alphabet});
}

enum Order {
  alphabet, distance
}