import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ArticleData {
  ArticleData(
      {@required this.title,
      @required this.textColor,
      @required this.img,
      @required this.articlePage,
      @required this.tags,
      @required this.heroTag});

  final String title;
  final String textColor;
  final String img;
  final DocumentReference articlePage;
  // TODO: use tags
  final List<dynamic> tags;
  final String heroTag;
}
