
const NAME = "name";
const TYPE = "type";
const DURATION = "duration";
const DONE = "done";

class TaskData {
  
  TaskData({this.name, this.type, this.durationH, this.done});

  final String name;
  final String type;
  final double durationH;
  final bool done;

}