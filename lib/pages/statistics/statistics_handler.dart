import 'dart:math';

class StatisticsHandler {
  bool isLoading = false;
  bool _doneInit = false;

  List<int> _daysScores = [];
  List<int> _monthsScores = [];

  int get topDay {
    if (_doneInit || _daysScores.isEmpty) return 0;
    return _daysScores.reduce(max);
  }

  int get topMonth {
    if (_doneInit || _monthsScores.isEmpty) return 0;
    return _monthsScores.reduce(max);
  }

  Future<void> init() async {
    isLoading = true;

    isLoading = false;
    _doneInit = true;
  }
}
