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

String dateToString(DateTime date, [DateTime now]) {
  if (now == null) now = DateTime.now();
  
  final year = date.year == now.year ? "" : "y";

  return DateFormat("${year}MMMEd").format(date);
}

String getDayDisplayString(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  // future
  if (diff.isNegative) return "Error";
  print(date);
  print(diff.inDays);
  switch (diff.inDays) {
    case 0:
      return "Today";
    case 1:
      return "Yesterday";
    default:
      return dateToString(date);
  }
}
