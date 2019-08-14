import 'package:hayat_app/utils.dart';
import 'package:intl/intl.dart';

class Score {
  static Score none = Score(DateTime.fromMillisecondsSinceEpoch(0), 0);
  static Score noneMonth = Score.month(DateTime.fromMillisecondsSinceEpoch(0), 0);

  Score.month(this._date, this._score) : _isMonth = true;

  Score(this._date, this._score) : _isMonth = false;

  final DateTime _date;
  final bool _isMonth;
  double _score;

  double get score => _score;

  DateTime get date {
    if (_isMonth)
      return DateTime(_date.year, _date.month);
    else
      return DateTime(_date.year, _date.month, _date.day);
  }

  String get dateString {
    if (_isMonth)
      return DateFormat.yMMMM().format(date);
    else
      return dateToString(date);
  }

  Score max(Score other) {
    if(this._score >= other._score)
      return this;
    return other;
  }
}
