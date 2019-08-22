import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hayat_app/DB/db_user.dart';

const String USERS_COLLECTION = "users",
    USER_DOC_FAVS = "favs",
    USER_DOC_TASKS_TYPES = "tasks_types";

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
      _user = DBUser.fromMap(userDataRef, DBUser.defaults);
    } else {
      _user = DBUser.fromMap(userDataRef, userDoc.data);
    }
  }

  Future<void> putData(
      DocumentReference dest, Map<String, dynamic> data) async {
    await dest.setData(data);
  }
}
