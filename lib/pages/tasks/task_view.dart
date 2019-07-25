
import 'package:flutter/material.dart';
import 'package:hayat_app/pages/tasks/task_data.dart';

class TaskView extends StatefulWidget {
  TaskView({Key key, this.data}) : super(key: key);

  final TaskData data;

  _TaskViewState createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Row(children: <Widget>[
        Text(widget.data.name),
        Text(widget.data.type),
        Text("${widget.data.durationH}"),
        Text("${widget.data.done}"),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,)
    );
  }
}