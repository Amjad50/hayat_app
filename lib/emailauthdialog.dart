import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum _FormMode { SIGNIN, SIGNUP }

class EmailAuthDialog extends StatefulWidget {
  EmailAuthDialog({Key key}) : super(key: key);

  _EmailAuthDialogState createState() => _EmailAuthDialogState();
}

class _EmailAuthDialogState extends State<EmailAuthDialog> {
  final _formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _emailError;
  String _passwordError;

  _FormMode _formMode;

  bool _loading;

  @override
  void initState() {
    _resetErrors();
    _loading = false;
    _formMode = _FormMode.SIGNIN;
    super.initState();
  }

  void _resetErrors() {
    _passwordError = "";
    _emailError = "";
  }

  void _switchMode() {
    _formKey.currentState.reset();
    setState(() {
      _formMode =
          _formMode == _FormMode.SIGNIN ? _FormMode.SIGNUP : _FormMode.SIGNIN;
    });
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void _validateAndSubmit() async {
    setState(() {
      _resetErrors();
      _loading = true;
    });
    if (_validateAndSave()) {
      FirebaseUser firebaseUser;
      String uid = "";
      try {
        if (_formMode == _FormMode.SIGNIN) {
          firebaseUser = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: _email, password: _password);
          uid = firebaseUser.uid;
          print('Signed in: $uid');
        } else {
          firebaseUser = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: _email, password: _password);
          uid = firebaseUser.uid;
          print('Signed up user: $uid');
        }

        setState(() {
          _loading = false;
        });

        if (uid != null && uid.length > 0) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _loading = false;
        });
        showDialog(
            builder: (context) {
              return AlertDialog(
                content: Text((e as PlatformException).message),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("OKAY"),
                  )
                ],
              );
            },
            context: context);
      }
    }
  }

  Widget _buildLoading() {
    if (_loading)
      return Container(child: CircularProgressIndicator());
    else
      return Container();
  }

  Widget _buildEmailInput() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      maxLines: 1,
      decoration: InputDecoration(
        labelText: "Email",
        icon: const Icon(Icons.email),
        errorText: _emailError.isNotEmpty ? _emailError : null,
      ),
      onSaved: (value) => _email = value,
      validator: (value) {
        if (value.isEmpty) {
          setState(() {
            _loading = false;
          });
          return "Email cannot be empty";
        }
        if (!RegExp(
          "^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\\.[a-zA-Z0-9]+\$",
        ).hasMatch(value)) {
          setState(() {
            _loading = false;
          });
          return "The email provided is not valid";
        }
        return null;
      },
    );
  }

  Widget _buildPasswordInput() {
    return TextFormField(
      keyboardType: TextInputType.text,
      obscureText: true,
      maxLines: 1,
      decoration: InputDecoration(
        labelText: "Password",
        icon: const Icon(Icons.lock),
        errorText: _passwordError.isNotEmpty ? _passwordError : null,
      ),
      onSaved: (value) => _password = value,
      validator: (value) {
        if (value.isEmpty) {
          setState(() {
            _loading = false;
          });
          return "Password cannot be empty";
        }
        if (value.length < 8) {
          setState(() {
            _loading = false;
          });
          return "Password length is too short (must be 8 or more)";
        }
        return null;
      },
    );
  }

  Widget _buildButtons() {
    return RaisedButton(
      child: Text(
        _formMode == _FormMode.SIGNIN ? "Sign-in" : "Sign-up",
      ),
      onPressed: _validateAndSubmit,
    );
  }

  Widget _buildSwitchButton() {
    return FlatButton(
      child: Text(
        _formMode == _FormMode.SIGNIN
            ? "New here? Sign-up"
            : "Already have an account? Sign-in",
      ),
      onPressed: _switchMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildLoading(),
            Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  _buildEmailInput(),
                  _buildPasswordInput(),
                  _buildButtons(),
                  _buildSwitchButton()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
