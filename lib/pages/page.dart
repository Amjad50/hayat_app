import 'package:flutter/material.dart';
import 'package:hayat_app/pages/articles.dart';
import 'package:hayat_app/pages/basepage.dart';
import 'package:hayat_app/pages/statistics/statistics.dart';
import 'package:hayat_app/pages/tasks/tasks.dart';

final allPages = <_Page>[
  _Page(
    label: "Articles",
    widget: ({String uid}) => ArticlesPage(uid: uid),
    color: Colors.redAccent,
    icon: Icons.label_outline,
  ),
  _Page(
    label: "Tasks",
    widget: ({String uid}) => TasksPage(uid: uid),
    color: Colors.greenAccent,
    icon: Icons.dashboard,
  ),
  _Page(
    label: "Stastics",
    widget: ({String uid}) => StatisticsPage(uid: uid),
    color: Colors.amberAccent,
    icon: Icons.language,
  ),
];

class _Page {
  _Page({this.label, this.widget, this.color, this.icon});

  final String label;
  final BasePage Function({@required String uid}) widget;
  final Color color;
  final IconData icon;
}

