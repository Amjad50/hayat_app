import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hayat_app/pages/tasks/new_task_dialog.dart';
import 'package:hayat_app/pages/tasks/task_data.dart';
import 'package:hayat_app/pages/tasks/view/task_view.dart';
import 'package:hayat_app/pages/tasks/tasks_collection_types.dart';
import 'package:hayat_app/utils.dart';

const USERS_COLLECTION = "users";
const USER_TASKS_TYPES = "tasks_types";
const TASKS_SUBCOLLECTION = "tasks";

class TasksHandler {
  TasksHandler({this.uid, @required this.tasksType});

  final String uid;
  final TasksCollectionType tasksType;

  bool isLoading;

  List<String> _types;

  Future<void> initUserTypes() async {
    isLoading = true;
    final snapshot = await Firestore.instance
        .collection(USERS_COLLECTION)
        .document(this.uid)
        .get();

    final data = _fixUser(snapshot.data);

    _types = data[USER_TASKS_TYPES];

    if (_types.isEmpty)
      _types.add(
          "ERROR: Empty Types List"); // TODO: use default list in the user dataset

    isLoading = false;
  }

  Future<void> createTask(BuildContext context, DateTime date) async {
    final result = await showDialog<TaskData>(
      context: context,
      builder: (BuildContext context) =>
          NewTaskDialog(tasksType: this.tasksType, userTypes: _types),
    );

    // final batch = Firestore.instance.batch();

    if (result != null) {
      await _writeToDB(date, (transaction, tasksCollectionRef) async {
        print("hi");
        final newTaskDocRef = tasksCollectionRef.document();
        print(result.buildMap());
        await transaction.set(newTaskDocRef, result.buildMap());
      });
    } else {
      print("cancled");
    }
  }

  Widget _buildListView(List<DocumentSnapshot> documents) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        final taskData = _fixTask(documents[index].data);
        return TaskView(
          data: TaskData(
            tasksType: tasksType,
            name: taskData[NAME],
            type: taskData[TYPE],
            durationH: (taskData[DURATION] as num).toDouble(),
            done: taskData[DONE],
          ),
          // TODO: maybe better idea to update the done percentage?
          onDoneChange: (value) {
            documents[index].reference.updateData({DONE: value});
          },
        );
      },
      itemCount: documents.length,
    );
  }

  Widget buildTasksList(DateTime date, WidgetBuilder zeroWidget) {
    CollectionReference tasksCollectionRef = Firestore.instance
        .collection(USERS_COLLECTION)
        .document(this.uid)
        .collection(tasksCollectionTypesDBNames[tasksType]);

    if (tasksType == TasksCollectionType.TODAYS_TASKS)
      tasksCollectionRef = tasksCollectionRef
          .document(getTasksDBDocumentName(date))
          .collection(TASKS_SUBCOLLECTION);

    return StreamBuilder<QuerySnapshot>(
      stream: tasksCollectionRef.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.documents.length > 0)
            return _buildListView(snapshot.data.documents);
          else
            return zeroWidget(context);
        } else {
          return buildLoadingWidget();
        }
      },
    );
  }

  Map<String, dynamic> _fixTask(Map<String, dynamic> data) {
    Map<String, dynamic> newData = data;
    if (!newData.containsKey(NAME) || !(newData[NAME] is String)) {
      newData[NAME] = "emptyName";
    }
    if (!newData.containsKey(TYPE) || !(newData[TYPE] is String)) {
      newData[TYPE] = "emptyType";
    }
    if (!newData.containsKey(DURATION) || !(newData[DURATION] is num)) {
      newData[DURATION] = 0.0;
    }
    if (tasksType == TasksCollectionType.TODAYS_TASKS) {
      if (newData.containsKey(DONE) && (newData[DONE] is num)) {
        newData[DONE] = (newData[DONE] as num).toInt();
      } else {
        newData[DONE] = 0;
      }
    }
    return newData;
  }

  Map<String, dynamic> _fixUser(Map<String, dynamic> data) {
    Map<String, dynamic> newData = data;

    if (newData.containsKey(USER_TASKS_TYPES) &&
        (newData[USER_TASKS_TYPES] is List<dynamic>))
      newData[USER_TASKS_TYPES] = (newData[USER_TASKS_TYPES] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
    else
      newData[USER_TASKS_TYPES] = <String>[];

    return newData;
  }

  Future<void> _writeToDB(
      DateTime date,
      Future<dynamic> Function(Transaction, CollectionReference)
          handler) async {
    CollectionReference tasksCollectionRef = Firestore.instance
        .collection(USERS_COLLECTION)
        .document(this.uid)
        .collection(tasksCollectionTypesDBNames[tasksType]);

    await Firestore.instance.runTransaction((transaction) async {
      if (tasksType == TasksCollectionType.TODAYS_TASKS) {
        final dayDocRef =
            tasksCollectionRef.document(getTasksDBDocumentName(date));

        final doc = await transaction.get(dayDocRef);

        if (!doc.exists)
          await transaction.set(dayDocRef, {});
        else
          await transaction.update(dayDocRef, {});

        tasksCollectionRef = dayDocRef.collection(TASKS_SUBCOLLECTION);
      }

      await handler(transaction, tasksCollectionRef);
    });
  }

  Future<void> addTasks(List<TaskData> tasks, DateTime date) async {
    _writeToDB(date, (transaction, tasksCollectionRef) async {
      tasks.forEach((e) async {
        final newTaskDocRef = tasksCollectionRef.document();
        await transaction.set(newTaskDocRef, e.buildMap());
      });
    });
  }

  Future<List<TaskData>> getTasks(DateTime date) async {
    CollectionReference tasksCollectionRef = Firestore.instance
        .collection(USERS_COLLECTION)
        .document(this.uid)
        .collection(tasksCollectionTypesDBNames[tasksType]);

    if (tasksType == TasksCollectionType.TODAYS_TASKS)
      tasksCollectionRef = tasksCollectionRef
          .document(getTasksDBDocumentName(date))
          .collection(TASKS_SUBCOLLECTION);

    final docs = await tasksCollectionRef.getDocuments();

    final tasks = docs.documents.map((e) {
      final taskData = _fixTask(e.data);
      return TaskData(
        tasksType: tasksType,
        name: taskData[NAME],
        type: taskData[TYPE],
        durationH: (taskData[DURATION] as num).toDouble(),
        done: taskData[DONE] ?? 0,
      );
    }).toList();

    return tasks;
  }
}
