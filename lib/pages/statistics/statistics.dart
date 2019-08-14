import 'package:flutter/material.dart';
import 'package:hayat_app/pages/basepage.dart';
import 'package:hayat_app/pages/statistics/statistics_handler.dart';
import 'package:hayat_app/utils.dart';

class StatisticsPage extends BasePage {
  StatisticsPage({Key key, String uid}) : super(key: key, uid: uid);

  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  _StatisticsPageState() : statisticsHandler = StatisticsHandler();

  final StatisticsHandler statisticsHandler;

  @override
  void initState() {
    super.initState();
    statisticsHandler.init();
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
    return _card(Text("ADD CHART"));
  }

  Widget _buildMonthGraph() {
    return _card(Text("ADD CHART"));
  }

  Widget _buildBestMonth() {
    return _card(
      Text(
        "${statisticsHandler.topMonth}",
        style: Theme.of(context).textTheme.display2,
      ),
      "TOP MONTH",
    );
  }

  Widget _buildBestDay() {
    return _card(
      Text(
        "${statisticsHandler.topDay}",
        style: Theme.of(context).textTheme.display2,
      ),
      "TOP DAY",
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
      return buildLoadingWidget();
    else
      return _buildMainView();
  }
}
