import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

PreferredSize makeAppBarHeroFix(AppBar _bar) {
  return PreferredSize(
    child: Hero(
      child: _bar,
      tag: AppBar,
    ),
    preferredSize: AppBar().preferredSize,
  );
}

Color hexColor(String s) {
  s = s.toUpperCase().replaceAll("#", "");
  if (s.length > 8)
    s = s.substring(0, 8);
  else
    s = "F" * (8 - s.length) + s;

  return Color(int.parse(s, radix: 16));
}

String mergeMarkdownArray(List<dynamic> markdownList) {
  return markdownList
      .reduce((a1, a2) => (a1.toString() + '\n' + a2.toString()))
      .replaceAll('\\n', '\n');
}

String parseTimestamp(Timestamp time) {
  final dateTime = time.toDate();

  return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
}
