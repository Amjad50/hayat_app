import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hayat_app/pages/tasks/new_task_dialog.dart';
import 'package:hayat_app/pages/tasks/task_data.dart';
import 'package:hayat_app/pages/tasks/task_view.dart';

const USERS_COLLECTION = "users";
const TASKS = "tasks";

class TasksHandler {
  TasksHandler({this.uid}) : _data = <TaskData>[];

  final String uid;
  final List<TaskData> _data;

  Future<void> createTask({BuildContext context}) async {
    final result = await showDialog<TaskData>(
        context: context,
        builder: (BuildContext context) {
          return NewTaskDialog();
        });

    if (result != null) {
      _data.add(result);
    } else {
      print("cancled");
    }
  }

  Widget buildTasksList() {
    return ListView(
      children: _data.map((e) => TaskView(data: e)).toList(),
    );
  }

  Future<bool> downloadData() async {
    final tasksRef = Firestore.instance
        .collection(USERS_COLLECTION)
        .document(this.uid)
        .collection(TASKS);

    final snapshot = await tasksRef.getDocuments();

    _data.addAll(snapshot.documents.map<TaskData>((e) {
      final taskData = _fixTask(e.data);
      return TaskData(
          name: taskData[NAME],
          type: taskData[TYPE],
          durationH: (taskData[DURATION] as num).toDouble(),
          done: taskData[DONE]);
    }));

    return true;
  }

  DocumentSnapshot _fixData(DocumentSnapshot snapshot) {
    if (!snapshot.data.containsKey(TASKS) ||
        !(snapshot.data[TASKS] is List<dynamic>)) {
      snapshot.data[TASKS] = List<dynamic>();
    }

    return snapshot;
  }

  Map<String, dynamic> _fixTask(Map<String, dynamic> data) {
    if (!data.containsKey(NAME) ||
        !(data[NAME] is String)) {
      data[NAME] = "emptyName";
    }
    if (!data.containsKey(TYPE) ||
        !(data[TYPE] is String)) {
      data[TYPE] = "emptyType";
    }
    if (!data.containsKey(DURATION) ||
        !(data[DURATION] is num)) {
      data[DURATION] = 0.0;
    }
    if (!data.containsKey(DONE) ||
        !(data[DONE] is bool)) {
      data[DONE] = false;
    }
    return data;
  }
}
