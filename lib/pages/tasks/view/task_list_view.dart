import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:hayat_app/pages/tasks/task_data.dart';
import 'package:hayat_app/pages/tasks/view/task_view.dart';

class TasksListView extends StatefulWidget {
  TasksListView({Key key, @required this.tasks}) : super(key: key);

  final List<TaskData> tasks;

  _TasksListViewState createState() => _TasksListViewState();
}

class _TasksListViewState extends State<TasksListView> {
  _TasksListViewState() {
    _selected = HashSet<int>();
  }
  HashSet<int> _selected;

  void _select(int index, bool isSelect) {
    setState(() {
      if (isSelect)
        _selected.add(index);
      else
        _selected.remove(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final taskView = TaskView(
          data: widget.tasks[index],
          onDoneChange: (value) {
            widget.tasks[index].reference.updateData({DONE: value});
          },
          selected: _selected.contains(index)
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: taskView,
          onLongPress: () {
            _select(index, !taskView.selected);
          },
          onTap: () {
            if (_selected.isNotEmpty)
              _select(index, !taskView.selected);
          },
        );
      },
      itemCount: widget.tasks.length,
    );
  }
}
