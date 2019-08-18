import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hayat_app/pages/tasks/task_data.dart';
import 'package:hayat_app/pages/tasks/tasks_collection_types.dart';
import 'package:hayat_app/pages/tasks/view/task_view.dart';

class TasksListView extends StatefulWidget {
  TasksListView({Key key, @required this.tasks, @required this.tasksType})
      : super(key: key);

  final List<TaskData> tasks;
  final TasksCollectionType tasksType;

  _TasksListViewState createState() => _TasksListViewState();
}

class _TasksListViewState extends State<TasksListView> {
  _TasksListViewState() : _selected = HashSet<DocumentReference>();

  final HashSet<DocumentReference> _selected;

  void _select(DocumentReference reference, bool isSelect) {
    setState(() {
      if (isSelect)
        _selected.add(reference);
      else
        _selected.remove(reference);
    });
  }

  void _delete() {
    setState(() {
      _selected.forEach((r) {
        widget.tasks.removeWhere((e) => e.reference == r);
        r.delete();
      });

      _selected.clear();
    });
  }

  Widget _buildLabel(String label) {
    return Text(label);
  }

  Widget _buildItem(TaskData task) {
    final taskView = TaskView(
        data: task,
        onDoneChange: (value) {
          setState(() {
            task.reference.updateData({DONE: value});
          });
        },
        selected: _selected.contains(task.reference));

    return GestureDetector(
      key: ValueKey(task.hashCode),
      behavior: HitTestBehavior.opaque,
      child: taskView,
      onLongPress: () {
        _select(task.reference, !taskView.selected);
      },
      onTap: () {
        if (_selected.isNotEmpty) _select(task.reference, !taskView.selected);
      },
    );
  }

  Widget _buildList() {
    // sort the list
    widget.tasks.sort(TaskData.byTypeComparator);

    bool buildNotDone = false, buildDone = false;

    List<TaskData> notDoneTasks, doneTasks;
    if (widget.tasksType != TasksCollectionType.ROUTINE_TASKS) {
      notDoneTasks = widget.tasks.where((e) => e.done != 100).toList();
      buildNotDone = notDoneTasks.isNotEmpty;

      doneTasks = widget.tasks.where((e) => e.done == 100).toList();
      buildDone = doneTasks.isNotEmpty;
    } else {
      notDoneTasks = widget.tasks;
      doneTasks = [];

      // do not build any labels
    }

    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildListDelegate(
            [buildNotDone ? _buildLabel("NOT DONE") : Container()],
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return _buildItem(notDoneTasks[index]);
            },
            childCount: notDoneTasks.length,
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [buildDone ? _buildLabel("DONE") : Container()],
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return _buildItem(doneTasks[index]);
            },
            childCount: doneTasks.length,
          ),
        ),
      ],
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
