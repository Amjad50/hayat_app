import 'package:flutter/material.dart';
import 'package:hayat_app/pages/basepage.dart';
import 'package:hayat_app/pages/statistics/score_graph.dart';
import 'package:hayat_app/pages/statistics/statistics_handler.dart';
import 'package:hayat_app/utils.dart';

class StatisticsPage extends BasePage {
  StatisticsPage({Key key}) : super(key: key);

  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  _StatisticsPageState();
  StatisticsHandler statisticsHandler;

  bool _reInit = false;

  // to avoid error of updating the widget, after dispose
  void Function(void Function()) _updateWidget;

  @override
  void initState() {
    super.initState();
    _updateWidget = setState;
    statisticsHandler = StatisticsHandler(
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

  Future<void> _handleRefresh() async {
    _reInit = true;
    await statisticsHandler.reInit();
    _updateWidget(() {
      _reInit = false;
    });
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
      ScoreGraph(data: statisticsHandler.daysScores, id: "Days"),
    );
  }

  Widget _buildMonthGraph() {
    return _card(
      ScoreGraph.month(data: statisticsHandler.monthsScores, id: "Months"),
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

  Widget _buildDoneStatisticsData() {
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

  Widget _buildMainView() {
    if (statisticsHandler.isLoading)
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _reInit ? Container() : buildLoadingWidget(),
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
      return _buildDoneStatisticsData();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverFillViewport(
            delegate: SliverChildBuilderDelegate(
              (_, __) => _buildMainView(),
              childCount: 1,
            ),
          ),
        ],
      ),
    );
  }
}
