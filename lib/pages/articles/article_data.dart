import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ArticleData {
  ArticleData({
    @required this.title,
    @required this.mainTitle,
    @required this.textColor,
    @required this.img,
    @required this.articlePage,
    @required this.tags,
    @required this.heroTag,
    @required this.date,
    star = false,
  }) : star = ValueNotifier<bool>(star);

  final String title;
  final List<dynamic> mainTitle;
  final String textColor;
  final String img;
  final DocumentReference articlePage;
  final List<dynamic> tags;
  final String heroTag;
  final Timestamp date;

  ValueNotifier<bool> star;
}
