class Subscription {
  String id;
  String name;
  double price;
  SubscriptionType type;
  bool selection = false;

  Subscription(this.id, this.name, this.price, this.type, {this.selection = false});
}

enum SubscriptionType {
  year, month, week
}