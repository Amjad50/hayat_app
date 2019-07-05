import 'package:flutter/material.dart';

PreferredSize makeAppBarHeroFix(AppBar _bar) {
  return PreferredSize(
    child: Hero(
      child: _bar,
      tag: AppBar,
    ),
    preferredSize: AppBar().preferredSize,
  );
}
