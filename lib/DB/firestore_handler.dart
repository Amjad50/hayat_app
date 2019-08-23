import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hayat_app/DB/db_task.dart';
import 'package:hayat_app/DB/db_user.dart';
import 'package:hayat_app/utils.dart';

const String USERS_COLLECTION = "users";

class FireStoreHandler {
  FireStoreHandler([String uid]) {
    if (uid == null) return;
    this.uid = uid;
  }

  static final FireStoreHandler instance = FireStoreHandler();

  bool _readyToUse = false;
  bool get readyToUse => _readyToUse;

  String uid;
  DBUser _user;
  DBUser get user => this._readyToUse ? _user : null;

  Future<void> init([String uid]) async {
    if (uid != null) this.uid = uid;
    await initUser();
    _readyToUse = true;
  }

  Future<void> initUser() async {
    final userDataRef =
        Firestore.instance.collection(USERS_COLLECTION).document(this.uid);
    final userDoc = await userDataRef.get();

    if (!userDoc.exists) {
      await putData(userDoc.reference, DBUser.defaults);
      _user = DBUser.fromMap(
          userDataRef, Map<String, dynamic>.from(DBUser.defaults));
    } else {
      _user = DBUser.fromMap(userDataRef, userDoc.data);
    }
  }

  Future<void> putData(
      DocumentReference dest, Map<String, dynamic> data) async {
    await dest.setData(data);
  }

  Widget tasksStreamBuilder(
    DateTime date, {
    @required Widget Function(BuildContext, List<DBTask>) builder,
  }) {
    final tasksRef = user.baseRef
        .collection(TASKS_SUBCOLLECTION)
        .document(getTasksDBDocumentName(date))
        .collection(TASKS_SUBCOLLECTION);

    return StreamBuilder<QuerySnapshot>(
      stream: tasksRef.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          final tasks = snapshot.data.documents
              .map<DBTask>((e) => DBTask.fromMap(
                    e.reference,
                    e.data,
                    user.tasksTypes,
                  ))
              .toList();
          return builder(context, tasks);
        } else {
          return buildLoadingWidget();
        }
      },
    );
  }

  Future<void> addTask(DateTime date, DBTask task) async {
    final tasksRef = user.baseRef
        .collection(TASKS_SUBCOLLECTION)
        .document(getTasksDBDocumentName(date))
        .collection(TASKS_SUBCOLLECTION);

    await tasksRef.add(task.toMap());
  }
}
