import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:hayat_app/pages/basepage.dart';
import 'package:hayat_app/pages/statistics/score.dart';
import 'package:hayat_app/pages/statistics/statistics_handler.dart';
import 'package:hayat_app/utils.dart';

class StatisticsPage extends BasePage {
  StatisticsPage({Key key, String uid}) : super(key: key, uid: uid);

  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  _StatisticsPageState();
  StatisticsHandler statisticsHandler;

  // to avoid error of updating the widget, after dispose
  void Function(void Function()) _updateWidget;

  @override
  void initState() {
    super.initState();
    _updateWidget = setState;
    statisticsHandler = StatisticsHandler(
      uid: widget.uid,
      onChange: () => _updateWidget(() {}),
    );
    statisticsHandler.init().then((_) => _updateWidget(() {}));
  }

  @override
  void dispose() {
    _updateWidget = (_) {};
    statisticsHandler.dispose();
    super.dispose();
  }

  Widget _card(Widget widget, [String titleString]) {
    final title = titleString != null
        ? Padding(
            padding: const EdgeInsets.all(4.0),
            child: Align(
              child: Text(titleString ?? ""),
              alignment: Alignment.topLeft,
            ),
          )
        : Container();
    final centeredWidget = Center(child: widget);

    return Card(
      child: Stack(
        children: <Widget>[
          title,
          centeredWidget,
        ],
      ),
    );
  }

  Widget _buildDaysGraph() {
    return _card(
      LineChart(
        <Series<Score, num>>[
          Series<Score, num>(
              id: "Days",
              data: statisticsHandler.daysScores,
              measureFn: (score, index) => score.score,
              domainFn: (score, index) => index),
        ],
      ),
    );
  }

  Widget _buildMonthGraph() {
    return _card(
      LineChart(
        <Series<Score, num>>[
          Series<Score, num>(
            id: "Days",
            data: statisticsHandler.monthsScores,
            measureFn: (score, index) => score.score,
            domainFn: (score, index) => index,
          ),
        ],
      ),
    );
  }

  Widget _buildBestMonth() {
    return _card(
      Text(
        "${statisticsHandler.topMonth.score}",
        style: Theme.of(context).textTheme.display2,
      ),
      "TOP MONTH = ${statisticsHandler.topMonth.dateString}",
    );
  }

  Widget _buildBestDay() {
    return _card(
      Text(
        "${statisticsHandler.topDay.score}",
        style: Theme.of(context).textTheme.display2,
      ),
      "TOP DAY = ${statisticsHandler.topDay.dateString}",
    );
  }

  Widget _expand(Widget widget) {
    return Expanded(child: widget);
  }

  Widget _buildBestDataRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildBestMonth(),
        _buildBestDay(),
      ].map(_expand).toList(),
    );
  }

  Widget _buildMainView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildDaysGraph(),
        _buildMonthGraph(),
        _buildBestDataRow(),
      ].map(_expand).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (statisticsHandler.isLoading)
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildLoadingWidget(),
            Padding(
              padding: EdgeInsets.only(top: 16),
            ),
            Text("${statisticsHandler.message}"),
          ],
        ),
      );
    else if (statisticsHandler.isError)
      return Center(
          child: Text(
        statisticsHandler.message,
        textAlign: TextAlign.center,
      ));
    else
      return _buildMainView();
  }
}
