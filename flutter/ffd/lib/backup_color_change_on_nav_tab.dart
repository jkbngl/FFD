import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
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

  String dropdownValue = 'One';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nav Bar")),
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('We move under cover and we move as one'),
                Text('Through the night, we have one shot to live another day'),
                Text('We cannot let a stray gunshot give us away'),
                Text('We will fight up close, seize the moment and stay in it'),
                Text('It’s either that or meet the business end of a bayonet'),
                Text('The code word is ‘Rochambeau,’ dig me?'),
                Text('Rochambeau!', style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('We move under cover and we move as one'),
                Text('Through the night, we have one shot to live another day'),
                Text('We cannot let a stray gunshot give us away'),
                Text('We will fight up close, seize the moment and stay in it'),
                Text('It’s either that or meet the business end of a bayonet'),
                Text('The code word is ‘Rochambeau,’ dig me?'),
                Text('Rochambeau!', style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('We move under cover and we move as one'),
                Text('Through the night, we have one shot to live another day'),
                Text('We cannot let a stray gunshot give us away'),
                Text('We will fight up close, seize the moment and stay in it'),
                Text('It’s either that or meet the business end of a bayonet'),
                Text('The code word is ‘Rochambeau,’ dig me?'),
                Text('Rochambeau!', style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('We move under cover and we move as one'),
                Text('Through the night, we have one shot to live another day'),
                Text('We cannot let a stray gunshot give us away'),
                Text('We will fight up close, seize the moment and stay in it'),
                Text('It’s either that or meet the business end of a bayonet'),
                Text('The code word is ‘Rochambeau,’ dig me?'),
                Text('Rochambeau!', style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0)),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
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
                      color: Colors.deepPurpleAccent,
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
                            content: new Text("Alert Dialog body"),
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
                ),Container(
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
                      color: Colors.deepPurpleAccent,
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
                            content: new Text("Alert Dialog body"),
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
                ),Container(
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
                    style: TextStyle(color: Colors.deepPurple),
                    isExpanded: true,
                    underline: Container(
                      height: 2,
                      width: 5000,
                      color: Colors.deepPurpleAccent,
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
                            content: new Text("Alert Dialog body"),
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
              activeColor: Colors.lightBlue),
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
