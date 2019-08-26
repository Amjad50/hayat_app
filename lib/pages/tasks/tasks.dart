import 'package:flutter/material.dart';
import 'package:hayat_app/pages/basepage.dart';
import 'package:hayat_app/pages/tasks/tasks_collection_types.dart';
import 'package:hayat_app/pages/tasks/tasks_handler.dart';
import 'package:hayat_app/utils.dart';

class TasksPage extends BasePage {
  TasksPage({Key key}) : super(key: key);

  final tabs = TasksCollectionType.values;

  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with TickerProviderStateMixin {
  List<TasksHandler> _taskshandlers;
  TabController _tabsController;

  DateTime _choosenDay;

  bool _populateLoading = false;

  // to avoid error of updating the widget, after dispose
  void Function(void Function()) _updateWidget;

  @override
  void initState() {
    super.initState();
    _updateWidget = setState;
    _tabsController =
        TabController(length: widget.tabs.length, vsync: this, initialIndex: 1);
    _tabsController.addListener(() {
      if (!_tabsController.indexIsChanging) _updateWidget(() {});
    });
    _choosenDay = DateTime.now();
    _taskshandlers =
        widget.tabs.map((e) => TasksHandler(tasksType: e)).toList();
  }

  @override
  void dispose() {
    _tabsController.dispose();
    _taskshandlers.clear();
    _updateWidget = (_) {};
    super.dispose();
  }

  PreferredSizeWidget _buildTabsBar() {
    return TabBar(
      tabs: widget.tabs
          .map((e) => Tab(text: tasksCollectionTypesViewNames[e]))
          .toList(),
      controller: _tabsController,
    );
  }

  PreferredSizeWidget _buildDaysChoosedBar() {
    return PreferredSize(
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () {
            final now = DateTime.now();
            showDatePicker(
              context: context,
              initialDate: _choosenDay,
              firstDate: now.subtract(const Duration(days: 30)),
              lastDate: now,
            ).then((value) {
              if (value != null) {
                _updateWidget(() {
                  _choosenDay = value;
                });
              }
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.calendar_today,
                size: 20,
              ),
              const Padding(
                padding: const EdgeInsets.only(right: 4),
              ),
              Text(getDayDisplayString(_choosenDay)),
              const Icon(Icons.arrow_drop_down)
            ],
          ),
        ),
      ),
      preferredSize: Size.fromHeight(50), // way larger than used (== infinite)
    );
  }

  Widget _buildPopulateRoutines(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text("Populate your routine tasks?"),
          RaisedButton(
            child: Text("YES"),
            onPressed: () async {
              _updateWidget(() {
                _populateLoading = true;
              });
              final todayHandler = _taskshandlers[
                  widget.tabs.indexOf(TasksCollectionType.TODAYS_TASKS)];
              final routineHandler = _taskshandlers[
                  widget.tabs.indexOf(TasksCollectionType.ROUTINE_TASKS)];

              await todayHandler.addTasks(
                  await routineHandler.getTasks(_choosenDay), _choosenDay);
              _updateWidget(() {
                _populateLoading = false;
              });
            },
          )
        ],
      ),
    );
  }

  Widget _buildEmptyTasksMessage(BuildContext context) {
    return Center(
        child: Text(
      "No Tasks Found",
      textAlign: TextAlign.center,
    ));
  }

  Widget _buildTopBar() {
    final tabsBar = _buildTabsBar();
    final daysChooseBar = _buildDaysChoosedBar();
    return PreferredSize(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Material(
            color: Theme.of(context).accentColor,
            child: tabsBar,
            elevation: 4, // TODO: remove elvation of the top appbar
          ),
          Material(
            color: Colors.black26,
            child: daysChooseBar,
          ),
        ],
      ),
      preferredSize: Size(tabsBar.preferredSize.width,
          tabsBar.preferredSize.height + daysChooseBar.preferredSize.height),
    );
  }

  FloatingActionButton _buildFAB() {
    if ((_choosenDay.difference(DateTime.now()).inDays != 0 &&
        _tabsController.index != 0)) return null;
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        _taskshandlers[_tabsController.index]
            .createTask(context, _choosenDay)
            .then((v) => _updateWidget(() {}));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildTopBar(),
      floatingActionButton: _buildFAB(),
      body: TabBarView(
        controller: _tabsController,
        children: _taskshandlers.map(
          (e) {
            return Builder(
              builder: (context) {
                if (_populateLoading && _tabsController.index == 1)
                  return buildLoadingWidget();
                else
                  return e.buildTasksList(
                      _choosenDay,
                      // TODO: fix this spagetti code
                      e.tasksType == TasksCollectionType.TODAYS_TASKS &&
                              _choosenDay.difference(DateTime.now()).inDays == 0
                          ? _buildPopulateRoutines
                          : _buildEmptyTasksMessage);
              },
            );
          },
        ).toList(),
      ),
    );
  }
}
