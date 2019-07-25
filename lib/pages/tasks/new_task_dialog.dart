import 'package:flutter/material.dart';
import 'package:hayat_app/pages/tasks/task_data.dart';

class NewTaskDialog extends StatefulWidget {
  NewTaskDialog({Key key}) : super(key: key);

  _NewTaskDialogState createState() => _NewTaskDialogState();
}

class _NewTaskDialogState extends State<NewTaskDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: RaisedButton(
        child: Text("New Entry"),
        onPressed: () => Navigator.pop(
          context,
          TaskData(
            name: "null",
            type: "null",
            durationH: 878787.0,
            done: true,
          ),
        ),
      ),
    );
  }
}
