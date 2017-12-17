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
      setState(() {
        isLoaded = true;
      });
    }
  }

  saveCalories() {
    dbProvider.getUserByLogin(login).then((user) {
      var dateFormat = new DateFormat('yyyy-MM-dd');
      var date = dateFormat.format(new DateTime.now());
      dbProvider.getStatisticsByDate(date).then((statByDate) {
        if (statByDate == null) {
          Statistics statistics = new Statistics(
            datetime: date,
            iduser: user.iduser
          );
          print(statistics.datetime);
          dbProvider.insertStatistics(statistics).then((value) {
            Calories calories = new Calories(
              caloriescount: sumColories,
              idstatistics: value.idstatistics
            );
            dbProvider.insertCalories(calories).then((val) {
              Navigator.of(context).pushReplacementNamed('/statistics');
            });
          });
        } else {
          Calories calories = new Calories(
            caloriescount: sumColories,
            idstatistics: statByDate[0]['idstatistics'],
          );
          dbProvider.insertCalories(calories).then((val) {
            Navigator.of(context).pushReplacementNamed('/statistics');
          });
        }
      });
    });
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
        child: new Column(
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
                  alignment: Alignment.bottomRight,
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
        )
      )
    );
  }
}