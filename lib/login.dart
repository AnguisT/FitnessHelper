import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'httpclient.dart';
import 'sqldb.dart';
import 'dart:async';

DBProvider dbProvider = new DBProvider();

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _Login createState() => new _Login();
}

class _Login extends State<Login> {

  HttpClient httpClient = new HttpClient();
  String loginText = '';
  String passwordText = '';
  int idText = 0; 
  String message = '';
  String authToken = '';
  String authSecret = '';
  bool isLoaded = false;
  bool error = false;
  bool closeDialog = false;

  @override
  void initState() {
    super.initState();
    _createDB();
    new Future.delayed(new Duration(seconds: 5), () {
      setState(() {
        isLoaded = true;
      });
    });
    User user = new User(login: 'Vlad', password: 'vlad');
    httpClient.newUserFirebase(user).then((onValue) {
      httpClient.getUserFirebase();
    });
  }

  _saveValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('userid', idText);
    prefs.setString('login', loginText);
    prefs.setString('password', passwordText);
    prefs.setString('auth_token', authToken);
    prefs.setString('auth_secret', authSecret);
  }

  void _createDB() {
    dbProvider.create();
  }

  TextEditingController _controllerLogin = new TextEditingController();
  TextEditingController _controllerPassword = new TextEditingController();
  TextEditingController _controllerWeight = new TextEditingController();
  TextEditingController _controllerHeight = new TextEditingController();

  @override
  Widget build(BuildContext context) {

    void _navigate() {
      Navigator.of(context).pushReplacementNamed('/home');
    }

    Future userDescript() async {
      AlertDialog alert = new AlertDialog(
        title: new Text('User Description'),
        content: new Container(
          height: 100.0,
          child: new Column(
            children: <Widget>[
              new Container(
                child: new Row(
                  children: <Widget>[
                    new Container(
                      width: MediaQuery.of(context).size.width * 0.54,
                      child: new TextField(
                        controller: _controllerHeight,
                        keyboardType: TextInputType.number,
                        decoration: new InputDecoration(
                          hintText: 'Height'
                        ),
                      ),
                    ),
                    new Container(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: new Text('cm')
                    ),
                  ],
                )
              ),
              new Container(
                child: new Row(
                  children: <Widget>[
                    new Container(
                      width: MediaQuery.of(context).size.width * 0.54,
                      child: new TextField(
                        controller: _controllerWeight,
                        keyboardType: TextInputType.number,
                        decoration: new InputDecoration(
                          hintText: 'Weight'
                        ),
                      ),
                    ),
                    new Container(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: new Text('kg')
                    ),
                  ],
                ) 
              ),
            ],
          )
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text('OK'),
            onPressed: () {
              httpClient.newWeightHeight(authToken, authSecret, _controllerHeight.text, _controllerWeight.text).then((status) {
                Navigator.pop(context);
                _navigate();
              });
            },
          ),
        ],
      );
      await showDialog(context: context, child: alert);
    }

    newAccount() {
      dbProvider.getAllUser().then((users) {
        if (users != null) {
          showDialog(
            context: context,
            child: new AlertDialog(
              title: new Text('You have one account'),
              content: new Text('Create a new account?'),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: new Text('No'),
                ),
                new FlatButton(
                  onPressed: () {
                    loginText = _controllerLogin.text;
                    passwordText = _controllerPassword.text;
                    User user = new User(login: loginText, password: passwordText);
                    httpClient.newUser(loginText).then((tokens) {
                      if (tokens != null) {
                        authToken = tokens['auth_token'];
                        authSecret = tokens['auth_secret'];
                        dbProvider.insertUser(user).then((_user) {
                          idText = _user.iduser;
                        });
                        userDescript().then((val) {
                          Navigator.pop(context);
                          _navigate();
                        });
                      }
                    });
                  },
                  child: new Text('Yes'),
                ),
              ],
            ),
          );
        } else {
          loginText = _controllerLogin.text;
          passwordText = _controllerPassword.text;
          User user = new User(login: loginText, password: passwordText);
          httpClient.newUser(loginText).then((tokens) {
            if (tokens != null) {
              dbProvider.insertUser(user).then((_user) {
                idText = _user.iduser;
              });
              authToken = tokens['auth_token'];
              authSecret = tokens['auth_secret'];
              _saveValues();
              userDescript().then((val) {
                Navigator.pop(context);
                _navigate();
              });
            }
          });
        }
      });
    }

    _signInOut() {
      error = false;
      if (_controllerLogin.text.isNotEmpty && _controllerPassword.text.isNotEmpty) {
        dbProvider.getUserByLogin(_controllerLogin.text).then((_user) {
          setState(() {
            if (_user != null) {
              loginText = _user.login;
              passwordText = _user.password;
              idText = _user.iduser;
              if (_user.password != _controllerPassword.text) {
                error = true;
                message = 'Login or password is invalid';
              } else {
                httpClient.getUser(loginText).then((tokens) {
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
        backgroundColor: Colors.orange,
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
                  color: Colors.orange[200],
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