import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hayat_app/DB/db_article.dart';
import 'package:hayat_app/DB/db_user.dart';
import 'package:hayat_app/DB/db_task.dart';
import 'package:hayat_app/pages/tasks/tasks_collection_types.dart';
import 'package:hayat_app/utils.dart';

const String USERS_COLLECTION = "users",
    ARTICLES_HEADERS_COLLECTION = "articles_headers",
    ARTICLES_PAGES_COLLECTION = "articles_pages";

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

  Widget articlesHeadersStreamBuilder({
    @required Widget Function(BuildContext, List<DBArticle>) builder,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(ARTICLES_HEADERS_COLLECTION)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // convert them into DBArticles then send them to the layout builder
        if (snapshot.hasData) {
          final userFavs = user.favs;
          final articles = snapshot.data.documents.map((e) {
            final article = DBArticle.fromMap(
                e.reference, e.data, userFavs.contains(e.reference));
            article.star.addListener(() => user.invertFav(e.reference));
            return article;
          }).toList();
          return builder(context, articles);
        } else {
          return buildLoading();
        }
      },
    );
  }

  Widget tasksStreamBuilder(
    DateTime date,
    TasksCollectionType tasksType, {
    @required Widget Function(BuildContext, List<DBTask>) builder,
  }) {
    final tasksRef = _getTasksRef(date, tasksType);

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

  Future<void> addTask(
      DateTime date, TasksCollectionType tasksType, DBTask task) async {
    final tasksRef = _getTasksRef(date, tasksType);

    await tasksRef.add(task.toMap());
  }

  Future<List<DBTask>> getTasks(
      DateTime date, TasksCollectionType tasksType) async {
    final tasksRef = _getTasksRef(date, tasksType);

    final docs = await _getDocuments(tasksRef);

    return docs
        .map(
          (e) => DBTask.fromMap(e.reference, e.data, user.tasksTypes),
        )
        .toList();
  }

  CollectionReference _getTasksRef(DateTime date, TasksCollectionType tasksType) {
    if (tasksType == TasksCollectionType.TODAYS_TASKS)
      return user.getTasksRef(date);
    else
      return user.getRoutineTasksRef();
  }

  Future<List<DocumentSnapshot>> _getDocuments(CollectionReference ref) async {
    return (await ref.getDocuments()).documents;
  }
}
