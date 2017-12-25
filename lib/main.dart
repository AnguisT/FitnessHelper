import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'login.dart';
import 'basket.dart';
import 'drawer.dart';
import 'httpclient.dart';
import 'profile.dart';
import 'statistics.dart';
import 'sqldb.dart' as db;
import 'exercise.dart';

class Food {
  Food({this.idFood, this.title, this.description });
  final int idFood;
  final String title;
  final String description;
  bool checked = false;
}

List<Food> foods = <Food>[];

List<String> selectedFoods = <String>[];

HttpClient httpClient = new HttpClient();

void main() {
  runApp(
    new MaterialApp(
      title: 'Fitnes Helper',
      // home: new Login(),
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder> {
        '/': (BuildContext context) => new Login(),
        '/home': (BuildContext context) => new HomePage(),
        '/basket': (BuildContext context) => new Basket(), 
        '/statistics': (BuildContext context) => new Statisctics(),
        '/profile': (BuildContext context) => new Profile(),
        '/exercise': (BuildContext context) => new Exercise(),
      },
    )
  );
  // runApp(new HttpApi());
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}):super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() => new _HomePage();
}

class _HomePage extends State<HomePage> {

  String login = '';
  String password = '';
  String authToken = '';
  String authSecret = '';
  List data;
  bool isLoaded = true;

  @override
  void initState() {
    super.initState();
    getSharedPreferences();
  }

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    login = prefs.getString('login');
    password = prefs.getString('password');
    authToken = prefs.getString('auth_token');
    authSecret = prefs.getString('auth_secret');
  }

  setListFoods() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('selectedFoods', selectedFoods);
  }

  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      child: new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Exit from application.'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ?? false;
  }

  _searchFood() {
    httpClient.search(controller.text).then((res) {
      setState(() {
        data = res['foods']['food'];
        foods.clear();
        for (var i = 0; i < data.length; i++) {
          foods.add(new Food(
              idFood: int.parse(data[i]['food_id']),
              title: data[i]['food_name'].toString(), 
              description: data[i]['food_description'].toString()
            )
          );
        }
        isLoaded = true;
      });
    });
  }

  TextEditingController controller = new TextEditingController();

  Widget buildListTile(BuildContext context, Food item) {

    var addInBasket = new FlatButton(
      child: new Text('Add in basket'),
      onPressed: () {
        item.checked = !item.checked;
        selectedFoods.add(item.idFood.toString());
        Navigator.of(context).pop();
      },
    );

    var removeInBasket = new FlatButton(
      child: new Text('Remove in basket'),
      onPressed: () {
        item.checked = !item.checked;
        selectedFoods.remove(item.idFood.toString());
        Navigator.of(context).pop();
      },
    );

    return new MergeSemantics(
      child: new Container(
        child: new Column(
          children: <Widget>[
            new ListTile(
              title: new Text(item.title),
              trailing: item.checked ? new Icon(Icons.check_box, color: Colors.blue) : new Icon(Icons.check_box_outline_blank, color: Colors.blue),
              onTap: () {
                showDialog(
                  context: context,
                  child: new AlertDialog(
                    title: new Text(item.title),
                    content: new Text(item.description),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      !item.checked ? addInBasket : removeInBasket
                    ],
                  )
                );
              },
            ),
            new Divider()
          ],
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    Iterable<Widget> listTiles = foods.map((Food item) => buildListTile(context, item));

    var listTitle = new Expanded(
      child: new ListView(
        padding: new EdgeInsets.symmetric(vertical: 4.0),
        children: listTiles.toList(),
      )
    );

    var listView = new Expanded(
      child: new ListView.builder(
        itemCount: foods.length,// data == null ? 0 : data.length,
        padding: const EdgeInsets.all(10.0), 
        itemBuilder: (context, int index) {
          return new Container(
              child: new Container(
                margin: const EdgeInsets.only(left: 20.0),
                child: new Column(children: <Widget>[
                  new Row(
                    children: <Widget>[
                      new Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: new Column(
                          children: <Widget>[
                            new Text(
                              foods[index].title.toString(),
                            ),
                            new Text(
                              foods[index].description.toString(),
                            ),
                          ],
                        ),
                      ),
                      // new Checkbox(
                      //   value: foods[index].checked, 
                      //   onChanged: (bool value) {
                      //     setState(() {
                      //       foods[index].checked = value;
                      //       value ? selectedFoods.add(foods[index].idFood) : selectedFoods.remove(foods[index].idFood);
                      //     });
                      //   },
                      // )  
                    ],
                  ),
                  new Divider(),
                    // new Text(foods[index].description.toString()),
                    // onTap: () {
                    //   setState(() {
                    //     foods[index].checked = true;
                    //     foods[index].checked ? selectedFoods.add(foods[index].idFood) : selectedFoods.remove(foods[index].idFood);
                    //   });
                    // },
                    // new Checkbox(
                    //   value: foods[index].checked, 
                    //   // onChanged: (bool value) {
                    //   //   setState(() {
                    //   //     foods[index].checked = value;
                    //   //     value ? selectedFoods.add(foods[index].idFood) : selectedFoods.remove(foods[index].idFood);
                    //   //   });
                    //   // },
                    // )

                  // )
                ]
              )
            ) 
          );
        },
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

    var iconClear = new IconButton(
      icon: new Icon(Icons.clear),
      onPressed: () {
        setState(() {
          selectedFoods.clear();
          for (int i = 0; i < foods.length; i++ ) {
            foods[i].checked = false;
          }
        });
      },
    );

    var disableIconClear = new IconButton(
      icon: new Icon(Icons.clear), 
      onPressed: null,
    );

    return new Scaffold(
      drawer: new MyDrawer(),
      appBar: new AppBar(
        title: new Text('Home Page'),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          selectedFoods.length != 0 ? iconClear : disableIconClear,
          new Padding(
            padding: const EdgeInsets.only(top: 17.0),
            child: new Text(
              selectedFoods.length != 0 ? selectedFoods.length.toString() : '', 
            ),
          ),
          new IconButton(
            icon: new Icon(Icons.shopping_basket), 
            onPressed: () {
              if (selectedFoods.length > 0) {
                setListFoods();
                Navigator.pushNamed(context, '/basket');
              }
            },
          ),
        ],
      ),
      body: new Container(
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
                        controller: controller,
                        decoration: new InputDecoration(
                          hintText: 'Enter name food',
                        ),
                        onSubmitted: (value) {
                          setState(() {
                            isLoaded = false;                            
                          });
                          _searchFood();
                        },
                      ),
                    ),
                    new IconButton(
                      icon: new Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          isLoaded = false;                            
                        });
                        _searchFood();
                      },
                    )
                  ],
                ),
              ),
              isLoaded ? listTitle : listViewProgress
            ],
          )
        )
      ),
    );
  }
}