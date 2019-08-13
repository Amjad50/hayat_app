import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hayat_app/auth/emailauthdialog.dart';

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

  void _emailAction() {
    // elminiate double auth
    if (_loading) return;
    setState(() => _loading = true);

    Navigator.of(context)
        .push<bool>(MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) {
              return EmailAuthDialog();
            }))
        .then((value) {
      if (value != null && value) {
        widget.onlogin();
      }
    }).whenComplete(() {
      setState(() => _loading = false);
    });
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

    Padding _buildEmailButton(String label) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: RaisedButton(
          child: Text(label),
          onPressed: () => _emailAction(),
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
            _buildEmailButton("Sign-in/Sign-up"),
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
