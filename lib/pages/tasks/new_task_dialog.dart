import 'package:flutter/material.dart';
import 'package:hayat_app/pages/tasks/task_data.dart';
import 'package:hayat_app/pages/tasks/tasks_collection_types.dart';

class NewTaskDialog extends StatefulWidget {
  NewTaskDialog({Key key, @required this.tasksType, @required this.userTypes})
      : assert(userTypes != null && userTypes.isNotEmpty),
        super(key: key);

  final TasksCollectionType tasksType;
  final List<String> userTypes;

  _NewTaskDialogState createState() => _NewTaskDialogState();
}

class _NewTaskDialogState extends State<NewTaskDialog> {
  final _formKey = new GlobalKey<FormState>();

  String _name;
  int _typeIndex;
  double _durationH;

  static const _white = const TextStyle(color: Colors.white);

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
        typeIndex: _typeIndex,
        typeString: widget.userTypes[_typeIndex],
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
      decoration:
          InputDecoration(labelText: "Name", border: OutlineInputBorder()),
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
    final items = List<DropdownMenuItem<int>>(widget.userTypes.length);

    for (int i = 0; i < widget.userTypes.length; i++) {
      items[i] = DropdownMenuItem<int>(
        value: i,
        child: Text(widget.userTypes[i]),
      );
    }

    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: "Type",
        border: OutlineInputBorder(),
      ),
      items: items,
      value: _typeIndex,
      onChanged: (value) {
        setState(() => _typeIndex = value);
      },
      validator: (value) {
        if (value == null || value == -1) {
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
      decoration:
          InputDecoration(labelText: "Duration", border: OutlineInputBorder()),
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
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _buildNameInput(),
          _buildTypeInput(),
          _buildDurationInput(),
        ]
            .map(
              (e) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: e,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return FlatButton(
      onPressed: _validateAndSubmit,
      child: const Text(
        "SUBMIT",
        style: _white,
      ),
    );
  }

  Widget _buildCancelButton() {
    return FlatButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text(
        "CANCEL",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[_buildSubmitButton()],
        title: const Text("New Task"),
      ),
      body: _buildMainDialogBox(),
    );
  }
}
