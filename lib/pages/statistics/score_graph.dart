import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:hayat_app/pages/statistics/score.dart';

enum _SUBTRACT_TYPE { LAST_WEEK, LAST_MONTH, LAST_YEAR, ALL_TIME }

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

  static const _items = {
    _SUBTRACT_TYPE.LAST_WEEK: "Last week",
    _SUBTRACT_TYPE.LAST_MONTH: "Last Month",
    _SUBTRACT_TYPE.LAST_YEAR: "Last Year",
    _SUBTRACT_TYPE.ALL_TIME: "All Time",
  };

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
    bool Function(Score) handler = (_) => false;

    DateTime now = DateTime.now();

    switch (_choosenType) {
      case _SUBTRACT_TYPE.LAST_WEEK:
        final beforeWeek = DateTime(now.year, now.month, now.day - 7 + 1);
        handler = (e) => e.date.isBefore(beforeWeek);
        break;
      case _SUBTRACT_TYPE.LAST_MONTH:
        final beforeMonth = DateTime(now.year, now.month - 1, now.day + 1);

        handler = (e) => e.date.isBefore(beforeMonth);
        break;
      case _SUBTRACT_TYPE.LAST_YEAR:
        final beforeYear = DateTime(now.year - 1, now.month, now.day + 1);

        handler = (e) => e.date.isBefore(beforeYear);
        break;
      case _SUBTRACT_TYPE.ALL_TIME:
        // no change to handler (default to ALL_TIME)
        break;
    }
    return widget.data.skipWhile(handler).toList();
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
            !widget._isMonth ? _buildChoose() : Container(),
          ],
        ),
        Expanded(
          child: _buildChart(),
        ),
      ],
    );
  }
}
