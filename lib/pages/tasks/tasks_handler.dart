import 'package:flutter/material.dart';
import 'package:hayat_app/DB/db_task.dart';
import 'package:hayat_app/DB/db_user.dart';
import 'package:hayat_app/DB/firestore_handler.dart';
import 'package:hayat_app/pages/tasks/new_task_dialog.dart';
import 'package:hayat_app/pages/tasks/view/task_list_view.dart';
import 'package:hayat_app/pages/tasks/tasks_collection_types.dart';

const TASKS_SUBCOLLECTION = "tasks";

class TasksHandler {
  TasksHandler({@required this.tasksType})
      : _user = FireStoreHandler.instance.user;

  final TasksCollectionType tasksType;
  final DBUser _user;

  Future<void> createTask(BuildContext context, DateTime date) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute<DBTask>(
        fullscreenDialog: true,
        builder: (BuildContext context) => NewTaskDialog(
          tasksType: this.tasksType,
          userTypes: _user.tasksTypes,
        ),
      ),
    );

    if (result != null) {
      await FireStoreHandler.instance.addTask(date, tasksType, result);
    } else {
      print("cancled");
    }
  }

  Widget buildTasksList(DateTime date, WidgetBuilder zeroWidget) {
    return FireStoreHandler.instance.tasksStreamBuilder(date, tasksType,
        builder: (context, tasks) {
      if (tasks.isNotEmpty)
        return TasksListView(
          tasksType: tasksType,
          tasks: tasks,
        );
      else
        return zeroWidget(context);
    });
  }

  Future<void> addTasks(List<DBTask> tasks, DateTime date) async {
    for (final child in tasks) {
      await FireStoreHandler.instance.addTask(date, tasksType, child);
    }
  }

  Future<List<DBTask>> getTasks(DateTime date) async {
    return await FireStoreHandler.instance.getTasks(date, tasksType);
  }
}
