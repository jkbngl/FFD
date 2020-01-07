import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:after_layout/after_layout.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FFD Demo',
      theme: ThemeData(
        primarySwatch: colorCustom,
      ),
      home: MyHomePage(title: 'FFD Home Page'),
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

class Account {
  const Account(this.id, this.name, this.parentAccount);

  final int id;
  final String name;
  final int parentAccount;
}

class CostType {
  const CostType(this.id, this.name);

  final int id;
  final String name;
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with AfterLayoutMixin<MyHomePage> {
  int _currentIndex = 0;
  PageController _pageController;

  String level1Actual = 'UNDEFINED';
  String level1Budget = 'UNDEFINED';

  String level2Actual = 'UNDEFINED';
  String level2Budget = 'UNDEFINED';

  String level3Actual = 'UNDEFINED';
  String level3Budget = 'UNDEFINED';

  String costtype = 'UNDEFINED';

  // Are placeholders which are dynamically filled from the DB
  Account level1ActualObject;
  Account level1BudgetObject;
  Account level2ActualObject;
  Account level2BudgetObject;
  Account level3ActualObject;
  Account level3BudgetObject;
  CostType costtypeObject;

  // List has to be filled with 1 default account so that we don't get a null error on startup
  List<Account> level1ActualAccountsList = <Account>[
    const Account(-1, 'UNDEFINED', null)
  ];
  List<Account> level1BudgetAccountsList = <Account>[
    const Account(-1, 'UNDEFINED', null)
  ];
  List<Account> level2ActualAccountsList = <Account>[
    const Account(-1, 'UNDEFINED', null)
  ];
  List<Account> level2BudgetAccountsList = <Account>[
    const Account(-1, 'UNDEFINED', null)
  ];
  List<Account> level3ActualAccountsList = <Account>[
    const Account(-1, 'UNDEFINED', null)
  ];
  List<Account> level3BudgetAccountsList = <Account>[
    const Account(-1, 'UNDEFINED', null)
  ];
  List<CostType> costTypesList = <CostType>[const CostType(-1, 'UNDEFINED')];

  // Are placeholders which are dynamically filled from the DB
  var level1Values = {
    '1': 'UNDEFINED',
  };

  var level2Values = {
    '1': 'UNDEFINED',
  };

  var level3Values = {
    '1': 'UNDEFINED',
  };

  var costtypesValues = {
    '1': 'UNDEFINED',
  };

  final actualTextFieldController = TextEditingController();
  final budgetTextFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Init with a default so that we don't get a null error on startup
    level1ActualObject = level1ActualAccountsList[0];
    level1ActualObject = level1BudgetAccountsList[0];
    level1ActualObject = level2ActualAccountsList[0];
    level1ActualObject = level2BudgetAccountsList[0];
    level1ActualObject = level3ActualAccountsList[0];
    level1ActualObject = level3BudgetAccountsList[0];
    costtypeObject = costTypesList[0];

    print(level1ActualObject.name);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    checkForChanges(true);
  }

  // callback to check if something in the layout needs to be changed
  void checkForChanges(bool onStartup) async {
    print("Checking for changes $onStartup");

    var accountLevel1 =
        await http.read('http://192.168.0.21:5000/api/ffd/accounts/1');
    var accountLevel2 =
        await http.read('http://192.168.0.21:5000/api/ffd/accounts/2');
    var accountLevel3 =
        await http.read('http://192.168.0.21:5000/api/ffd/accounts/3');
    var costTypes =
        await http.read('http://192.168.0.21:5000/api/ffd/costtypes/');

    var parsedAccountLevel1 = json.decode(accountLevel1);
    var parsedAccountLevel2 = json.decode(accountLevel2);
    var parsedAccountLevel3 = json.decode(accountLevel3);
    var parsedCostTypes = json.decode(costTypes);

    level1ActualObject = new Account(
        parsedAccountLevel1[0]['id'],
        parsedAccountLevel1[0]['name'],
        parsedAccountLevel1[0]['parentAccount']);
    level1BudgetObject = new Account(
        parsedAccountLevel1[0]['id'],
        parsedAccountLevel1[0]['name'],
        parsedAccountLevel1[0]['parentAccount']);
    level2ActualObject = new Account(
        parsedAccountLevel2[0]['id'],
        parsedAccountLevel2[0]['name'],
        parsedAccountLevel2[0]['parentAccount']);
    level2BudgetObject = new Account(
        parsedAccountLevel2[0]['id'],
        parsedAccountLevel2[0]['name'],
        parsedAccountLevel2[0]['parentAccount']);
    level3ActualObject = new Account(
        parsedAccountLevel3[0]['id'],
        parsedAccountLevel3[0]['name'],
        parsedAccountLevel3[0]['parentAccount']);
    level3BudgetObject = new Account(
        parsedAccountLevel3[0]['id'],
        parsedAccountLevel3[0]['name'],
        parsedAccountLevel3[0]['parentAccount']);
    costtypeObject =
        new CostType(parsedCostTypes[0]['id'], parsedCostTypes[0]['name']);

    level1Actual = parsedAccountLevel1[0]['name'];
    level1Budget = parsedAccountLevel1[0]['name'];
    level2Actual = parsedAccountLevel2[0]['name'];
    level2Budget = parsedAccountLevel2[0]['name'];
    level3Actual = parsedAccountLevel3[0]['name'];
    level3Budget = parsedAccountLevel3[0]['name'];
    costtype = parsedCostTypes[0]['name'];

    int i = 0;

    for (var account in parsedAccountLevel1) {
      //level1Values.
      level1Values[i.toString()] = account['name'];
      i++;
    }

    i = 0;

    for (var account in parsedAccountLevel2) {
      level2Values[i.toString()] = account['name'];
      i++;
    }

    i = 0;

    for (var account in parsedAccountLevel3) {
      level3Values[i.toString()] = account['name'];
      i++;
    }

    i = 0;

    for (var types in parsedCostTypes) {
      costtypesValues[i.toString()] = types['name'];
      i++;
    }

    /*
    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        content: new Text(
            'All available level1Values - Accounts: $level1Values\n All available level2Values - Accounts: $level2Values\n All available level3Values - Accounts: $level3Values\n'),
        actions: <Widget>[
          new FlatButton(
            child: new Text('DISMISS'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
    */
  }

  void sendBackend(String type) async {
    var url = 'http://192.168.0.21:5000/api/ffd/';

    var params = {
      "doctor_id": "DOC000506",
      "date_range": "25/03/2019-25/03/2019",
      "clinic_id": "LAD000404"
    };

    // Used to determine between actual and budget
    String level1Local;
    String level2Local;
    String level3Local;
    int amount;

    if (type.toLowerCase() == 'actual') {
      level1Local = level1Actual;
      level2Local = level2Actual;
      level3Local = level3Actual;
      amount = int.parse(actualTextFieldController.text);
    } else if (type.toLowerCase() == 'budget') {
      level1Local = level1Budget;
      level2Local = level2Budget;
      level3Local = level3Budget;
      amount = int.parse(budgetTextFieldController.text);
    }

    var body = {
      'amount': amount.toString(),
      'level1': level1Local,
      'level2': level2Local,
      'level3': level3Local,
      'costtype': costtype,
      'status': 'IP',
      'user': "1",
      'type': type,
    };

    var response = await http.post(url, body: body);

    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        content: new Text(
            'sending to server: \n ${response.statusCode} \n ${response.body}'),
        actions: <Widget>[
          new FlatButton(
            child: new Text('DISMISS'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );

    /*var response2 = await http.read('http://192.168.0.21:5000/api/ffd/accounts');

    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        content: new Text('Checking for changes: $response2'),
        actions: <Widget>[
          new FlatButton(
            child: new Text('DISMISS'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("FFD")),
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);

            // Check if something in the settings has been changed, if yes set the vars and widgets accordingly
            checkForChanges(false);
          },
          children: <Widget>[
            CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                      color: Color(0xfff9f9f9),
                      //color: Color(0xffffffff),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * .48,
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
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          onPressed: () {},
                                        ),
                                        FlatButton(
                                          child: const Text('Delete',
                                              style: TextStyle(
                                                  color: Colors.white)),
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
                            width: MediaQuery.of(context).size.width * .48,
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
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          onPressed: () {},
                                        ),
                                        FlatButton(
                                          child: const Text('Delete',
                                              style: TextStyle(
                                                  color: Colors.white)),
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
                      )),
                ),
              ],
            ),
            CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        constraints: BoxConstraints.expand(
                          height: 40,
                        ),

                        padding: const EdgeInsets.only(
                            left: 0.0, top: 10, right: 0, bottom: 0),
                        //color: Colors.blue[600],
                        alignment: Alignment.center,
                        //child: Text('Submit'),
                        child: Text(
                          'Actual',
                          style: TextStyle(fontSize: 30),
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
                        child: TextFormField(
                          keyboardType: TextInputType
                              .number, //keyboard with numbers only will appear to the screen
                          style: TextStyle(
                              height: 2), //increases the height of cursor
                          autofocus: true,
                          controller: actualTextFieldController,
                          decoration: InputDecoration(
                              // hintText: 'Enter ur amount',
                              //hintStyle: TextStyle(height: 1.75),
                              labelText: 'Enter your amount',
                              labelStyle: TextStyle(
                                  height: 0.5,
                                  color: Color(
                                      0xff0957FF)), //increases the height of cursor
                              icon: Icon(
                                Icons.attach_money,
                                color: Color(0xff0957FF),
                              ),
                              //prefixIcon: Icon(Icons.attach_money),
                              //labelStyle: TextStyle(color: Color(0xff0957FF)),
                              enabledBorder: new UnderlineInputBorder(
                                  borderSide: new BorderSide(
                                      color: Color(0xff0957FF)))),
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints.expand(
                          height: 100,
                          //width: MediaQuery.of(context).size.width * .8
                        ),

                        padding: const EdgeInsets.only(
                            left: 30.0, top: 0, right: 30, bottom: 0),
                        //color: Colors.blue[600],
                        alignment: Alignment.center,
                        //child: Text('Submit'),
                        child: DropdownButton<Account>(
                          value: level1ActualObject,
                          hint: Text(
                            "Select a level 1 account",
                            /*style: TextStyle(
                              color,
                            ),*/
                          ),
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
                          onChanged: (Account newValue) {
                            setState(() {
                              level1ActualObject = newValue;
                            });
                          },
                          items:
                              level1ActualAccountsList.map((Account account) {
                            return new DropdownMenuItem<Account>(
                              value: account,
                              child: new Text(
                                account.name,
                                style: new TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      new Text("selected user name is ${level1ActualObject.name} : and Id is : ${level1ActualObject.id}"),
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
                          value: level2Actual,
                          hint: Text(
                            "Select a level 2 account",
                            /*style: TextStyle(
                              color,
                            ),*/
                          ),
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
                              level2Actual = newValue;
                            });
                          },
                          items: level2Values.entries
                              .map<DropdownMenuItem<String>>(
                                  (MapEntry<String, String> e) =>
                                      DropdownMenuItem<String>(
                                        value: e.value,
                                        child: Text(e.value),
                                      ))
                              .toList(),
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints.expand(
                          height: 100.0,
                        ),
                        padding: const EdgeInsets.only(
                            left: 30.0, top: 0, right: 30, bottom: 0),
                        alignment: Alignment.center,
                        child: DropdownButton<String>(
                          value: level3Actual,
                          hint: Text(
                            "Select a level 3 account",
                            /*style: TextStyle(
                              color,
                            ),*/
                          ),
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
                              level3Actual = newValue;
                            });
                          },
                          items: level3Values.entries
                              .map<DropdownMenuItem<String>>(
                                  (MapEntry<String, String> e) =>
                                      DropdownMenuItem<String>(
                                        value: e.value,
                                        child: Text(e.value),
                                      ))
                              .toList(),
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints.expand(
                          height: 50.0,
                        ),
                        padding: const EdgeInsets.only(
                            left: 30.0, top: 0, right: 30, bottom: 0),
                        //color: Colors.blue[600],
                        alignment: Alignment.center,
                        //child: Text('Submit'),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: DropdownButton<String>(
                            value: costtype,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(color: Color(0xff0957FF)),
                            underline: Container(
                              height: 2,
                              width: 2000,
                              color: Color(0xff0957FF),
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                costtype = newValue;
                              });
                            },
                            items: costtypesValues.entries
                                .map<DropdownMenuItem<String>>(
                                    (MapEntry<String, String> e) =>
                                        DropdownMenuItem<String>(
                                          value: e.value,
                                          child: Text(e.value),
                                        ))
                                .toList(),
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
                                actualTextFieldController.text = '';
                              },
                            ),
                          ),
                          ButtonTheme(
                            minWidth: 150.0,
                            height: 60.0,
                            child: RaisedButton(
                              child: Text('Save',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 17)),
                              color: Color(0xff0957FF), //df7599 - 0957FF
                              onPressed: () {
                                sendBackend('actual');
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        constraints: BoxConstraints.expand(
                          height: 40,
                        ),

                        padding: const EdgeInsets.only(
                            left: 0.0, top: 10, right: 0, bottom: 0),
                        //color: Colors.blue[600],
                        alignment: Alignment.center,
                        //child: Text('Submit'),
                        child: Text(
                          'Budget',
                          style: TextStyle(fontSize: 30),
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
                        child: TextFormField(
                          keyboardType: TextInputType
                              .number, //keyboard with numbers only will appear to the screen
                          style: TextStyle(
                              height: 2), //increases the height of cursor
                          autofocus: true,
                          controller: budgetTextFieldController,
                          decoration: InputDecoration(
                              // hintText: 'Enter ur amount',
                              //hintStyle: TextStyle(height: 1.75),
                              labelText: 'Enter your amount',
                              labelStyle: TextStyle(
                                  height: 0.5,
                                  color: Color(
                                      0xff0957FF)), //increases the height of cursor
                              icon: Icon(
                                Icons.attach_money,
                                color: Color(0xff0957FF),
                              ),
                              //prefixIcon: Icon(Icons.attach_money),
                              //labelStyle: TextStyle(color: Color(0xff0957FF)),
                              enabledBorder: new UnderlineInputBorder(
                                  borderSide: new BorderSide(
                                      color: Color(0xff0957FF)))),
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints.expand(
                          height: 100,
                          //width: MediaQuery.of(context).size.width * .8
                        ),

                        padding: const EdgeInsets.only(
                            left: 30.0, top: 0, right: 30, bottom: 0),
                        //color: Colors.blue[600],
                        alignment: Alignment.center,
                        //child: Text('Submit'),
                        child: DropdownButton<String>(
                          value: level1Budget,
                          hint: Text(
                            "Select a level 1 account",
                            /*style: TextStyle(
                              color,
                            ),*/
                          ),
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
                              level1Budget = newValue;
                            });
                          },
                          items: level1Values.entries
                              .map<DropdownMenuItem<String>>(
                                  (MapEntry<String, String> e) =>
                                      DropdownMenuItem<String>(
                                        value: e.value,
                                        child: Text(e.value),
                                      ))
                              .toList(),
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
                          value: level2Budget,
                          hint: Text(
                            "Select a level 2 account",
                            /*style: TextStyle(
                              color,
                            ),*/
                          ),
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
                              level2Budget = newValue;
                            });
                          },
                          items: level2Values.entries
                              .map<DropdownMenuItem<String>>(
                                  (MapEntry<String, String> e) =>
                                      DropdownMenuItem<String>(
                                        value: e.value,
                                        child: Text(e.value),
                                      ))
                              .toList(),
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints.expand(
                          height: 100.0,
                        ),
                        padding: const EdgeInsets.only(
                            left: 30.0, top: 0, right: 30, bottom: 0),
                        alignment: Alignment.center,
                        child: DropdownButton<String>(
                          value: level3Budget,
                          hint: Text(
                            "Select a level 3 account",
                            /*style: TextStyle(
                              color,
                            ),*/
                          ),
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
                              level3Budget = newValue;
                            });
                          },
                          items: level3Values.entries
                              .map<DropdownMenuItem<String>>(
                                  (MapEntry<String, String> e) =>
                                      DropdownMenuItem<String>(
                                        value: e.value,
                                        child: Text(e.value),
                                      ))
                              .toList(),
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints.expand(
                          height: 50.0,
                        ),
                        padding: const EdgeInsets.only(
                            left: 30.0, top: 0, right: 30, bottom: 0),
                        //color: Colors.blue[600],
                        alignment: Alignment.center,
                        //child: Text('Submit'),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: DropdownButton<String>(
                            value: costtype,
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
                                costtype = newValue;
                              });
                            },
                            items: costtypesValues.entries
                                .map<DropdownMenuItem<String>>(
                                    (MapEntry<String, String> e) =>
                                        DropdownMenuItem<String>(
                                          value: e.value,
                                          child: Text(e.value),
                                        ))
                                .toList(),
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
                                budgetTextFieldController.text = '';

                                /*
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    // return object of type Dialog
                                    return AlertDialog(
                                      title: new Text("Alert Dialog title"),
                                      content: new Text(
                                          "Alert Dialog body: costtype"),
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
                                */
                              },
                            ),
                          ),
                          ButtonTheme(
                            minWidth: 150.0,
                            height: 60.0,
                            child: RaisedButton(
                              child: Text('Save',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 17)),
                              color: Color(0xff0957FF), //df7599 - 0957FF
                              onPressed: () {
                                sendBackend('budget');
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
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
