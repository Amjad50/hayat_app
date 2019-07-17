import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hayat_app/auth.dart';
import 'package:hayat_app/home.dart';
import 'package:hayat_app/loginsignup.dart';

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
      home: RootPage(title: _TITLE),
    );
  }
}

class RootPage extends StatefulWidget {
  RootPage({Key key, this.title}) : super(key: key);

  final String title;
  // TODO: group multiple auth handlers into one
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthState _state = AuthState.NOT_DETERMINED;
  String _uid = "";

  @override
  void initState() {
    super.initState();

    _reloadUser();
  }

  void _reloadUser() {
    FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        if (user != null && user.uid.isNotEmpty) {
          _state = AuthState.AUTHENTICATED;
          _uid = user.uid;
        } else {
          _state = AuthState.NOT_AUTHENTICATED;
        }
      });
    });
  }

  void _signout() {
    widget._googleSignIn.signOut();
    _reloadUser();
  }

  Widget _buildLoading() {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case AuthState.AUTHENTICATED:
        return HomePage(
          title: widget.title,
          signout: _signout,
          uid: _uid
        );
        break;
      case AuthState.NOT_AUTHENTICATED:
        return LoginSignupPage(onlogin: _reloadUser, googleSignIn: widget._googleSignIn,);
        break;
      case AuthState.NOT_DETERMINED:
        return _buildLoading();
        break;
    }

    return _buildLoading();
  }
}
