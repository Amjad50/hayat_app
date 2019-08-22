import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hayat_app/DB/firestore_handler.dart';
import 'package:hayat_app/pages/page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.signout, this.uid})
      : assert(uid != null),
        super(key: key);

  final String title;
  final VoidCallback signout;
  final String uid;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index;

  bool _loading;

  @override
  void initState() {
    super.initState();
    _loading = true;
    FireStoreHandler.instance
        .init(widget.uid)
        .then((_) => setState(() => _loading = false));
    _index = 1;
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

  Widget _buildLoading() {
    return const Center(child: const CircularProgressIndicator());
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
      body: _loading
          ? _buildLoading()
          : Container(
              child: allPages[_index].widget(),
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
