import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'httpclient.dart';
import 'sqldb.dart';
import 'dart:async';

String typeExercise = 'Athletics';
HttpClient httpClient = new HttpClient();
TextEditingController _controllerLogin = new TextEditingController();
TextEditingController _controllerPassword = new TextEditingController();
TextEditingController _controllerWeight = new TextEditingController();
TextEditingController _controllerHeight = new TextEditingController();
TextEditingController _controllerNorm = new TextEditingController();
TextEditingController _controllerReset = new TextEditingController();
String loginText = '';
String passwordText = '';
int idText = 0; 
String message = '';
String authToken = '';
String authSecret = '';
bool isLoaded = false;
bool error = false;
bool closeDialog = false;
List<int> idTypeExercise = <int>[];
List<String> nameTypeExercise = <String>[];
int typeexerciseid;
int caloriesnorm;

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _Login createState() => new _Login();
}

class _Login extends State<Login> {

  @override
  void initState() {
    super.initState();
    new Future.delayed(new Duration(seconds: 5), () {
      setState(() {
        isLoaded = true;
      });
    });
  }

  _saveValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('userid', idText);
    prefs.setString('login', loginText);
    prefs.setString('auth_token', authToken);
    prefs.setString('auth_secret', authSecret);
    prefs.setInt('idtypeexercise', typeexerciseid);
    prefs.setInt('caloriesnorm', caloriesnorm);
  }

  @override
  Widget build(BuildContext context) {

    void _navigate() {
      Navigator.of(context).pushReplacementNamed('/home');
    }

    newUser() async {
      await httpClient.getAllTypeExercise().then((typeexercise) {
        for (int i = 0; i < typeexercise.length; i++) {
          nameTypeExercise.add(typeexercise[i]['nametypeexercise']);
          idTypeExercise.add(typeexercise[i]['typeexerciseid']);
        }
      });
      Navigator.push(context, new MaterialPageRoute(
        builder: (BuildContext context) => new DescUserDialog(),
        fullscreenDialog: true,
      ));
      // userDescript();
    }

    newAccount() {
      showDialog(
        context: context,
        child: new AlertDialog(
          title: new Text('Do you want to create a new account?'),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                newUser();
              },
            ),
          ]
        )
      );
    }

    _signInOut() {
      error = false;
      if (_controllerLogin.text.isNotEmpty && _controllerPassword.text.isNotEmpty) {
        httpClient.getUserByLogin(_controllerLogin.text).then((_user) {
          setState(() {
            if (_user.isNotEmpty) {
              isLoaded = false;
              loginText = _user[0]['login'];
              passwordText = _user[0]['password'];
              idText = _user[0]['userid'];
              if (_user[0]['password'] != _controllerPassword.text) {
                error = true;
                message = 'Login or password is invalid';
              } else {
                httpClient.getUser(loginText).then((tokens) {
                  typeexerciseid = _user[0]['idtypeexercise'];
                  caloriesnorm = _user[0]['caloriesnorm'];
                  authToken = tokens['auth_token'];
                  authSecret = tokens['auth_secret'];
                  _saveValues();
                  _navigate();
                });
              }
            } else {
              newAccount();
            }
          });
        });
      } else {
        setState(() {
          error = true;
          message = 'Login or password is empty';
        });
      }
    }

    var errorMessage = new Text(message, style: new TextStyle(color: Colors.red),);

    var body = new Scaffold(
      appBar: new AppBar(
        title: new Text('Login'),
        backgroundColor: Colors.blue,
      ),
      body: new Container(
        padding: new EdgeInsets.all(10.0),
        child: new Column(
          children: <Widget>[
            error ? errorMessage : new Container(),
            new TextField(
              controller: _controllerLogin,
              decoration: new InputDecoration(
                labelText: 'Login',
                hintText: 'Enter your login',
              ),
            ),
            new TextField(
              controller: _controllerPassword,
              decoration: new InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
              ),
              obscureText: true,
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              child: new Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: new RaisedButton(
                  color: Colors.blue,
                  child: new Text('Login/SignUp', style: new TextStyle(color: Colors.white)),                
                  onPressed: () {
                    _signInOut();
                  },
                )
              )
            ),
          ]
        ),
      )
    );

    var bodyProgress = new Container(
      color: Colors.white,
      child: new Center(
        child: new SizedBox(
          height: 50.0,
          width: 50.0,
          child: new CircularProgressIndicator(
            value: null,
            strokeWidth: 7.0,
          ),
        ),
      ),
    );

    return isLoaded ? body : bodyProgress;
  }
}

class DescUserDialog extends StatefulWidget {
  @override
  DescUserDialogState createState() => new DescUserDialogState();
}

class DescUserDialogState extends State<DescUserDialog> {

  Future<bool> _onWillPop() async {
    return false;
  }

  void _navigate() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  _saveValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('userid', idText);
    prefs.setString('login', loginText);
    prefs.setString('auth_token', authToken);
    prefs.setString('auth_secret', authSecret);
    prefs.setInt('typeexerciseid', typeexerciseid);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    saveDesc() {
      typeexerciseid = nameTypeExercise.indexOf(typeExercise);
      User user = new User(
        login: _controllerLogin.text,
        password: _controllerPassword.text,
        caloriesnorm: int.parse(_controllerNorm.text),
        resetcalories: int.parse(_controllerReset.text),
        idtypeexercise: typeexerciseid + 1
      );
      httpClient.newUser(loginText).then((tokens) {
        if (tokens != null) {
          httpClient.newUserServer(user).then((value) async {
            if (value.isNotEmpty) {
              idText = value[0]['userid'];
              authToken = tokens['auth_token'];
              authSecret = tokens['auth_secret'];
              await _saveValues();
              httpClient.newWeightHeight(authToken, authSecret, _controllerHeight.text, _controllerWeight.text).then((status) {
                Navigator.pop(context);
                _navigate();
              });
            }
          });
        } else {
          setState(() {
            Navigator.pop(context);
            error = true;
            message = 'This login is already in use';
          });
        }
      });
    }

    return new Scaffold(
      appBar: new AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Description user'),
        actions: <Widget> [
          new FlatButton(
            child: new Text('SAVE', style: theme.textTheme.body1.copyWith(color: Colors.white)),
            onPressed: () {
              if (_controllerHeight.text.isNotEmpty && _controllerWeight.text.isNotEmpty && _controllerNorm.text.isNotEmpty && _controllerReset.text.isNotEmpty) {
                saveDesc();
              }
            }
          )
        ]
      ),
      body: new Form(
        onWillPop: _onWillPop,
        child: new ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            new Container(
              child: new TextField(
                controller: _controllerHeight,
                keyboardType: TextInputType.number,
                decoration: new InputDecoration(
                  hintText: 'Enter you height',
                  labelText: 'Height cm',
                ),
              ),
            ),
            new Container(
              child: new TextField(
                controller: _controllerWeight,
                keyboardType: TextInputType.number,
                decoration: new InputDecoration(
                  hintText: 'Enter you weight',
                  labelText: 'Weight kg',
                ),
              ),
            ),
            new Container(
              child: new Container(
                child: new TextField(
                  controller: _controllerNorm,
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(
                    hintText: 'Enter you calories norm',
                    labelText: 'Calories norm',
                  ),
                ),
              ),
            ),
            new Container(
              child: new Container(
                child: new TextField(
                  controller: _controllerReset,
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(
                    hintText: 'Enter the quantity how much you want to lose calories',
                    labelText: 'Reset norm',
                  ),
                ),
              ),
            ),
            new DropdownButtonHideUnderline(
              child: new InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Type exercise',
                  hintText: 'Choose an type exercise',
                ),
                isEmpty: typeExercise == null,
                child: new DropdownButton<String>(
                  value: typeExercise,
                  isDense: true,
                  onChanged: (String newValue) {
                    setState(() {
                      typeExercise = newValue;
                    });
                  },
                  items: nameTypeExercise.map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                ),
              ),
            )
          ]
          .map((Widget child) {
            return new Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              height: 96.0,
              child: child
            );
          })
          .toList()
        )
      ),
    );
  }
}