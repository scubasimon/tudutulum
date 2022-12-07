import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  int articleId;
  String banner;
  String title;
  double rating;
  List<int> business;
  Map<String, List<String>> listContent;

  Article(
      {
        required this.articleId,
        required this.banner,
        required this.title,
        required this.rating,
        required this.business,
        required this.listContent,
      });

  Map<String, dynamic> toJson() => {
    // "articleId": articleId,
  };
}