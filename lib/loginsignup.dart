import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum _Mode { SIGNIN, SIGNUP }

class LoginSignupPage extends StatefulWidget {
  LoginSignupPage({Key key, this.onlogin, this.googleSignIn}) : super(key: key);

  final VoidCallback onlogin;
  final GoogleSignIn googleSignIn;

  _LoginSignupPageState createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  bool _loading = false;

  void _googleAction() {
    // elminiate double auth
    if (_loading) return;

    setState(() => _loading = true);

    Future<void> _proceedLogin() async {
      final GoogleSignInAccount googleSignInAccount =
          await widget.googleSignIn.signIn();

      if (googleSignInAccount == null) return;
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      if (googleSignInAuthentication == null) return;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final FirebaseUser user =
          await FirebaseAuth.instance.signInWithCredential(credential);

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);
    }

    _proceedLogin().then((user) {
      setState(() => _loading = false);
      widget.onlogin();
    });
  }

  void _emailAction(_Mode mode) {
    // elminiate double auth
    if (_loading) return;
    switch (mode) {
      case _Mode.SIGNIN:
        setState(() => _loading = true);
        FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: "user@test.com", password: "password")
            .then((user) {
          setState(() => _loading = false);
          widget.onlogin();
        }).catchError((error) {
          print((error as Exception));
          setState(() => _loading = false);
        });
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
      label: const Text("Sign-in via Google"),
      onPressed: _googleAction,
    );
  }

  Widget _buildEmailButtons() {
    const labelColor = const Color.fromARGB(255, 115, 115, 115);

    Padding _buildEmailButton(String label, _Mode mode) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: RaisedButton(
          child: Text(label),
          onPressed: () => _emailAction(mode),
        ),
      );
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 30.0, bottom: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: const Icon(
                  Icons.email,
                  color: labelColor,
                ),
              ),
              const Text(
                "EMAIL",
                style: TextStyle(
                  fontSize: 16,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildEmailButton("Sign-in", _Mode.SIGNIN),
            _buildEmailButton("Sign-up", _Mode.SIGNUP)
          ],
        ),
      ],
    );
  }

  Widget _buildLoading() {
    if (_loading)
      return Container(
        child: CircularProgressIndicator(),
        padding: EdgeInsets.symmetric(horizontal: 60, vertical: 30),
        decoration: BoxDecoration(
            color: Colors.black45, borderRadius: BorderRadius.circular(5)),
      );
    else
      return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Stack(alignment: Alignment.center, children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildGoogleButton(),
              _buildEmailButtons(),
            ],
          ),
          _buildLoading()
        ]),
      ),
    );
  }
}
