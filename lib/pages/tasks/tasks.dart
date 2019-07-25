import 'package:flutter/material.dart';
import 'package:hayat_app/pages/basepage.dart';
import 'package:hayat_app/pages/tasks/tasks_handler.dart';

class TasksPage extends BasePage {
  TasksPage({Key key, String uid}) : super(key: key, uid: uid);

  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  TasksHandler _taskshandler;
  bool _loading;

  @override
  void initState() {
    super.initState();
    _taskshandler = TasksHandler(uid: widget.uid);
    _loading = true;

    _taskshandler.downloadData().then((v) {
      setState(() {
        _loading = !v;
      });
    });
  }

  Widget _buildBody() {
    if (_loading) {
      return Container(
          alignment: Alignment.center,
          child: const CircularProgressIndicator());
    } else {
      return _taskshandler.buildTasksList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: _loading ? null : () {
            _taskshandler
                .createTask(context: context)
                .then((v) => setState(() {}));
          },
        ),
        body: _buildBody());
  }
}
