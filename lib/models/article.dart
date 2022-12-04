import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  int articleId;
  String banner;
  String title;

  Article(
      {
        required this.articleId,
        required this.banner,
        required this.title,
      });

  Map<String, dynamic> toJson() => {
    // "articleId": articleId,
  };
}