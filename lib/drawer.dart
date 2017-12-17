import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: new Column(
        children: <Widget>[
          new Container(
            child: new Icon(
              Icons.account_box,
              color: Colors.blue,
              size: 90.0,
            ),
            // color: Colors.blue,
            height: 190.0,
          ),
          new Expanded(
            child: new ListView(
              children: <Widget>[
                new Divider(color: Colors.black),
                new GestureDetector(
                  child: new Container(
                    // color: Colors.orange,
                    child: new Padding(
                      child: new Text("Home"),
                      padding: new EdgeInsets.only(bottom: 25.0, left: 8.0, right: 8.0, top: 25.0),
                    ),
                    width: MediaQuery.of(context).size.width,
                  ),
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                ),
                new Divider(color: Colors.black,),
                new GestureDetector(
                  child: new Container(
                    // color: Colors.orange,
                    child: new Padding(
                      child: new Text("Profile"),
                      padding: new EdgeInsets.only(bottom: 25.0, left: 8.0, right: 8.0, top: 25.0),
                    ),
                    width: MediaQuery.of(context).size.width,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/profile");
                  },
                ),
                new Divider(color: Colors.black,),
                new GestureDetector(
                  child: new Container(
                    // color: Colors.orange,
                    child: new Padding(
                      child: new Text("Statisctics"),
                      padding: new EdgeInsets.only(bottom: 25.0, left: 8.0, right: 8.0, top: 25.0),
                    ),
                    width: MediaQuery.of(context).size.width,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/statistics");
                  },
                ),
                new Divider(color: Colors.black,),
                new GestureDetector(
                  child: new Container(
                    // color: Colors.orange,
                    child: new Padding(
                      child: new Text("Exercise"),
                      padding: new EdgeInsets.only(bottom: 25.0, left: 8.0, right: 8.0, top: 25.0),
                    ),
                    width: MediaQuery.of(context).size.width,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/exercise");
                  },
                ),
                new Divider(color: Colors.black,),
              ],
            )
          )
        ]
      )
    );
  }
}