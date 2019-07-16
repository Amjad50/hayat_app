import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hayat_app/page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.signout}) : super(key: key);

  final String title;
  final VoidCallback signout;

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

  PopupMenuButton _buildAppbarMenu() {
    // TODO: make into list
    return PopupMenuButton(
      onSelected: (value) {
        if (value == 1) {
          FirebaseAuth.instance.signOut().then((e) => widget.signout());
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            child: Text("sign out"),
            value: 1,
          )
        ];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          _buildAppbarMenu(),
        ],
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
