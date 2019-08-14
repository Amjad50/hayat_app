
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// return the int in a String with a fixed size
/// if its less, it will append leading zeros
/// if its more, it will trunc from the left
/// else: it will just return the String of int.
String fixedSizeInt(int value, int size) {
  if (value < 0) return "-" + fixedSizeInt(-value, size - 1);
  String s = value.toString();
  if (s.length < size)
    return ("0" * (size - s.length)) + s;
  else
    return s.substring(s.length - size);
}

/// this is used for the database access (FireStore)
String getTasksDBDocumentName(DateTime date) {
  return "${fixedSizeInt(date.year, 4)}${fixedSizeInt(date.month, 2)}${fixedSizeInt(date.day, 2)}";
}

/// return the DateTime object back from a String format
DateTime getDateFromDBDocumentName(String name) {
  if (name.length != 4 + 2 + 2) return null;
  return DateTime.tryParse(name);
}

/// return the standard date format in this app from a date.
String dateToString(DateTime date, [DateTime now, bool noDay = false]) {
  if (now == null) now = DateTime.now();

  final year = date.year == now.year ? "" : "y";
  final day = noDay ? "" : "Ed";

  return DateFormat("${year}MMM${day}").format(date);
}

/// return a String representation of a date relevant to today.
String getDayDisplayString(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  // future
  if (diff.isNegative) return "Error";

  switch (diff.inDays) {
    case 0:
      return "Today";
    case 1:
      return "Yesterday";
    default:
      return dateToString(date);
  }
}

/// return a widget which display a loading circle
Widget buildLoadingWidget() {
  return const Center(child: const CircularProgressIndicator());
}

/// return an appbar that works with heros
/// the issue was during a hero animation, the hero animated 
/// widget will get on top of the appbar,
/// when wrapping the appbar with a hero, the issue is fixed as the
/// appbar on top now.
PreferredSize makeAppBarHeroFix(AppBar _bar) {
  return PreferredSize(
    child: Hero(
      child: _bar,
      tag: AppBar,
    ),
    preferredSize: AppBar().preferredSize,
  );
}

/// convert the String #AARRGGBB or #RRGGBB to a Color object
Color hexColor(String s) {
  s = s.toUpperCase().replaceAll("#", "");
  if (s.length > 8)
    s = s.substring(0, 8);
  else
    s = "F" * (8 - s.length) + s;

  return Color(int.parse(s, radix: 16));
}

/// As the article page is stored as an array of lines in firestore
/// this function returns the whole String article
String mergeMarkdownArray(List<dynamic> markdownList) {
  return markdownList
      .reduce((a1, a2) => (a1.toString() + '\n' + a2.toString()))
      .replaceAll('\\n', '\n');
}

/// same as dateToString, covert a timestamp instead of dateTime
String parseTimestamp(Timestamp time) {
  final dateTime = time.toDate();
  return dateToString(dateTime);
}
