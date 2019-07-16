import 'package:flutter/material.dart';
import 'package:hayat_app/page.dart';

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
      appBar: AppBar(
        title: Text(widget.title),
      ),
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