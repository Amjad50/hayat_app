import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hayat_app/DB/db_article.dart';
import 'package:hayat_app/DB/db_user.dart';
import 'package:hayat_app/utils.dart';

const String USERS_COLLECTION = "users",
    USER_DOC_FAVS = "favs",
    USER_DOC_TASKS_TYPES = "tasks_types",
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
      _user = DBUser.fromMap(userDataRef, Map<String, dynamic>.from(DBUser.defaults));
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
}
