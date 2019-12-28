import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: colorCustom,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// To assign primarySwatch a custom color
Map<int, Color> color = {
  50: Color.fromRGBO(136, 14, 79, .1),
  100: Color.fromRGBO(136, 14, 79, .2),
  200: Color.fromRGBO(136, 14, 79, .3),
  300: Color.fromRGBO(136, 14, 79, .4),
  400: Color.fromRGBO(136, 14, 79, .5),
  500: Color.fromRGBO(136, 14, 79, .6),
  600: Color.fromRGBO(136, 14, 79, .7),
  700: Color.fromRGBO(136, 14, 79, .8),
  800: Color.fromRGBO(136, 14, 79, .9),
  900: Color.fromRGBO(136, 14, 79, 1),
};

MaterialColor colorCustom = MaterialColor(0xFF0957FF, color);

class SalesData {
  SalesData(this.year, this.sales);
  final String year;
  final double sales;
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onLoad(BuildContext context) {
    print("test");
  } //callback when layout build done

  String dropdownValue = 'One';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("FFD")),
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 170,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    color: Colors.green,
                    elevation: 10,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const ListTile(
                          leading: Icon(Icons.album, size: 70),
                          title: Text('Actual',
                              style: TextStyle(color: Colors.white)),
                          subtitle: Text('TWICE',
                              style: TextStyle(color: Colors.white)),
                        ),
                        ButtonTheme.bar(
                          child: ButtonBar(
                            children: <Widget>[
                              FlatButton(
                                child: const Text('Edit',
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () {},
                              ),
                              FlatButton(
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 170,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    color: Colors.red,
                    elevation: 10,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const ListTile(
                          leading: Icon(Icons.album, size: 70),
                          title: Text('Budget',
                              style: TextStyle(color: Colors.white)),
                          subtitle: Text('TWICE',
                              style: TextStyle(color: Colors.white)),
                        ),
                        ButtonTheme.bar(
                          child: ButtonBar(
                            children: <Widget>[
                              FlatButton(
                                child: const Text('Edit',
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () {},
                              ),
                              FlatButton(
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Actual',
                  style: TextStyle(fontSize: 30),
                ),
                Container(
                  constraints: BoxConstraints.expand(
                    height: 100,
                  ),

                  padding: const EdgeInsets.only(
                      left: 30.0, top: 0, right: 30, bottom: 0),
                  //color: Colors.blue[600],
                  alignment: Alignment.center,
                  //child: Text('Submit'),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Enter your amoaunt',
                      suffixIcon: Icon(Icons.attach_money),
                      labelStyle: TextStyle(color: Color(0xff0957FF)),
                      enabledBorder: new UnderlineInputBorder(
                          borderSide: new BorderSide(color: Color(0xff0957FF))

                      ),
                    )
                    ,
                  ),
                ),
                Container(
                  constraints: BoxConstraints.expand(
                    height: 100,
                  ),

                  padding: const EdgeInsets.only(
                      left: 30.0, top: 0, right: 30, bottom: 0),
                  //color: Colors.blue[600],
                  alignment: Alignment.center,
                  //child: Text('Submit'),
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Color(0xff0957FF)),
                    isExpanded: true,
                    underline: Container(
                      height: 2,
                      width: 5000,
                      color: Color(0xff0957FF),
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // return object of type Dialog
                          return AlertDialog(
                            title: new Text("Alert Dialog title"),
                            content:
                                new Text("Alert Dialog body: $dropdownValue"),
                            actions: <Widget>[
                              // usually buttons at the bottom of the dialog
                              new FlatButton(
                                child: new Text("Close"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    items: <String>['One', 'Two', 'Free', 'Four']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  constraints: BoxConstraints.expand(
                    height: 50,
                  ),
                  padding: const EdgeInsets.only(
                      left: 30.0, top: 0, right: 30, bottom: 0),
                  //color: Colors.blue[600],
                  alignment: Alignment.center,
                  //child: Text('Submit'),
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Color(0xff0957FF)),
                    isExpanded: true,
                    underline: Container(
                      height: 2,
                      width: 5000,
                      color: Color(0xff0957FF),
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // return object of type Dialog
                          return AlertDialog(
                            title: new Text("Alert Dialog title"),
                            content:
                                new Text("Alert Dialog body: $dropdownValue"),
                            actions: <Widget>[
                              // usually buttons at the bottom of the dialog
                              new FlatButton(
                                child: new Text("Close"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    items: <String>['One', 'Two', 'Free', 'Four']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  constraints: BoxConstraints.expand(
                    height: 100.0,
                  ),
                  padding: const EdgeInsets.all(30.0),
                  alignment: Alignment.center,
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Color(0xff0957FF)),
                    isExpanded: true,
                    underline: Container(
                      height: 2,
                      width: 5000,
                      color: Color(0xff0957FF),
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // return object of type Dialog
                          return AlertDialog(
                            title: new Text("Alert Dialog title"),
                            content:
                                new Text("Alert Dialog body: $dropdownValue"),
                            actions: <Widget>[
                              // usually buttons at the bottom of the dialog
                              new FlatButton(
                                child: new Text("Close"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    items: <String>['One', 'Two', 'Free', 'Four']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  constraints: BoxConstraints.expand(
                    height: 100.0,
                  ),
                  padding: const EdgeInsets.only(
                      left: 30.0, top: 0, right: 30, bottom: 0),
                  //color: Colors.blue[600],
                  alignment: Alignment.center,
                  //child: Text('Submit'),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: DropdownButton<String>(
                      value: dropdownValue,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Color(0xff0957FF)),
                      //isExpanded: true,
                      underline: Container(
                        height: 2,
                        width: 2000,
                        color: Color(0xff0957FF),
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          dropdownValue = newValue;
                        });
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // return object of type Dialog
                            return AlertDialog(
                              title: new Text("Alert Dialog title"),
                              content:
                                  new Text("Alert Dialog body: $dropdownValue"),
                              actions: <Widget>[
                                // usually buttons at the bottom of the dialog
                                new FlatButton(
                                  child: new Text("Close"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      items: <String>['One', 'Two', 'Free', 'Four']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                ButtonBar(
                  mainAxisSize: MainAxisSize
                      .min, // this will take space as minimum as posible(to center)
                  children: <Widget>[
                    ButtonTheme(
                      minWidth: 75.0,
                      height: 40.0,
                      child: RaisedButton(
                        child: Text('Discard'),
                        color: Color(0xffEEEEEE), // EEEEEE
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // return object of type Dialog
                              return AlertDialog(
                                title: new Text("Alert Dialog title"),
                                content: new Text(
                                    "Alert Dialog body: $dropdownValue"),
                                actions: <Widget>[
                                  // usually buttons at the bottom of the dialog
                                  new FlatButton(
                                    child: new Text("Close"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                    ButtonTheme(
                      minWidth: 150.0,
                      height: 60.0,
                      child: RaisedButton(
                        child: Text('Save', style: TextStyle(color: Colors.white, fontSize: 17)),
                        color: Color(0xff0957FF), //df7599 - 0957FF
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // return object of type Dialog
                              return AlertDialog(
                                title: new Text("Alert Dialog title"),
                                content: new Text(
                                    "Alert Dialog body: $dropdownValue"),
                                actions: <Widget>[
                                  // usually buttons at the bottom of the dialog
                                  new FlatButton(
                                    child: new Text("Close"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Budget',
                  style: TextStyle(fontSize: 30),
                ),
                Container(
                  constraints: BoxConstraints.expand(
                    height: 100,
                  ),

                  padding: const EdgeInsets.all(30.0),
                  //color: Colors.blue[600],
                  alignment: Alignment.center,
                  //child: Text('Submit'),
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.deepPurple),
                    isExpanded: true,
                    underline: Container(
                      height: 2,
                      width: 5000,
                      color: Color(0xff0957FF),
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // return object of type Dialog
                          return AlertDialog(
                            title: new Text("Alert Dialog title"),
                            content:
                                new Text("Alert Dialog body: $dropdownValue"),
                            actions: <Widget>[
                              // usually buttons at the bottom of the dialog
                              new FlatButton(
                                child: new Text("Close"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    items: <String>['One', 'Two', 'Free', 'Four']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  constraints: BoxConstraints.expand(
                    height: 100,
                  ),

                  padding: const EdgeInsets.all(30.0),
                  //color: Colors.blue[600],
                  alignment: Alignment.center,
                  //child: Text('Submit'),
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Color(0xff0957FF)),
                    isExpanded: true,
                    underline: Container(
                      height: 2,
                      width: 5000,
                      color: Color(0xff0957FF),
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // return object of type Dialog
                          return AlertDialog(
                            title: new Text("Alert Dialog title"),
                            content:
                                new Text("Alert Dialog body: $dropdownValue"),
                            actions: <Widget>[
                              // usually buttons at the bottom of the dialog
                              new FlatButton(
                                child: new Text("Close"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    items: <String>['One', 'Two', 'Free', 'Four']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  constraints: BoxConstraints.expand(
                    height: 100.0,
                  ),

                  padding: const EdgeInsets.all(30.0),
                  //color: Colors.blue[600],
                  alignment: Alignment.center,
                  //child: Text('Submit'),
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Color(0xff0957FF)),
                    isExpanded: true,
                    underline: Container(
                      height: 2,
                      width: 5000,
                      color: Color(0xff0957FF),
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // return object of type Dialog
                          return AlertDialog(
                            title: new Text("Alert Dialog title"),
                            content:
                                new Text("Alert Dialog body: $dropdownValue"),
                            actions: <Widget>[
                              // usually buttons at the bottom of the dialog
                              new FlatButton(
                                child: new Text("Close"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    items: <String>['One', 'Two', 'Free', 'Four']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Visualizer',
                  style: TextStyle(fontSize: 30),
                ),
                Container(
                    child: SfCartesianChart(
                        primaryXAxis:
                            CategoryAxis(), // Initialize category axis.
                        series: <LineSeries<SalesData, String>>[
                      // Initialize line series.
                      LineSeries<SalesData, String>(
                          dataSource: [
                            SalesData('Jan', 35),
                            SalesData('Feb', 28),
                            SalesData('Mar', 34),
                            SalesData('Apr', 32),
                            SalesData('May', 40)
                          ],
                          xValueMapper: (SalesData sales, _) => sales.year,
                          yValueMapper: (SalesData sales, _) => sales.sales)
                    ])),
              ],
            ),
            DefaultTabController(
              length: 3,
              child: Column(
                children: <Widget>[
                  Container(
                    constraints: BoxConstraints.expand(height: 50),
                    child: TabBar(tabs: [
                      Tab(
                        child: Container(
                          alignment: Alignment.center,
                          //constraints: BoxConstraints.expand(width: 200),
                          width: 2000,
                          color: Colors.grey,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.home),
                                Text("General")
                              ]),
                        ),
                      ),
                      Tab(
                        child: Container(
                          alignment: Alignment.center,
                          constraints: BoxConstraints.expand(),
                          color: Colors.grey,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.home),
                                Text(
                                  "Accounts",
                                  style: TextStyle(color: Colors.black),
                                )
                              ]),
                        ),
                      ),
                      Tab(
                        child: Container(
                          alignment: Alignment.center,
                          constraints: BoxConstraints.expand(),
                          color: Colors.grey,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.home),
                                Text("Costtypes")
                              ]),
                        ),
                      ),
                    ]),
                  ),
                  Expanded(
                    child: Container(
                      child: TabBarView(children: [
                        Container(
                          child: Text("General Body"),
                        ),
                        Container(
                          child: Text("Accounts Body"),
                        ),
                        Container(
                          child: Text("Costtypes Body"),
                        ),
                      ]),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
              title: Text('Home'),
              icon: Icon(Icons.home),
              activeColor: Color(0xff0957FF)),
          BottomNavyBarItem(
              title: Text('Actuals'),
              icon: Icon(Icons.attach_money),
              activeColor: Colors.orange),
          BottomNavyBarItem(
            title: Text('Budget'),
            icon: Icon(Icons.account_balance_wallet),
            activeColor: Colors.deepPurple,
          ),
          BottomNavyBarItem(
            title: Text('Visualizer'),
            icon: Icon(Icons.bubble_chart),
            activeColor: Colors.red,
          ),
          BottomNavyBarItem(
            title: Text('Settings'),
            icon: Icon(Icons.settings),
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }
}
