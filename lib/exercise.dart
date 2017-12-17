import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'drawer.dart';
import 'httpclient.dart';
import 'sqldb.dart' as db;

class _Page {
  _Page({ this.label, this.colors, this.icon });

  final String label;
  final MaterialColor colors;
  final IconData icon;

  Color get labelColor => colors != null ? colors.shade300 : Colors.grey.shade300;
  bool get fabDefined => colors != null && icon != null;
  Color get fabColor => colors.shade400;
  Icon get fabIcon => new Icon(icon);
}

final List<_Page> _allPages = <_Page>[
  new _Page(label: 'Search Exercise'),
  new _Page(label: 'Custom Exercise', colors: Colors.blue, icon: Icons.add),
];

class ExerciseEntries {
  ExerciseEntries({this.exerciseName, this.minutes, this.calories});
  String exerciseName;
  String minutes;
  String calories;
}

class CustomExerciseEntries {
  CustomExerciseEntries({this.customExerciseName, this.customMinutes, this.customCalories});
  String customExerciseName;
  String customMinutes;
  String customCalories;
}

List<ExerciseEntries> listExercise = <ExerciseEntries>[];
List<CustomExerciseEntries> listCustomExercise = <CustomExerciseEntries>[];

class Exercise extends StatefulWidget {
  
  @override
  _Exercise createState() => new _Exercise();
}

class _Exercise extends State<Exercise> with SingleTickerProviderStateMixin {

  HttpClient httpClient = new HttpClient();
  String authToken = '';
  String authSecret = '';
  int idUser = 0;
  bool isLoaded = true;
  bool selectTabBarTwo = false;
  bool radio1 = false;
  bool radio2 = false;
  bool radio3 = false;
  TabController controller;
  _Page _selectedPage;
  db.DBProvider dbProvider = new db.DBProvider();

  @override
  void initState() {
    super.initState();
    dbProvider.create().then((val) {
      getValues().then((val) {
        getAllCustomExercise();
      });
    });
    controller = new TabController(length: _allPages.length, vsync: this);
    controller.addListener(_handleTabSelection);
    _selectedPage = _allPages[0];
    getValues();
    showStartDialog();
  }

  int radioValue = 0;

  void handleRadioValueChanged(int value) {
    setState(() {
      radioValue = value;
    });
  }

  showStartDialog() async {
    showDialog(
      context: context,
      child: new AlertDialog(
        title: new Text('Select type exercise'),
        content: new Container(
          height: MediaQuery.of(context).size.height * 0.25, 
          child:new Column(
            children: <Widget>[
              new Text('Do you choose exercises depending on the type of exercises?'),
              new Text('The type of exercise can be changed in the profile.'),
            ],
          ),
        ),
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
            },
          )
        ],
      )
    );
  }

  void _handleTabSelection() {
    setState(() {
      _selectedPage = _allPages[controller.index];
    });
  }

  List<String> list = <String>['', 'mama'];

  Future getValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');
    authSecret = prefs.getString('auth_secret');
    idUser = prefs.getInt('userid');
  }

  Widget buildListTileExercise(BuildContext context, ExerciseEntries item) {
    return new MergeSemantics(
      child: new Container(
        child: new Column(
          children: <Widget>[
            new ListTile(
              title: new Text('Exercise: ' + item.exerciseName),
              subtitle: new Text('Minutes: ' + item.minutes + ', Calories: ' + item.calories),
            ),
            new Divider()
          ],
        )
      )
    );
  }

  Widget buildListTileCustomExercise(BuildContext context, CustomExerciseEntries item) {
    return new MergeSemantics(
      child: new Container(
        child: new Column(
          children: <Widget>[
            new ListTile(
              title: new Text('Exercise: ' + item.customExerciseName),
              subtitle: new Text('Minutes: ' + item.customMinutes + ', Calories: ' + item.customCalories),
            ),
            new Divider()
          ],
        )
      )
    );
  }

  getAllCustomExercise() {
    listCustomExercise.clear();
    dbProvider.getAllCustomExercise(idUser).then((customExercise) {
      print(customExercise);
      setState(() {
        if (customExercise != null) {
          for (int i = 0; i < customExercise.length; i++) {
            listCustomExercise.add(new CustomExerciseEntries(
              customExerciseName: customExercise[i]['customexercisename'],
              customCalories: customExercise[i]['customexercisecalories'].toString(),
              customMinutes: customExercise[i]['customexerciseminutes'].toString(),
            ));
          }
        }
      });
    });
  }

  searchExercise() {
    dbProvider.getExerciseByName(controllerTextExercise.text).then((exercise) {
      listExercise.clear();
      setState(() {
        if (exercise != null) {
          for (int i = 0; i < exercise.length; i++) {
            listExercise.add(new ExerciseEntries(
              exerciseName: exercise[i]['exercisename'],
              calories: exercise[i]['exercisecalories'].toString(),
              minutes: exercise[i]['exerciseminutes'].toString(),
            ));
          }
        }
        isLoaded = true;                            
      });
    });
  }

  Future addCustomExercise() async {
    dbProvider.insertCustomExercise(
      new db.CustomExercise(
        customexercisename: controllerNameExercise.text,
        customexercisecalories: int.parse(controllerCaloriesExercise.text),
        customexerciseminutes: int.parse(controllerMinutesExercise.text),
        customiduser: idUser,
      )
    ).then((val) {
      controllerNameExercise.text = '';
      controllerCaloriesExercise.text = '';
      controllerMinutesExercise.text = '';
      getAllCustomExercise();
    });
  }

  TextEditingController controllerTextExercise = new TextEditingController();
  TextEditingController controllerTextCustomExercise = new TextEditingController();
  TextEditingController controllerNameExercise = new TextEditingController();
  TextEditingController controllerCaloriesExercise = new TextEditingController();
  TextEditingController controllerMinutesExercise = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    
    Iterable<Widget> listTitlesExercise = listExercise.map((ExerciseEntries item) => buildListTileExercise(context, item));
    Iterable<Widget> listTitlesCustomExercise = listCustomExercise.map((CustomExerciseEntries item) => buildListTileCustomExercise(context, item));

    showDialogAdd() {
      showDialog(
        context: context,
        child: new AlertDialog(
          title: new Text('Add new custom exercise'),
          content: new Container(
            child: new Column(
              children: <Widget>[
                new TextField(
                  controller: controllerNameExercise,
                  decoration: new InputDecoration(
                    labelText: 'Name exercise',
                    hintText: 'Eneter name exercise',
                  ),
                ),
                new TextField(
                  controller: controllerCaloriesExercise,
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(
                    labelText: 'Calories',
                    hintText: 'Eneter count calories',
                  ),
                ),
                new TextField(
                  controller: controllerMinutesExercise,
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(
                    labelText: 'Minutes',
                    hintText: 'Eneter count minutes',
                  ),
                )
              ],
            )
          ),
          actions: <Widget> [
            new FlatButton(
              child: new Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text('OK'),
              onPressed: () {
                if (controllerNameExercise.text.isNotEmpty && controllerCaloriesExercise.text.isNotEmpty && controllerMinutesExercise.text.isNotEmpty) {
                  addCustomExercise().then((val) {
                    Navigator.of(context).pop();
                  });
                }
              },
            ),
          ]
        )
      );
    }

    var listTitleExercise = new Expanded(
      child: new ListView(
        padding: new EdgeInsets.symmetric(vertical: 4.0),
        children: listTitlesExercise.toList(),
      )
    );
    
    var listTitleCustomExercise = new Expanded(
      child: new ListView(
        padding: new EdgeInsets.symmetric(vertical: 4.0),
        children: listTitlesCustomExercise.toList(),
      )
    );

    var listViewProgress = new Expanded(
      child: new Container(
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
      )
    );

    return new Scaffold(
      drawer: new MyDrawer(),
      appBar: new AppBar(
        title: new Text('Exercise'),
        backgroundColor: Colors.blue,
        bottom: new TabBar(
          controller: controller,
          tabs: _allPages.map((_Page page) => new Tab(text: page.label)).toList(),
        )
      ),
      body: new TabBarView(
        controller: controller,
        children: <Widget>[
          new Container(
            child: new Center(
              child: new Column(
                children: <Widget>[
                  new Container(
                    padding: const EdgeInsets.all(10.0),
                    child: new Row(
                      children: <Widget>[
                        new Container(
                          width: MediaQuery.of(context).size.width * 3/4,
                          margin: const EdgeInsets.only(left: 20.0),
                          child: new TextField(
                            controller: controllerTextExercise,
                            decoration: new InputDecoration(
                              hintText: 'Enter name exercise',
                            ),
                          ),
                        ),
                        new IconButton(
                          icon: new Icon(Icons.search),
                          onPressed: () {
                            setState(() {
                              isLoaded = false;                            
                            });
                            searchExercise();
                          },
                        )
                      ],
                    ),
                  ),
                  isLoaded ? listTitleExercise : listViewProgress
                ],
              )
            )
          ),
          new Container(
            child: new Center(
              child: new Column(
                children: <Widget>[
                  new Container(
                    padding: const EdgeInsets.all(10.0),
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: new Container(
                      width: MediaQuery.of(context).size.width,
                      child: new TextField(
                        controller: controllerTextCustomExercise,
                        decoration: new InputDecoration(
                          hintText: 'Enter name custom exercise',
                        ),
                        onChanged: (value) {
                          dbProvider.getCustomExerciseByName(value).then((customExercise) {
                            setState(() {
                              if (customExercise != null) {
                                listCustomExercise.clear();
                                for (int i = 0; i < customExercise.length; i++) {
                                  listCustomExercise.add(new CustomExerciseEntries(
                                    customExerciseName: customExercise[i]['customexercisename'],
                                    customCalories: customExercise[i]['customexercisecalories'].toString(),
                                    customMinutes: customExercise[i]['customexerciseminutes'].toString(),
                                  ));
                                }
                              }
                            });
                          });
                        },
                      ),
                    ),
                  ),
                  listTitleCustomExercise                  
                ],
              ),
            )
          )
        ],
      ),
      floatingActionButton: !_selectedPage.fabDefined ? null : new FloatingActionButton(  
        tooltip: 'Add',
        elevation: 1.0,
        backgroundColor: _selectedPage.fabColor,
        child: _selectedPage.fabIcon,
        onPressed: () {
          showDialogAdd();
        },
      ),
    );
  }
}