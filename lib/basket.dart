import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'httpclient.dart';
import 'sqldb.dart';
import 'package:intl/intl.dart';

class Food {
  Food({this.nameFood, this.calories});
  final String nameFood;
  final int calories;
}

List<Food> listFood = <Food>[];
List<String> listSelected = <String>[];

class Basket extends StatefulWidget {  

  @override
  State<StatefulWidget> createState() => new _Basket();
}

class _Basket extends State<Basket> {

  DBProvider dbProvider = new DBProvider();
  HttpClient httpClient = new HttpClient();
  int sumColories = 0;
  bool isLoaded = true;
  String login;

  @override
  void initState() {
    super.initState();
    dbProvider.create();    
    listFood.clear();
    getValues();
    setState(() {
      isLoaded = false;
    });
  }

  getListFoods() async {
    if (listSelected.length != 0 && listFood.length == 0) {
      for (int i = 0; i < listSelected.length; i++) {
        print(listSelected[i]);
        await httpClient.getFoodId(listSelected[i]).then((res) {
          listFood.add(new Food(
              nameFood: res['food_name'],
              calories: int.parse(res['servings']['serving'][0]['calories']),
            )
          );
          sumColories += int.parse(res['servings']['serving'][0]['calories']);
          updateList(context);
        });
      }
      await warningMessage();
    }
  }

  saveCalories() {
    httpClient.getUserByLogin(login).then((user) {
      if (sumColories > user[0]['caloriesnorm']) {
        var remainder = (sumColories - user[0]['caloriesnorm']) + user[0]['caloriesnorm'];
        saveValues(remainder);
      }
      var dateFormat = new DateFormat('yyyy-MM-dd');
      var date = dateFormat.format(new DateTime.now());
      httpClient.getStatisticsByDate(date).then((statByDate) {
        if (statByDate.isEmpty) {
          Statistics statistics = new Statistics(
            datetime: date,
            iduser: user[0]['userid']
          );
          print(statistics.datetime);
          httpClient.newStatistics(statistics).then((value) {
            Calories calories = new Calories(
              caloriescount: sumColories,
              idstatistics: value[0]['statisticsid']
            );
            httpClient.newCalories(calories).then((val) {
              Navigator.of(context).pushReplacementNamed('/statistics');
            });
          });
        } else {
          Calories calories = new Calories(
            caloriescount: sumColories,
            idstatistics: statByDate[0]['statisticsid'],
          );
          httpClient.newCalories(calories).then((val) {
            showDialog(
              context: context,
              child: new AlertDialog(
                title: new Text('Which page do you want to go to'),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text('Statistics'),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/statistics');
                    },
                  ),
                  new FlatButton(
                    child: new Text('Exercise'),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/exercise');                      
                    },
                  )
                ],
              )
            );
          });
        }
      });
    });
  }

  saveValues(remainder) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(remainder);
    prefs.setInt('remainder', remainder);
  }

  getValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    login = prefs.getString('login');
    listSelected = prefs.getStringList('selectedFoods');
    getListFoods();
  }

  Widget buildListTile(BuildContext context, Food item) {
    return new MergeSemantics(
      child: new Container(
        child: new ListTile(
          title: new Text(item.nameFood),
          subtitle: new Text(item.calories.toString()),
        ),
      )
    );
  }

  Iterable<Widget> listTiles;

  updateList(BuildContext context) {
    setState(() {
      listTiles = listFood.map((Food item) => buildListTile(context, item));
    });
  }

  warningMessage() {
    httpClient.getUserByLogin(login).then((user) async {
      setState(() {
        isLoaded = true;
      });
      if (sumColories > user[0]['caloriesnorm']) {
        await showDialog(
          context: context,
          child: new AlertDialog(
            content: new Text('You have exceeded the norm for calories. Do you want to continue?'),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Back'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/home');
                },
              ),
              new FlatButton(
                child: new Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          )
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    
    listTiles = listFood.map((Food item) => buildListTile(context, item));

    // updateList(context);

    var listTitle = new Expanded(
      child: new ListView(
        padding: new EdgeInsets.symmetric(vertical: 4.0),
        children: listTiles.toList(),
      )
    );

    var listViewProgress = new Container(
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

    var listView = new Container(
      child: new ListView.builder(
        itemCount: listFood == null ? 0 : listFood.length,
        padding: const EdgeInsets.all(10.0), 
        itemBuilder: (BuildContext context, int index) {
          return new SizedBox(
            height: 100.0,
            child: new Card(
              child: new Center(
                child: new Column(
                  children: <Widget>[
                    new Container(
                      child: new Container(
                        margin: const EdgeInsets.only(top: 20.0),
                        child: new Column(children: <Widget>[
                          new Text(listFood[index].nameFood),
                          new Text(listFood[index].calories.toString()),
                        ],) 
                      )
                    ),
                  ],
                )
              )
            ) 
          );
        },
      )
    );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Basket'),
      ),
      body: new Container(
        child: isLoaded ? new Column(
          children: <Widget>[
            isLoaded ? listTitle : listViewProgress,
            new Row(
              children: <Widget>[
                new Container(
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width / 2,
                  child: new Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 5.0, left: 10.0, right: 10.0),
                    child: new Text('Sum calories:'),
                  ),
                ),
                new Container(
                  alignment: Alignment.centerRight,
                  width: MediaQuery.of(context).size.width / 2,
                  child: new Padding(
                    padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
                    child: new Text(sumColories.toString()),
                  ),
                ),
              ],
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              child: new Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom: 10.0, left: 10.0, right: 10.0),
                child: new RaisedButton(
                  color: Colors.green[400],
                  child: new Text(
                    'Save',
                    style: new TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    saveCalories();
                  },
                ),
              ),
            ),
            // new Container(
            //   width: MediaQuery.of(context).size.width,
            //   child: new Padding(
            //     padding: const EdgeInsets.only(top: 5.0, bottom: 10.0, left: 10.0, right: 10.0),
            //     child: new RaisedButton(
            //       color: Colors.green[400],
            //       child: new Text(
            //         'Calculate',
            //         style: new TextStyle(color: Colors.white),
            //       ),
            //       onPressed: () {},
            //     ),
            //   )
            // )
          ]
        ) : listViewProgress
      )
    );
  }
}