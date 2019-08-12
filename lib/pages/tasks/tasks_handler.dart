import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hayat_app/pages/tasks/new_task_dialog.dart';
import 'package:hayat_app/pages/tasks/task_data.dart';
import 'package:hayat_app/pages/tasks/view/task_view.dart';
import 'package:hayat_app/pages/tasks/tasks_collection_types.dart';
import 'package:hayat_app/utils.dart';

const USERS_COLLECTION = "users";
const TASKS_SUBCOLLECTION = "tasks";

class TasksHandler {
  TasksHandler({this.uid, @required this.tasksType});

  final String uid;
  final TasksCollectionType tasksType;

  Future<void> createTask(BuildContext context, DateTime date) async {
    final result = await showDialog<TaskData>(
      context: context,
      builder: (BuildContext context) => NewTaskDialog(
        tasksType: this.tasksType,
      ),
    );

    final batch = Firestore.instance.batch();

    if (result != null) {
      CollectionReference tasksCollectionRef = Firestore.instance
          .collection(USERS_COLLECTION)
          .document(this.uid)
          .collection(tasksCollectionTypesDBNames[tasksType]);

      if (tasksType == TasksCollectionType.TODAYS_TASKS) {
        final dayDocRef =
            tasksCollectionRef.document(getTasksDBDocumentName(date));

        batch.setData(dayDocRef, {});

        tasksCollectionRef = dayDocRef.collection(TASKS_SUBCOLLECTION);
      }

      final newTaskDocRef = tasksCollectionRef.document();

      batch.setData(newTaskDocRef, result.buildMap());
      await batch.commit();
    } else {
      print("cancled");
    }
  }

  Widget _buildLoading() {
    return Center(child: CircularProgressIndicator());
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

  Widget buildTasksList(DateTime date) {
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
          return _buildListView(snapshot.data.documents);
        } else {
          return _buildLoading();
        }
      },
    );
  }

  Map<String, dynamic> _fixTask(Map<String, dynamic> data) {
    if (!data.containsKey(NAME) || !(data[NAME] is String)) {
      data[NAME] = "emptyName";
    }
    if (!data.containsKey(TYPE) || !(data[TYPE] is String)) {
      data[TYPE] = "emptyType";
    }
    if (!data.containsKey(DURATION) || !(data[DURATION] is num)) {
      data[DURATION] = 0.0;
    }
    if (tasksType == TasksCollectionType.TODAYS_TASKS) {
      if (data.containsKey(DONE) && (data[DONE] is num)) {
        data[DONE] = (data[DONE] as num).toInt();
      } else {
        data[DONE] = 0;
      }
    }
    return data;
  }
}
