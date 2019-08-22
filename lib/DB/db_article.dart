import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hayat_app/DB/base_db_type.dart';
import 'package:hayat_app/DB/firestore_handler.dart';

const TITLE = 'title';
const IMG = 'img';
const TEXTCOLOR = 'textColor';
const TAGS = 'tags';
const PAGEREF = 'page';
const DATE = 'date';

class DBArticle extends BaseDBType {
  DBArticle(
    this.baseRef, {
    @required this.title,
    @required this.textColor,
    @required this.img,
    @required this.articlePage,
    @required this.tags,
    @required this.date,
    bool star = false,
  }) : star = ValueNotifier<bool>(star);
  factory DBArticle.fromMap(
      DocumentReference baseRef, Map<String, dynamic> data, bool star) {
    data = fix(data);

    return DBArticle(baseRef,
        articlePage: data[PAGEREF],
        title: data[TITLE],
        textColor: data[TEXTCOLOR],
        img: data[IMG],
        tags: data[TAGS],
        date: data[DATE],
        star: star);
  }

  final String title;
  final String textColor;
  final String img;
  final DocumentReference articlePage;
  final List<String> tags;
  final Timestamp date;
  final DocumentReference baseRef;

  ValueNotifier<bool> star;

  @override
  Map<String, dynamic> toMap() {
    // TODO: should this be empty? as it is not used.
    return {};
  }

  static Map<String, dynamic> fix(Map<String, dynamic> data) {
    // TITLE
    if (!(data.containsKey(TITLE) && (data[TITLE] is String)))
      data[TITLE] = 'null';

    // IMG
    if (!(data.containsKey(IMG) && (data[IMG] is String)))
      data[IMG] =
          'https://images.pexels.com/photos/949587/pexels-photo-949587.' +
              'jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500';

    // TEXTCOLOR
    if (!(data.containsKey(TEXTCOLOR) && (data[TEXTCOLOR] is String)))
      data[TEXTCOLOR] = "#ffffffff";

    // PAGEREF
    if (!(data.containsKey(PAGEREF) && (data[PAGEREF] is DocumentReference)))
      data[PAGEREF] = Firestore.instance
          .collection(ARTICLES_PAGES_COLLECTION)
          .document('default');

    // TAGS
    if (data.containsKey(TAGS) && (data[TAGS] is List<dynamic>))
      data[TAGS] = List<String>.from(data[TAGS].cast<String>());
    else
      data[TAGS] = <String>[];

    // DATE
    if (!(data.containsKey(DATE) && (data[DATE] is Timestamp)))
      data[DATE] = Timestamp.now();

    return data;
  }
}
