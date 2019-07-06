import 'package:flutter/material.dart';

class ArticleData {
  ArticleData(
      {@required this.title,
      @required this.textColor,
      @required this.img,
      @required this.articleID,
      this.tags,
      @required this.heroTag});

  final String title;
  final String textColor;
  final String img;
  final String articleID;
  final List<String> tags;
  final String heroTag;
}
