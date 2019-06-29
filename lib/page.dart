import 'package:flutter/material.dart';
import 'package:hayat_app/pages/articles.dart';
import 'package:hayat_app/pages/statistics.dart';
import 'package:hayat_app/pages/tasks.dart';

final allPages = <_Page>[
  _Page(
    label: "Articles",
    widget: ArticlesPage(),
    color: Colors.redAccent,
    icon: Icons.label_outline,
  ),
  _Page(
    label: "Tasks",
    widget: TasksPage(),
    color: Colors.greenAccent,
    icon: Icons.dashboard,
  ),
  _Page(
    label: "Stastics",
    widget: StatisticsPage(),
    color: Colors.amberAccent,
    icon: Icons.language,
  ),
];

class _Page {
  _Page({this.label, this.widget, this.color, this.icon});

  final String label;
  final Widget widget;
  final Color color;
  final IconData icon;
}

