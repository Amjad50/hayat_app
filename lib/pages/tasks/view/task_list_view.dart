import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hayat_app/pages/tasks/task_data.dart';
import 'package:hayat_app/pages/tasks/view/task_view.dart';

class TasksListView extends StatefulWidget {
  TasksListView({Key key, @required this.tasks}) : super(key: key);

  final List<TaskData> tasks;

  _TasksListViewState createState() => _TasksListViewState();
}

class _TasksListViewState extends State<TasksListView> {
  GlobalKey<AnimatedListState> _listKey = GlobalKey();
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

  void _delete() async {
    final refernces = List<DocumentReference>(_selected.length);
    int refI = 0;
    setState(() {
      _selected.forEach((i) {
        final task = widget.tasks[i];
        _listKey.currentState.removeItem(
          i,
          (a, b) => Container(),
          duration: Duration(milliseconds: 300),
        );

        refernces[refI++] = task.reference;
      });
      _selected.clear();
    });
    for (var ref in refernces) {
      await ref.delete();
    }
  }

  Widget _buildList() {
    return AnimatedList(
      key: _listKey,
      itemBuilder: (context, index, animation) {
        final taskView = TaskView(
            data: widget.tasks[index],
            onDoneChange: (value) {
              widget.tasks[index].reference.updateData({DONE: value});
            },
            selected: _selected.contains(index));

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: taskView,
          onLongPress: () {
            _select(index, !taskView.selected);
          },
          onTap: () {
            if (_selected.isNotEmpty) _select(index, !taskView.selected);
          },
        );
      },
      initialItemCount: widget.tasks.length,
    );
  }

  Widget _buildDeleteButton() {
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      color: Colors.red.shade500,
      icon: const Icon(Icons.delete),
      label: const Text("DELETE SELECTED"),
      onPressed: () {
        _delete();
      },
    );
  }

  Widget _buildCrossAnimatedDeleteButton() {
    return AnimatedCrossFade(
      crossFadeState: _selected.isNotEmpty
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: Duration(milliseconds: 500),
      firstChild: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: _buildDeleteButton(),
      ),
      secondChild: Container(),
      layoutBuilder: (wtop, ktop, wbottom, kbottom) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[wbottom, wtop],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        _buildList(),
        _buildCrossAnimatedDeleteButton(),
      ],
    );
  }
}
