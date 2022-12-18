class Subscription {
  String id;
  String name;
  double price;
  String priceString;
  SubscriptionType type;
  bool selection = false;

  Subscription(this.id, this.name, this.price, this.priceString, this.type, {this.selection = false});
}

enum SubscriptionType {
  year, month, week
}