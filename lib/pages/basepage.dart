
import 'package:flutter/material.dart';

abstract class BasePage extends StatefulWidget {
  BasePage({Key key, this.uid}) : super(key: key);

  final String uid;
}