import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hayat_app/pages/tasks/tasks_collection_types.dart';

const NAME = "name";
const TYPE = "type";
const DURATION = "duration";
const DONE = "done";

class TaskData {
  TaskData(
      {this.name,
      this.typeIndex,
      this.typeString,
      this.durationH,
      done,
      this.tasksType,
      this.reference})
      : this.done = tasksType == TasksCollectionType.TODAYS_TASKS ? done : null;

  TaskData.fromMap(Map<String, dynamic> map, List<String> userTypes, {TasksCollectionType tasksType, DocumentReference reference})
      : this(
          name: map[NAME],
          typeIndex: map[TYPE],
          typeString: map[TYPE] == -1 || map[TYPE] > userTypes.length ? _ERROR_EMPTY_TYPE : userTypes[map[TYPE]],
          durationH: map[DURATION],
          done: map[DONE],
          reference: reference,
          tasksType: tasksType,
        );

  final String name;
  final int typeIndex;
  final String typeString;
  final double durationH;
  final int done;
  final DocumentReference reference;

  final TasksCollectionType tasksType;

  static const _ERROR_EMPTY_TYPE = "ERROR:EMPTY TYPE";

  Map<String, dynamic> buildMap() {
    final map = <String, dynamic>{
      NAME: this.name,
      TYPE: this.typeIndex,
      DURATION: this.durationH
    };

    if (tasksType == TasksCollectionType.TODAYS_TASKS) {
      map[DONE] = this.done;
    }

    return map;
  }
}
