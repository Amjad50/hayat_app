import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:hayat_app/pages/statistics/score.dart';

enum _SUBTRACT_TYPE {
  LAST_WEEK,
  LAST_MONTH,
  LAST_SIX_MONTHS,
  LAST_YEAR,
  ALL_TIME
}

class ScoreGraph extends StatefulWidget {
  ScoreGraph({Key key, @required this.data, @required this.id})
      : _isMonth = false,
        super(key: key);

  ScoreGraph.month({Key key, @required this.data, @required this.id})
      : _isMonth = true,
        super(key: key);

  final List<Score> data;
  final String id;

  final bool _isMonth;

  _ScoreGraphState createState() => _ScoreGraphState();
}

class _ScoreGraphState extends State<ScoreGraph> {
  _SUBTRACT_TYPE _choosenType = _SUBTRACT_TYPE.ALL_TIME;

  Map<_SUBTRACT_TYPE, String> _items;

  @override
  void initState() {
    super.initState();
    _items = widget._isMonth
        ? {}
        : {
            _SUBTRACT_TYPE.LAST_WEEK: "Last week",
            _SUBTRACT_TYPE.LAST_MONTH: "Last Month",
          };

    _items.addAll({
      _SUBTRACT_TYPE.LAST_SIX_MONTHS: "Last Six Months",
      _SUBTRACT_TYPE.LAST_YEAR: "Last Year",
      _SUBTRACT_TYPE.ALL_TIME: "All Time",
    });
  }

  List<DropdownMenuItem<_SUBTRACT_TYPE>> _buildDropDownItems() {
    final list = List<DropdownMenuItem<_SUBTRACT_TYPE>>(_items.length);
    final keys = _items.keys.iterator;

    for (int i = 0; i < list.length; i++) {
      final currentKey =
          keys.moveNext() ? keys.current : _SUBTRACT_TYPE.ALL_TIME;
      list[i] = DropdownMenuItem(
        child: Text(_items[currentKey]),
        value: currentKey,
      );
    }

    return list;
  }

  Widget _buildChoose() {
    return DropdownButton(
      items: _buildDropDownItems(),
      value: _choosenType,
      onChanged: (value) => setState(() => _choosenType = value),
      isDense: true,
    );
  }

  List<Score> _getData() {
    final DateTime now = DateTime.now();
    DateTime afterEdit;

    switch (_choosenType) {
      case _SUBTRACT_TYPE.LAST_WEEK:
        afterEdit = DateTime(now.year, now.month, now.day - 7 + 1);
        break;
      case _SUBTRACT_TYPE.LAST_MONTH:
        afterEdit = DateTime(now.year, now.month - 1, now.day + 1);
        break;
      case _SUBTRACT_TYPE.LAST_SIX_MONTHS:
        afterEdit = DateTime(now.year, now.month - 6, now.day + 1);
        break;
      case _SUBTRACT_TYPE.LAST_YEAR:
        afterEdit = DateTime(now.year - 1, now.month, now.day + 1);
        break;
      case _SUBTRACT_TYPE.ALL_TIME:
        afterEdit = DateTime.fromMillisecondsSinceEpoch(0);
        break;
    }
    return widget.data.skipWhile((e) => e.date.isBefore(afterEdit)).toList();
  }

  Widget _buildChart() {
    return TimeSeriesChart(
      <Series<Score, DateTime>>[
        Series<Score, DateTime>(
          id: widget.id,
          data: _getData(),
          measureFn: (score, index) => score.score,
          domainFn: (score, index) => score.date,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(widget.id),
            _buildChoose(),
          ],
        ),
        Expanded(
          child: _buildChart(),
        ),
      ],
    );
  }
}
