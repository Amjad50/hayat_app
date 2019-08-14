import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hayat_app/pages/statistics/score.dart';
import 'package:hayat_app/pages/tasks/task_data.dart';
import 'package:hayat_app/utils.dart';

const TASKS_SUBCOLLECTION = "tasks";
const USERS_COLLECTION = "users";

class StatisticsHandler {
  StatisticsHandler({@required this.uid});

  final String uid;
  bool _isLoading = false;
  bool _doneInit = false;
  bool _isError = false;

  String _message = "";

  List<Score> _daysScores = [];
  List<Score> _monthsScores = [];

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

  Future<void> init(void Function() onChange) async {
    _isLoading = true;

    Firestore.instance.settings(persistenceEnabled: true);

    if (_doneInit) return;
    _message = "processing main documents info";
    onChange();

    final documents = await Firestore.instance
        .collection(USERS_COLLECTION)
        .document(this.uid)
        .collection(TASKS_SUBCOLLECTION)
        .getDocuments();

    for (final child in documents.documents) {
      if (_doneInit) return;
      _message = "processing ${child.documentID}";
      onChange();
      await _processAndAddDocumentEntry(child);
    }

    if (_doneInit) return;
    _computeMonths();

    _isLoading = false;
    _doneInit = true;
  }

  void timedout() {
    _isLoading = false;
    _doneInit = true;
    _isError = true;
    _message =
        "Connection Timed out!\nMight be because there is no internet connection.";
  }

  void _computeMonths() {
    if (_daysScores.isEmpty) return;

    // because they are sorted,
    // the work is easy
    DateTime lastMonth = _daysScores[0].date;
    double score = 0;

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

  Future<void> _processAndAddDocumentEntry(DocumentSnapshot document) async {
    final date = getDateFromDBDocumentName(document.documentID);
    if (date == null) return;

    _daysScores.add(Score(date, await _computeScore(document.reference)));
  }

  Future<double> _computeScore(DocumentReference parent) async {
    final tasksCollection = parent.collection(TASKS_SUBCOLLECTION);
    final tasks = (await tasksCollection.getDocuments()).documents;

    double finalScore = 0;

    tasks.forEach((e) {
      final taskData = _fixTask(e.data);
      final task = TaskData(
        name: taskData[NAME],
        type: taskData[TYPE],
        durationH: (taskData[DURATION] as num).toDouble(),
        done: taskData[DONE],
      );

      finalScore += _computeTaskScore(task);
    });

    return finalScore;
  }

  double _computeTaskScore(TaskData task) {
    // TODO: add the fourmula

    return 1;
  }
}

Map<String, dynamic> _fixTask(Map<String, dynamic> data) {
  Map<String, dynamic> newData = data;
  if (!newData.containsKey(NAME) || !(newData[NAME] is String)) {
    newData[NAME] = "emptyName";
  }
  if (!newData.containsKey(TYPE) || !(newData[TYPE] is String)) {
    newData[TYPE] = "emptyType";
  }
  if (!newData.containsKey(DURATION) || !(newData[DURATION] is num)) {
    newData[DURATION] = 0.0;
  }
  if (newData.containsKey(DONE) && (newData[DONE] is num)) {
    newData[DONE] = (newData[DONE] as num).toInt();
  } else {
    newData[DONE] = 0;
  }
  return newData;
}
