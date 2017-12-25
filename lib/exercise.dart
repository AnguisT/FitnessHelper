import 'dart:async';
import 'dart:math';
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
  ExerciseEntries({this.exerciseName, this.minutes, this.calories, this.typeexerciseid});
  String exerciseName;
  String minutes;
  String calories;
  int typeexerciseid;
}

class CustomExerciseEntries {
  CustomExerciseEntries({this.idcustomexercise, this.customExerciseName, this.customMinutes, this.customCalories, this.iduser,this.timedayid});
  String idcustomexercise;
  String customExerciseName;
  String customMinutes;
  String customCalories;
  String timedayid;
  String iduser;
}

class TimeDay {
  TimeDay({this.idtimeday, this.timeday});
  String idtimeday;
  String timeday;
}

List<ExerciseEntries> listExercise = <ExerciseEntries>[];
List<CustomExerciseEntries> listCustomExercise = <CustomExerciseEntries>[];
List<TimeDay> listTimeDay = <TimeDay>[];

class Exercise extends StatefulWidget {
  
  @override
  _Exercise createState() => new _Exercise();
}

class _Exercise extends State<Exercise> with SingleTickerProviderStateMixin {

  HttpClient httpClient = new HttpClient();
  String authToken = '';
  String authSecret = '';
  String timedayid = '';
  int idUser = 0;
  bool isLoaded = true;
  bool selectTabBarTwo = false;
  bool radio1 = false;
  bool radio2 = false;
  bool radio3 = false;
  int remainder;
  int typeexerciseid;
  TabController controller;
  _Page _selectedPage;
  TextEditingController controllerTextExercise = new TextEditingController();
  TextEditingController controllerTextCustomExercise = new TextEditingController();
  TextEditingController controllerNameExercise = new TextEditingController();
  TextEditingController controllerCaloriesExercise = new TextEditingController();
  TextEditingController controllerMinutesExercise = new TextEditingController();
  TextEditingController controllerNameTimeDay = new TextEditingController();

  @override
  void initState() {
    super.initState();
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

  List<ExerciseEntries> listExerciseAutomaticly = <ExerciseEntries>[];

  saveValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var caloriesnorm = prefs.getInt('caloriesnorm');
    prefs.setInt('remainder', caloriesnorm);
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
              listExercise.clear();
              httpClient.getAllExercise().then((exercise) {
                Random rng = new Random();
                var length = exercise.length;
                var norm = 0;
                print(norm);
                print(remainder);
                while(norm < remainder) {
                  var randomIndex = rng.nextInt(length);
                  setState(() {
                    var newexercise = new ExerciseEntries(
                      exerciseName: exercise[randomIndex]['exercisename'],
                      calories: exercise[randomIndex]['exercisecalories'].toString(),
                      minutes: exercise[randomIndex]['exerciseminutes'].toString(),
                      typeexerciseid: exercise[randomIndex]['idtypeexercise']
                    );
                    if (listExercise.isNotEmpty) {
                      for (int i = 0; i < listExercise.length; i++) {
                        if ((listExercise[i].exerciseName != newexercise.exerciseName) && (newexercise.typeexerciseid == typeexerciseid)) {
                          print(listExercise.indexOf(newexercise));
                          norm += int.parse(newexercise.calories);
                          i = listExercise.length;
                          listExercise.add(newexercise);
                        }
                      }
                    } else {
                      listExercise.add(newexercise);
                    }
                  });
                }
              });
              saveValues();
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

  Future getValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');
    authSecret = prefs.getString('auth_secret');
    idUser = prefs.getInt('userid');
    typeexerciseid = prefs.getInt('idtypeexercise');
    remainder = prefs.getInt('remainder');
    print(remainder);
    getAllCustomExercise();
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

  Widget buildListTileTimeDay(BuildContext context, TimeDay item) {
    timedayid = item.idtimeday;
    return new MergeSemantics(
      child: new Container(
        child: new Column(
          children: <Widget>[
            new ListTile(
              title: new Text('Time day: ' + item.timeday),
              trailing: new IconButton(
                icon: new Icon(Icons.add),
                onPressed: () {
                  showDialogAddCustomExercise(item.idtimeday);
                },
              ),
            ),
            new Divider(),
            new Container(
              height: 180.0,
              child: new ListView(
                padding: new EdgeInsets.symmetric(vertical: 4.0),
                children: listTitlesCustomExercise.toList(),
              )
            )
          ],
        )
      )
    );
  }

  Widget buildListTileCustomExercise(BuildContext context, CustomExerciseEntries item) {
    return item.timedayid == timedayid ? new MergeSemantics(
      child: new Container(
        padding: const EdgeInsets.only(left: 20.0),
        child: new Column(
          children: <Widget>[
            new ListTile(
              title: new Text('Exercise: ' + item.customExerciseName),
              subtitle: new Text('Minutes: ' + item.customMinutes + ', Calories: ' + item.customCalories),
              trailing: new IconButton(
                icon: new Icon(Icons.remove),
                onPressed: () {
                  httpClient.deleteCustomExercise(item.idcustomexercise).then((val) {
                    getAllCustomExercise();
                  });
                },
              ),
            ),
            new Divider(),
          ],
        )
      )
    ) : new Container();
  }

  getAllTimeDay() async {
    listTimeDay.clear();
    await httpClient.getAllTimeDay().then((timeDay) {
      setState(() {
        if (timeDay != null) {
          for (int i = 0; i < timeDay.length; i++) {
            listTimeDay.add(new TimeDay(
              idtimeday: timeDay[i]['idtimeday'].toString(),
              timeday: timeDay[i]['timeday'],
            ));
          }
        } 
      });
    });
  }

  getAllCustomExercise() async {
    await getAllTimeDay();
    listCustomExercise.clear();
    httpClient.getAllCustomExercise(idUser).then((customExercise) {
      setState(() {
        if (customExercise != null) {
          for (int i = 0; i < customExercise.length; i++) {
            listCustomExercise.add(new CustomExerciseEntries(
              idcustomexercise: customExercise[i]['customexerciseid'].toString(),
              customExerciseName: customExercise[i]['customexercisename'],
              customCalories: customExercise[i]['customexercisecalories'].toString(),
              customMinutes: customExercise[i]['customexerciseminutes'].toString(),
              timedayid: customExercise[i]['timedayid'].toString(),
            ));
          }
        }
        print(listCustomExercise);
      });
    });
  }

  pushListExercise(exercise) {
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
  }

  searchExercise() {
    if (controllerTextExercise.text.isNotEmpty) {
      httpClient.getExerciseByName(controllerTextExercise.text).then((exercise) {
        pushListExercise(exercise);
      });
    } else {
      httpClient.getAllExercise().then((exercise) {
        pushListExercise(exercise);
      });
    }
  }

  showDialogAddCustomExercise(id) {
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
                CustomExerciseEntries customExerciseEntries = new CustomExerciseEntries(
                  customExerciseName: controllerNameExercise.text,
                  customMinutes: controllerMinutesExercise.text,
                  customCalories: controllerCaloriesExercise.text,
                  iduser: idUser.toString(),
                  timedayid: id,
                );
                httpClient.newCustomExercise(customExerciseEntries).then((val) {
                  getAllCustomExercise();
                  Navigator.of(context).pop();
                });
              }
            },
          ),
        ]
      )
    );
  }

  showDialogAddTimeDay() {
    showDialog(
      context: context,
      child: new AlertDialog(
        title: new Text('New time day'),
        content: new Container(
          child: new TextField(
            controller: controllerNameTimeDay,
            decoration: new InputDecoration(
              hintText: 'Enter name time of day',
              labelText: 'Name',
            ),
          )
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
              httpClient.newTimeDay(controllerNameTimeDay.text).then((val) {
                getAllCustomExercise();
                Navigator.of(context).pop();
              });
            },
          )
        ],
      )
    );
  }

  Iterable<Widget> listTitlesCustomExercise;

  @override
  Widget build(BuildContext context) {

    Iterable<Widget> listTitlesExercise = listExercise.map((ExerciseEntries item) => buildListTileExercise(context, item));
    Iterable<Widget> listTitlesTimeDay = listTimeDay.map((TimeDay item) => buildListTileTimeDay(context, item));
    listTitlesCustomExercise = listCustomExercise.map((CustomExerciseEntries item) => buildListTileCustomExercise(context, item));

    var listTitleExercise = new Expanded(
      child: new ListView(
        padding: new EdgeInsets.symmetric(vertical: 4.0),
        children: listTitlesExercise.toList(),
      )
    );
    
    var listTitleTimeDay = new Expanded(
      child: new ListView(
        padding: new EdgeInsets.symmetric(vertical: 4.0),
        children: listTitlesTimeDay.toList(),
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
                  listTitleTimeDay                  
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
          showDialogAddTimeDay();
        },
      ),
    );
  }
}