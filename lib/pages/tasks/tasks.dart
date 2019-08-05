import 'package:flutter/material.dart';
import 'package:hayat_app/pages/basepage.dart';
import 'package:hayat_app/pages/tasks/tasks_collection_types.dart';
import 'package:hayat_app/pages/tasks/tasks_handler.dart';

class TasksPage extends BasePage {
  TasksPage({Key key, String uid}) : super(key: key, uid: uid);

  final tabs = TasksCollectionTypes.values;

  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with TickerProviderStateMixin {
  List<TasksHandler> _taskshandlers;
  TabController _tabsController;

  @override
  void initState() {
    super.initState();
    _taskshandlers = widget.tabs
        .map((e) => TasksHandler(uid: widget.uid, tasksType: e))
        .toList();
    _tabsController = TabController(length: widget.tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabsController.dispose();
    super.dispose();
  }

  Widget _buildTabs() {
    final bar = TabBar(
      tabs: widget.tabs
          .map((e) => Tab(text: tasksCollectionTypesViewNames[e]))
          .toList(),
      controller: _tabsController,
    );
    return PreferredSize(
      child: Material(
        color: Theme.of(context).accentColor,
        child: bar,
        elevation: 4, // TODO: remove elvation of the top appbar
      ),
      preferredSize: bar.preferredSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildTabs(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _taskshandlers[_tabsController.index]
              .createTask(context: context)
              .then((v) => setState(() {}));
        },
      ),
      body: TabBarView(
        controller: _tabsController,
        children: _taskshandlers
            .map(
              (e) => e.buildTasksList(),
            )
            .toList(),
      ),
    );
  }
}
