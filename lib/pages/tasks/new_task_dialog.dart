import 'package:flutter/material.dart';
import 'package:hayat_app/pages/tasks/task_data.dart';
import 'package:hayat_app/pages/tasks/tasks_collection_types.dart';

class NewTaskDialog extends StatefulWidget {
  NewTaskDialog({Key key, @required this.tasksType}) : super(key: key);

  final TasksCollectionType tasksType;

  _NewTaskDialogState createState() => _NewTaskDialogState();
}

class _NewTaskDialogState extends State<NewTaskDialog> {
  final _formKey = new GlobalKey<FormState>();

  String _name;
  String _type;
  double _durationH;

  static const _white = const  TextStyle(color: Colors.white);

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmit() {
    if (_validateAndSave()) {
      final task = TaskData(
        name: _name,
        type: _type,
        durationH: _durationH,
        tasksType: widget.tasksType,
        done: 0,
      );

      Navigator.pop(context, task);
    }
  }

  Widget _buildNameInput() {
    return TextFormField(
      keyboardType: TextInputType.text,
      maxLines: 1,
      decoration: InputDecoration(
        labelText: "Name",
      ),
      onSaved: (value) => _name = value,
      validator: (value) {
        if (value.isEmpty) {
          return "Name cannot be empty";
        }
        return null;
      },
    );
  }

  Widget _buildTypeInput() {
    return TextFormField(
      keyboardType: TextInputType.text,
      maxLines: 1,
      decoration: InputDecoration(
        labelText: "Type",
      ),
      onSaved: (value) => _type = value,
      validator: (value) {
        if (value.isEmpty) {
          return "Type cannot be empty";
        }
        return null;
      },
    );
  }

  Widget _buildDurationInput() {
    return TextFormField(
      keyboardType: TextInputType.number,
      maxLines: 1,
      decoration: InputDecoration(
        labelText: "Duration",
      ),
      onSaved: (value) => _durationH = double.parse(value),
      validator: (value) {
        if (value.isEmpty || double.parse(value) <= 0) {
          return "Duration cannot be empty/zero/egative";
        }
        return null;
      },
    );
  }

  Widget _buildMainDialogBox() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildNameInput(),
            _buildTypeInput(),
            _buildDurationInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return RaisedButton(
      onPressed: _validateAndSubmit,
      child: const Text(
        "SUBMIT",
        style: _white,
      ),
    );
  }

  Widget _buildCancelButton() {
    return RaisedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text(
        "CANCEL",
        style: _white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      title: const Text("New Task"),
      content: _buildMainDialogBox(),
      actions: <Widget>[_buildCancelButton(), _buildSubmitButton()],
    );
  }
}
