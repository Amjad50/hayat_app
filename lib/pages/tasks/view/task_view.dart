import 'package:flutter/material.dart';
import 'package:hayat_app/pages/tasks/task_data.dart';
import 'package:hayat_app/pages/tasks/view/slider_theme.dart';

class TaskView extends StatefulWidget {
  TaskView({Key key, this.data}) : super(key: key);

  final TaskData data;

  _TaskViewState createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  double _donePercent = 0;
  bool _changing = false;

  @override
  void initState() {
    super.initState();
    _donePercent = widget.data.done?.toDouble();
  }

  Widget _buildSlider() {
    assert(_donePercent >= 0 && _donePercent <= 100);
    return SliderTheme(
      child: Slider(
        onChanged: (value) => setState(() => _donePercent = value),
        onChangeStart: (e) {
          setState(() {
            _changing = true;
          });
        },
        onChangeEnd: (e) {
          setState(() {
            _changing = false;
          });
          // TODO: update change to firebase
        },
        value: _donePercent,
        min: 0,
        max: 100,
        divisions: 20,
      ),
      data: TasksSliderThemeData.get_theme(context),
    );
  }

  Widget _buildDoneCheckBox() {
    return Checkbox(
      value: _donePercent == 100,
      onChanged: (value) {
        setState(() {
          _donePercent = value ? 100 : 0;
        });
      },
    );
  }

  Widget _buildProgressRow() {
    if (_donePercent == null) return Container();
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Flexible(
          child: _buildSlider(),
        ),
        _buildDoneCheckBox()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Material(
        borderRadius: BorderRadius.circular(5),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    widget.data.name,
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  AnimatedCrossFade(
                    duration: Duration(milliseconds: 150),
                    crossFadeState: _changing
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Text(
                      "${_donePercent?.toInt()}",
                      style: TextStyle(color: Theme.of(context).accentColor),
                    ),
                    secondChild: Container(),
                  )
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: <Widget>[
                    Text(
                      widget.data.type,
                      style: Theme.of(context).textTheme.body1.copyWith(
                            color: Theme.of(context).textTheme.caption.color,
                          ),
                    ),
                    Spacer(),
                    Material(
                      color: Colors.green, // TODO: change color
                      borderRadius: BorderRadius.circular(2),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.timer, // TODO: use diff icon
                              size: Theme.of(context).textTheme.body1.fontSize,
                            ),
                            Container(
                              width: 8,
                            ),
                            Text("${widget.data.durationH}",
                                style: Theme.of(context).textTheme.body1),
                          ],
                        ),
                      ),
                    ),
                    Spacer(
                      flex: 30,
                    )
                  ],
                ),
              ),
              _buildProgressRow()
            ],
          ),
        ),
      ),
    );
  }
}
