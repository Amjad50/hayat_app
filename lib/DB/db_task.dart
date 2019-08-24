import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hayat_app/DB/base_db_type.dart';

const NAME = "name", TYPE = "type", DURATION = "duration", DONE = "done";

class DBTask extends BaseDBType {
  DBTask(this.baseRef,
      {this.name, this.typeIndex, this.typeString, this.durationH, this.done});

  factory DBTask.fromMap(DocumentReference baseRef, Map<String, dynamic> data,
      List<String> tasksTypes) {
    data = fix(data);

    final int typeIndex = data[TYPE];
    String typeString;
    if (typeIndex == -1 || tasksTypes == null || typeIndex < 0 || typeIndex >= tasksTypes.length)
      typeString = "No type";
    else
      typeString = tasksTypes[typeIndex];

    return DBTask(
      baseRef,
      name: data[NAME],
      typeIndex: typeIndex,
      typeString: typeString,
      durationH: data[DURATION],
      done: data[DONE],
    );
  }

  final String name;
  final int typeIndex;
  final String typeString;
  final double durationH;
  final int done;
  final DocumentReference baseRef;

  @override
  Map<String, dynamic> toMap() => {
        NAME: this.name,
        TYPE: this.typeIndex,
        DURATION: this.durationH,
        DONE: this.done,
      };

  static Map<String, dynamic> fix(Map<String, dynamic> data) {
    // NAME
    if (!(data.containsKey(NAME) && (data[NAME] is String)))
      data[NAME] = "No Task Name";

    // TYPE
    if (data.containsKey(TYPE) && (data[TYPE] is num))
      data[TYPE] = (data[TYPE] as num).toInt();
    else
      data[TYPE] = -1;

    // DURATION
    if (data.containsKey(DURATION) && (data[DURATION] is num))
      data[DURATION] = (data[DURATION] as num).toDouble();
    else
      data[DURATION] = 0;

    // DONE
    if (data.containsKey(DONE) && (data[DONE] is num))
      data[DONE] = (data[DONE] as num).toInt();
    else
      data[DONE] = 0;

    return data;
  }

  static int byTypeComparator(DBTask a, DBTask b) {
    return (a.typeIndex - b.typeIndex);
  }
}
