import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hayat_app/DB/base_db_type.dart';
import 'package:hayat_app/utils.dart';

const String FAVS = "favs",
    TASKS_TYPES = "tasks_types",
    TASKS_SUBCOLLECTION = "tasks",
    ROUTINE_TASKS_SUBCOLLECTION = "routine_tasks";

class DBUser extends BaseDBType {
  DBUser(this.baseRef, {@required this.favs, @required this.tasksTypes});
  factory DBUser.fromMap(DocumentReference baseRef, Map<String, dynamic> data) {
    data = fix(data);
    return DBUser(
      baseRef,
      favs: data[FAVS],
      tasksTypes: data[TASKS_TYPES],
    );
  }

  final List<String> tasksTypes;
  final List<DocumentReference> favs;
  final DocumentReference baseRef;

  String get uid => this.baseRef.documentID;

  Future<bool> invertFav(DocumentReference ref) async {
    bool ret;
    if (favs.contains(ref)) {
      favs.remove(ref);
      ret = false;
    } else {
      favs.add(ref);
      ret = true;
    }
    await baseRef.updateData({FAVS: favs});

    return ret;
  }

  Map<String, dynamic> toMap() => {
        FAVS: this.favs,
        TASKS_TYPES: this.tasksTypes,
      };

  CollectionReference getTasksRef(DateTime date) {
    return baseRef
        .collection(TASKS_SUBCOLLECTION)
        .document(getTasksDBDocumentName(date))
        .collection(TASKS_SUBCOLLECTION);
  }

  CollectionReference getRoutineTasksRef() {
    return baseRef.collection(ROUTINE_TASKS_SUBCOLLECTION);
  }

  static Map<String, dynamic> fix(Map<String, dynamic> data) {
    // FAVS
    if (data.containsKey(FAVS) && (data[FAVS] is List<dynamic>))
      data[FAVS] =
          List<DocumentReference>.from(data[FAVS].cast<DocumentReference>());
    else
      data[FAVS] = <DocumentReference>[];

    // TASKS_TYPES
    if (data.containsKey(TASKS_TYPES) && (data[TASKS_TYPES] is List<dynamic>))
      data[TASKS_TYPES] = List<String>.from(data[TASKS_TYPES].cast<String>());
    else
      data[TASKS_TYPES] = <String>[];
    return data;
  }

  static const Map<String, dynamic> defaults = {
    FAVS: [],
    TASKS_TYPES: [
      "Very Important",
      "Important",
      "Nuetral",
    ],
  };
}
