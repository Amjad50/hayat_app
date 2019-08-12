import 'package:flutter/material.dart';
import 'package:hayat_app/pages/basepage.dart';
import 'package:hayat_app/pages/tasks/tasks_collection_types.dart';
import 'package:hayat_app/pages/tasks/tasks_handler.dart';
import 'package:hayat_app/utils.dart';

class TasksPage extends BasePage {
  TasksPage({Key key, String uid}) : super(key: key, uid: uid);

  final tabs = TasksCollectionType.values;

  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with TickerProviderStateMixin {
  List<TasksHandler> _taskshandlers;
  TabController _tabsController;

  DateTime _choosenDay;

  @override
  void initState() {
    super.initState();
    _tabsController =
        TabController(length: widget.tabs.length, vsync: this, initialIndex: 1);
    _tabsController.addListener(() {
      if (!_tabsController.indexIsChanging) setState(() {});
    });
    _choosenDay = DateTime.now();
    _taskshandlers = widget.tabs
        .map((e) => TasksHandler(uid: widget.uid, tasksType: e))
        .toList();
    _taskshandlers
        .forEach((e) => e.initUserTypes().then((_) => setState(() {})));
  }

  @override
  void dispose() {
    _tabsController.dispose();
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
                setState(() {
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
    if (_choosenDay.difference(DateTime.now()).inDays != 0 &&
        _tabsController.index != 0) return null;
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        _taskshandlers[_tabsController.index]
            .createTask(context, _choosenDay)
            .then((v) => setState(() {}));
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
        children: _taskshandlers
            .map(
              (e) => e.isLoading ? buildLoadingWidget() :e.buildTasksList(_choosenDay),
            )
            .toList(),
      ),
    );
  }
}
