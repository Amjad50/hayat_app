import 'package:flutter/material.dart';
import 'package:hayat_app/page.dart';
import 'package:hayat_app/utils.dart';

void main() => runApp(MainApp());

class MainApp extends StatelessWidget {
  static const _TITLE = "Hayat App";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _TITLE,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: _TITLE),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index;

  @override
  void initState() {
    super.initState();
    _index = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: makeAppBarHeroFix(AppBar(
        title: Text(widget.title),
      )),
      body: Container(
        child: allPages[_index].widget,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: allPages
            .map(
              (page) => BottomNavigationBarItem(
                backgroundColor: page.color,
                title: Text(page.label),
                icon: Icon(page.icon),
              ),
            )
            .toList(),
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          setState(() {
            _index = i;
          });
        },
      ),
    );
  }
}
