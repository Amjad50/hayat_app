import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hayat_app/DB/db_task.dart';
import 'package:hayat_app/DB/firestore_handler.dart';
import 'package:hayat_app/pages/statistics/score.dart';
import 'package:hayat_app/pages/tasks/tasks_collection_types.dart';
import 'package:hayat_app/utils.dart';
import 'package:intl/intl.dart';

const TASKS_SUBCOLLECTION = "tasks";
const USERS_COLLECTION = "users";
const USER_TASKS_TYPES = "tasks_types";

class StatisticsHandler {
  StatisticsHandler({@required this.onChange});

  static const DEFAULT_TIMEOUT_DURATION = Duration(seconds: 7);

  final void Function() onChange;

  int userTypesLength;

  bool _isLoading = false;
  bool _doneInit = false;
  bool _isError = false;

  String _message = "";

  final List<Score> _daysScores = [];
  final List<Score> _monthsScores = [];

  List<Score> get daysScores => _doneInit ? _daysScores : [];
  List<Score> get monthsScores => _doneInit ? _monthsScores : [];

  String get message => _message;

  bool get isLoading => _isLoading;
  bool get isError => _isError;

  Score get topDay {
    if (!_doneInit || _daysScores.isEmpty) return Score.none;
    return _daysScores.reduce((a, b) => a.max(b));
  }

  Score get topMonth {
    if (!_doneInit || _monthsScores.isEmpty) return Score.noneMonth;
    return _monthsScores.reduce((a, b) => a.max(b));
  }

  /// return true if the init function should stop and exit
  /// just an internal solution
  bool _update(String newMessage) {
    if (_doneInit) return true;
    print(newMessage);
    _message = newMessage;
    onChange();
    return false;
  }

  Future<void> reInit() async {
    _doneInit = true;
    _message = "";
    _daysScores.clear();
    _monthsScores.clear();
    await init();
  }

  Future<void> init() async {
    _isLoading = true;
    _doneInit = false;

    userTypesLength = FireStoreHandler.instance.user.tasksTypes.length;
    
    final dateFormatter = DateFormat('yyyyMMdd');
     if (_update("processing months data")) return;
    await FireStoreHandler.instance.processAllUserTasks<void>((date, tasklist, stop) {
        if(tasklist == null)
          return;
        
        if(_update("processing document: ${dateFormatter.format(date)}")) stop();
        _daysScores.add(Score(date, _computeScore(tasklist)));
    }, DEFAULT_TIMEOUT_DURATION, _timedout);

    if (_update("processing months data")) return;
    _computeMonths();

    _isLoading = false;
    _doneInit = true;
  }

  QuerySnapshot _timedout() {
    _isLoading = false;
    _doneInit = true;
    _isError = true;
    _message =
        "Connection Timed out!\nMight be because there is no internet connection.";
    onChange();
    return null;
  }

  void dispose() {
    _isLoading = false;
    _doneInit = true;
  }

  int _computeScore(final List<DBTask> tasks) {
    int finalScore = 0;

    tasks.forEach((e) {
      finalScore += _computeTaskScore(e);
    });

    return finalScore;
  }

  int _computeTaskScore(DBTask task) {
    double finalResult = 1;

    finalResult *= task.done / 10;
    finalResult *= task.durationH;

    if (!(userTypesLength == 0 || task.typeIndex == -1)) {
      finalResult *= (userTypesLength - task.typeIndex) / userTypesLength;
    }

    return finalResult.round();
  }

  void _computeMonths() {
    if (_daysScores.isEmpty) return;

    // because they are sorted,
    // the work is easy
    DateTime lastMonth = _daysScores[0].date;
    int score = 0;

    for (final child in _daysScores) {
      // different month
      if (!(child.date.month == lastMonth.month &&
          child.date.year == lastMonth.year)) {
        _monthsScores.add(Score.month(lastMonth, score));
        score = 0;
        lastMonth = child.date;
      }
      score += child.score;
    }
    _monthsScores.add(Score.month(lastMonth, score));
  }
}
