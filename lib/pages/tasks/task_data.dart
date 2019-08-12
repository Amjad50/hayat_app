import 'package:hayat_app/pages/tasks/tasks_collection_types.dart';

const NAME = "name";
const TYPE = "type";
const DURATION = "duration";
const DONE = "done";

class TaskData {
  TaskData({this.name, this.type, this.durationH, done, this.tasksType})
      : this.done =
            tasksType == TasksCollectionType.TODAYS_TASKS ? done : null;

  final String name;
  final String type;
  final double durationH;
  final int done;

  final TasksCollectionType tasksType;

  Map<String, dynamic> buildMap() {
    final map = <String, dynamic>{
      NAME: this.name,
      TYPE: this.type,
      DURATION: this.durationH
    };

    if (tasksType == TasksCollectionType.TODAYS_TASKS) {
      map[DONE] = this.done;
    }

    return map;
  }
}
