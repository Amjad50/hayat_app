import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hayat_app/DB/base_db_type.dart';
import 'package:hayat_app/DB/firestore_handler.dart';

class DBUser extends BaseDBType {
  DBUser(this.baseRef, {@required this.favs, @required this.tasksTypes});
  factory DBUser.fromMap(DocumentReference baseRef, Map<String, dynamic> data) {
    data = fix(data);
    return DBUser(
      baseRef,
      favs: data[USER_DOC_FAVS],
      tasksTypes: data[USER_DOC_TASKS_TYPES],
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
    await baseRef.updateData({USER_DOC_FAVS: favs});

    return ret;
  }

  Map<String, dynamic> toMap() => {
        USER_DOC_FAVS: this.favs,
        USER_DOC_TASKS_TYPES: this.tasksTypes,
      };

  static Map<String, dynamic> fix(Map<String, dynamic> data) {
    if (data.containsKey(USER_DOC_FAVS) &&
        (data[USER_DOC_FAVS] is List<dynamic>))
      data[USER_DOC_FAVS] = List<DocumentReference>.from(
          data[USER_DOC_FAVS].cast<DocumentReference>());
    else
      data[USER_DOC_FAVS] = <DocumentReference>[];

    if (data.containsKey(USER_DOC_TASKS_TYPES) &&
        (data[USER_DOC_TASKS_TYPES] is List<dynamic>))
      data[USER_DOC_TASKS_TYPES] =
          List<String>.from(data[USER_DOC_TASKS_TYPES].cast<String>());
    else
      data[USER_DOC_TASKS_TYPES] = <String>[];
    return data;
  }

  static const Map<String, dynamic> defaults = {
    USER_DOC_FAVS: [],
    USER_DOC_TASKS_TYPES: [
      "Very Important",
      "Important",
      "Nuetral",
    ],
  };
}
