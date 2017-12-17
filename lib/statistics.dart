import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'sqldb.dart';
import 'package:flutter_charts/flutter_charts.dart';
import 'drawer.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'httpclient.dart';

class Statisctics extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new _Statisctics();
}

class _Statisctics extends State<Statisctics> with SingleTickerProviderStateMixin {

  DBProvider dbProvider = new DBProvider();
  HttpClient httpClient = new HttpClient();

  LineChartOptions _lineCaloriesChartOptions;
  LineChartOptions _lineWeightChartOptions;
  ChartOptions _verticalBarChartOptions;

  ChartData _chartDataLineCalories;
  ChartData _chartDataLineWeight;
  ChartData _chartDataVertical;

  TabController controller;

  DateTime fromDate = new DateTime.now();
  DateTime toDate = new DateTime.now();
  int numberMonth = new DateTime.now().month;
  String authToken = '';
  String authSecret = '';

  bool isLoadedCalorLine = false;
  bool isLoadedWeightLine = false;
  bool isLoadedVertical = false;

  @override
  void initState() {
    super.initState();
    controller = new TabController(length: 3, vsync: this);
    dbProvider.create().then((onValue) {
      setState(() {
        verticalData();
      });
    });
    getSharedPreferences();
  }

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');
    authSecret = prefs.getString('auth_secret');
  }

  List<double> listCalorVertical = <double>[];
  List<List<double>> listRowsCalorVertical = <List<double>>[];
  List<String> listXLabelsCalorVertical = <String>[];
  List<String> listYLabelsCalorVertical = <String>[];

  addRowsVertical() async {
    DateTime date = new DateTime.now();
    var dateFormat = new DateFormat('yyyy-MM-dd');
    String dateToday = dateFormat.format(date);
    var val;
    listRowsCalorVertical.clear();
    listCalorVertical.clear();
    await dbProvider.getStatisticsByDate(dateToday).then((stat) {
      val = stat;
    });
    await dbProvider.getCaloriesByIdStatistics(val[0]['idstatistics']).then((calor) {
      for (int j = 0; j < calor.length; j++) {
        listCalorVertical.add(double.parse(calor[j]['caloriescount'].toString()));
      }
    });
  }

  verticalData() async {
    _verticalBarChartOptions = new VerticalBarChartOptions();
    _chartDataVertical = new ChartData();

    await addRowsVertical();

    print(listRowsCalorVertical);

    listYLabelsCalorVertical.clear();

    for (int i = 0; i < listCalorVertical.length; i++) {
      var asd = <double>[];
      asd.add(listCalorVertical[i]);
      listRowsCalorVertical.add(asd);
      listYLabelsCalorVertical.add(listCalorVertical[i].toString());
    }

    print(listYLabelsCalorVertical);

    _chartDataVertical.dataRowsLegends = listYLabelsCalorVertical;

    _chartDataVertical.dataRows = listRowsCalorVertical;

    _chartDataVertical.xLabels =  [new DateFormat('yyyy-MM-dd').format(new DateTime.now())];
    _chartDataVertical.assignDataRowsDefaultColors();
    setState(() {
      isLoadedVertical = true;
    });
  }

  List<double> listCalorLine = <double>[];
  List<List<double>> listRowsCalorLine = <List<double>>[];
  List<String> listXLabelsCalorLine = <String>[];
  List<String> listYLabelsCalorLine = <String>[];

  addRowsCalorLine() async {
    listCalorLine.clear();
    listXLabelsCalorLine.clear();
    double sumCalor = 0.0;
    var dateFormat = new DateFormat('yyyy-MM-dd');
    String dateF = dateFormat.format(fromDate);
    String dateT = dateFormat.format(toDate);
    var val;
    await dbProvider.getStatisticsByCustomDate(dateF, dateT).then((stat) {
      val = stat;
    });
    for (int i = 0; i < val.length; i++) {
      sumCalor = 0.0;
      await dbProvider.getCaloriesByIdStatistics(val[i]['idstatistics']).then((calor) {
        for (int j = 0; j < calor.length; j++) {
          sumCalor += double.parse(calor[j]['caloriescount'].toString());
        }
        print(sumCalor);
        listCalorLine.add(sumCalor);
        String value = val[i]['datetime'];
        String dateTime = value.substring(value.lastIndexOf('-') + 1, value.length);
        listXLabelsCalorLine.add(dateTime);
      });
    }
  }

  lineCaloriesData() async {
    _lineCaloriesChartOptions = new LineChartOptions();
    _chartDataLineCalories = new ChartData();

    _chartDataLineCalories.dataRowsLegends = ["Calories"];

    await addRowsCalorLine();

    listRowsCalorLine.add(listCalorLine);    

    _chartDataLineCalories.dataRows = listRowsCalorLine;
    _chartDataLineCalories.xLabels = listXLabelsCalorLine;

    _lineCaloriesChartOptions.useUserProvidedYLabels = true;

    double min = _chartDataLineCalories.minData();
    double max = _chartDataLineCalories.maxData();
    double medium = (max + min) / 2;
    
    listYLabelsCalorLine.clear();
    listYLabelsCalorLine.add(min.toString());
    listYLabelsCalorLine.add(medium.toString());
    listYLabelsCalorLine.add(max.toString());

    _chartDataLineCalories.yLabels = listYLabelsCalorLine;

    _chartDataLineCalories.assignDataRowsDefaultColors();
    setState(() {
      isLoadedCalorLine = true;
    });
  }

  List<double> listWidthLine = <double>[];
  List<List<double>> listRowsWidthLine = <List<double>>[];
  List<String> listXLabelsWidthLine = <String>[];
  List<String> listYLabelsWidthLine = <String>[];

  lineWeightData() async {
    listWidthLine.clear();
    listXLabelsWidthLine.clear();
    var date1 = new DateTime(1970, 1, 1);
    var date2 = new DateTime(new DateTime.now().year, numberMonth, new DateTime.now().day);
    var dur = date2.difference(date1);
    print('date: ' + dur.inDays.toString());
    await httpClient.getWidthMonth(authToken, authSecret, dur.inDays).then((widthMonth) {
      print(widthMonth);
      var listWidth = widthMonth['month']['day'];
      print(listWidth);      
      for (int i = 0; i < listWidth.length; i++) {
        var oldDate = new DateTime(1970, 1, 1);
        String newDate;
        newDate = new DateFormat('yyyy-MM-dd').format(oldDate.add(new Duration(days: int.parse(listWidth[i]['date_int']))));
        String strNewDate = newDate.substring(newDate.lastIndexOf('-') + 1, newDate.length);
        listWidthLine.add(double.parse(listWidth[i]['weight_kg']));
        listXLabelsWidthLine.add(strNewDate);
      }
      print(listWidthLine);
    });

    var asd = date1.add(new Duration(days: 17504));
    print(asd);

    _lineWeightChartOptions = new LineChartOptions();
    _chartDataLineWeight = new ChartData();

    _chartDataLineWeight.dataRowsLegends = ["Width"];

    // await addRowsWidthLine();

    listRowsWidthLine.clear();

    listRowsWidthLine.add(listWidthLine);    

    _chartDataLineWeight.dataRows = listRowsWidthLine;
    _chartDataLineWeight.xLabels = listXLabelsWidthLine;

    _lineWeightChartOptions.useUserProvidedYLabels = true;

    double min = _chartDataLineWeight.minData();
    double max = _chartDataLineWeight.maxData();
    double result = (max + min) / 2;
    double medium = double.parse(new NumberFormat("##.##").format(result));

    listYLabelsWidthLine.clear();
    listYLabelsWidthLine.add(min.toString());
    listYLabelsWidthLine.add(medium.toString());
    listYLabelsWidthLine.add(max.toString());

    _chartDataLineWeight.yLabels = listYLabelsWidthLine;

    _chartDataLineWeight.assignDataRowsDefaultColors();

    setState(() {
      isLoadedWeightLine = true;
    });
  }

  @override
  Widget build(BuildContext context) {

    var defaultPage = new Container();

    VerticalBarChart vertical = new VerticalBarChart(
      painter: new VerticalBarChartPainter(),
      layouter: new VerticalBarChartLayouter(
        chartData: _chartDataVertical,
        chartOptions: _verticalBarChartOptions              
      ),
    );

    LineChart linerCalories = new LineChart(
      painter: new LineChartPainter(),
      layouter: new LineChartLayouter(
        chartData: _chartDataLineCalories,
        chartOptions: _lineCaloriesChartOptions
      ),
    );

    LineChart linerWeight = new LineChart(
      painter: new LineChartPainter(),
      layouter: new LineChartLayouter(
        chartData: _chartDataLineWeight,
        chartOptions: _lineWeightChartOptions              
      ),
    );

    TextField dateFrom = new TextField(
      decoration: new InputDecoration(
        hintText: 'Date from',
      ),
      onSubmitted: (value) {
        print(value);
        showDatePicker(
          initialDate: new DateTime.now(), 
          firstDate: null,
          lastDate: null, 
          context: context
        );
      },
    );

    Future _selectFromDateCalories() async {
      DateTime picked = await showDatePicker(
        context: context,
        initialDate: fromDate,
        firstDate: new DateTime(1900),
        lastDate: new DateTime(2100),
      );
      if (picked != null) {
        setState(() {
          fromDate = picked;
        });
      }
    }

    Future _selectToDateCalories() async {
      DateTime picked = await showDatePicker(
        context: context,
        initialDate: toDate,
        firstDate: new DateTime(1900),
        lastDate: new DateTime(2100),
      );
      if (picked != null) {
        setState(() {
          toDate = picked;
        });
      }
    }

    return new Scaffold(
      drawer: new MyDrawer(),
      appBar: new AppBar(
        title: new Text("Chart"),
        bottom: new TabBar(
          tabs: <Tab>[
            new Tab(
              text: "Calories",
            ),
            new Tab(
              text: "Today",
            ),
            new Tab(
              text: "Weight",
            ),
          ],
          controller: controller,
        ),
      ),
      body: new TabBarView(
        children: <Widget>[
          new Container(
            child: new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Row(
                    children: <Widget>[
                      new Container(
                        margin: const EdgeInsets.only(left: 10.0, right: 5.0),
                        width: MediaQuery.of(context).size.width / 2 - 20.0,
                        child: new InkWell(
                          onTap: () {
                            _selectFromDateCalories();
                          },
                          child: new InputDecorator(
                            decoration: new InputDecoration(
                              labelText: "From",
                            ),
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                new Text(new DateFormat.yMMMd().format(fromDate)),
                                new Icon(Icons.arrow_drop_down,
                                  color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade700 : Colors.white70
                                ),
                              ],
                            ),
                          ),
                        )
                      ),
                      new Container(
                        margin: const EdgeInsets.only(left: 5.0, right: 10.0),
                        width: MediaQuery.of(context).size.width / 2 - 10.0,
                        // child: new TextField(decoration: new InputDecoration(hintText: 'Date to',),),
                        child: new InkWell(
                          onTap: () {
                            _selectToDateCalories();
                          },
                          child: new InputDecorator(
                            decoration: new InputDecoration(
                              labelText: "To",
                            ),
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                new Text(new DateFormat.yMMMd().format(toDate)),
                                new Icon(Icons.arrow_drop_down,
                                  color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade700 : Colors.white70
                                ),
                              ],
                            ),
                          ),
                        )
                      )
                    ],
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
                    child: new Container(
                      width: MediaQuery.of(context).size.width,
                      child: new RaisedButton(
                        child: new Text('Show'),
                        color: Colors.teal,
                        onPressed: () {
                          var fd = new DateFormat('yyyy-MM-dd').format(fromDate);
                          var td = new DateFormat('yyyy-MM-dd').format(toDate);
                          if (fd != td) {
                            setState(() {
                              lineCaloriesData();
                            });
                          }
                        },
                      )
                    ),
                  ),
                  new Expanded(
                    child: new Container(
                      width: MediaQuery.of(context).size.width,
                      child: isLoadedCalorLine ? linerCalories : defaultPage,
                    )
                  ),
                ],
              ),
            ),
          ),
          new Container(
            child: new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Expanded(
                    child: new Container(
                      width: MediaQuery.of(context).size.width,
                      child: isLoadedVertical ? vertical : defaultPage,
                    )
                  ),
                ],
              ),
            ),
          ),
          new Container(
            child: new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
                    child: new Container(
                      width: MediaQuery.of(context).size.width,
                      child: new RaisedButton(
                        child: new Text('Show'),
                        color: Colors.teal,
                        onPressed: () {
                            showDialog(
                              context: context,
                              child: new AlertDialog(
                                title: new Text('Pick month'),
                                content: new Container(
                                  height: MediaQuery.of(context).size.height / 4,
                                  child: new Center(
                                    child: new NumberPicker.integer(
                                      initialValue: numberMonth,
                                      minValue: 1,
                                      maxValue: 12,
                                      onChanged: (val) {
                                        setState(() {
                                          if (val == 13) {
                                            val = 12;
                                          }
                                          numberMonth = val;
                                          print(numberMonth);
                                        });
                                      }
                                    ),
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
                                      lineWeightData();
                                    },
                                  ),
                                ],
                              )
                            );
                        },
                      )
                    ),
                  ),
                  new Expanded(
                    child: new Container(
                      width: MediaQuery.of(context).size.width,
                      child: isLoadedWeightLine ? linerWeight : defaultPage,
                    )
                  ),
                ],
              ),
            ),
          ),
        ],
        controller: controller,
      )
    );
  }
}