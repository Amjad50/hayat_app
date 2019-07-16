import 'package:flutter/material.dart';

enum _Mode { LOGIN, SIGNUP }

class LoginSignupPage extends StatefulWidget {
  LoginSignupPage({Key key, this.onlogin}) : super(key: key);

  final VoidCallback onlogin;

  _LoginSignupPageState createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  _Mode _formMode = _Mode.LOGIN;

  void _switchMode() {
    setState(() {
      _formMode = _formMode == _Mode.LOGIN ? _Mode.SIGNUP : _Mode.LOGIN;
    });
  }

  void _googleAction() {
    // TODO: hangle google auth
  }

  void _emailAction() {
    switch(_formMode) {
      case _Mode.LOGIN:
        // TODO: Handle this case.
        break;
      case _Mode.SIGNUP:
        // TODO: Handle this case.
        break;
    }
  }

  Widget _buildGoogleButton() {
    return RaisedButton.icon(
      // TODO: use google icon
      icon: const Icon(
        IconData(71, fontFamily: "Sans"),
      ),
      label: Text(
        (_formMode == _Mode.SIGNUP ? "Sign up" : "Login") + " via Google",
      ),
      onPressed: _googleAction,
    );
  }

  Widget _buildEmailButton() {
    return RaisedButton.icon(
      icon: Icon(Icons.email),
      label: Text(
          (_formMode == _Mode.SIGNUP ? "Sign up" : "Login") + " via Email"),
      onPressed: _emailAction,
    );
  }

  Widget _buildSwitchButon() {
    return FlatButton.icon(
      icon: Icon(Icons.play_arrow),
      label:
          Text("Switch to " + (_formMode == _Mode.LOGIN ? "Sign up" : "Login")),
      onPressed: _switchMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildGoogleButton(),
          _buildEmailButton(),
          _buildSwitchButon(),
        ],
      ),
    );
  }
}
