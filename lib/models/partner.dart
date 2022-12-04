import 'package:cloud_firestore/cloud_firestore.dart';

class Partner {
  int partnerId;
  String icon;
  String link;
  String name;

  Partner(
      {
        required this.partnerId,
        required this.icon,
        required this.link,
        required this.name,
      });

  Map<String, dynamic> toJson() => {
    // "partnerId": partnerId,
  };
}