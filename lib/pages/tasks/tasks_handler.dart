import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hayat_app/DB/db_task.dart';
import 'package:hayat_app/DB/db_user.dart';
import 'package:hayat_app/DB/firestore_handler.dart';
import 'package:hayat_app/pages/tasks/new_task_dialog.dart';
import 'package:hayat_app/pages/tasks/view/task_list_view.dart';
import 'package:hayat_app/pages/tasks/tasks_collection_types.dart';
import 'package:hayat_app/utils.dart';

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
      await FireStoreHandler.instance.addTask(date, result);
    } else {
      print("cancled");
    }
  }

  Widget _buildListView(List<DBTask> tasks) {
    return TasksListView(
      tasksType: tasksType,
      tasks: tasks,
    );
  }

  Widget buildTasksList(DateTime date, WidgetBuilder zeroWidget) {
    return FireStoreHandler.instance.tasksStreamBuilder(date,
        builder: (context, tasks) {
      return _buildListView(tasks);
    });
  }

  Future<void> addTasks(List<DBTask> tasks, DateTime date) async {
    for (final child in tasks) {
      await FireStoreHandler.instance.addTask(date, child);
    }
  }

  Future<List<DBTask>> getTasks(DateTime date) async {
    // TODO: rewrite to use FireStoreHandler
    CollectionReference tasksCollectionRef = FireStoreHandler
        .instance.user.baseRef
        .collection(tasksCollectionTypesDBNames[tasksType]);

    if (tasksType == TasksCollectionType.TODAYS_TASKS)
      tasksCollectionRef = tasksCollectionRef
          .document(getTasksDBDocumentName(date))
          .collection(TASKS_SUBCOLLECTION);

    final docs = await tasksCollectionRef.getDocuments();

    final tasks = docs.documents
        .map((e) => DBTask.fromMap(e.reference, e.data, _user.tasksTypes))
        .toList();

    return tasks;
  }
}
