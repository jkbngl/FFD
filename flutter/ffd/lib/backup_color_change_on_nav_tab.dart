import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:after_layout/after_layout.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';

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

const String MIN_DATETIME = '2010-05-12';
const String MAX_DATETIME = '2021-11-25';
const String INIT_DATETIME = '2019-05-17';

class _MyHomePageState extends State<MyHomePage>
    with AfterLayoutMixin<MyHomePage> {
  int _currentIndex = 0;
  PageController _pageController;

  // Bool which defined if accounts and costtypes needs to be refetched or can be cached
  bool fetchAccountsAndCostTypes = false;

  // Effective objects which are displayed as value in dropdown and send to backend on SAVE
  Account level1ActualObject;
  Account level1BudgetObject;
  Account level2ActualObject;
  Account level2BudgetObject;
  Account level3ActualObject;
  Account level3BudgetObject;
  CostType costTypeObjectActual;
  CostType costTypeObjectBudget;

  // Json objects which are fetched from API
  var level1AccountsJson;
  var level2AccountsJson;
  var level3AccountsJson;
  var costTypesJson;

  // List has to be filled with 1 default account so that we don't get a null error on startup - Lists with all values for dropdown
  List<Account> level1AccountsList = <Account>[
    const Account(-99, 'UNDEFINED', null),
  ];

  List<Account> level2AccountsList = <Account>[
    const Account(-100, 'UNDEFINED', null)
  ];

  List<Account> level3AccountsList = <Account>[
    const Account(-101, 'UNDEFINED', null)
  ];

  List<CostType> costTypesList = <CostType>[const CostType(-99, 'UNDEFINED')];

  final actualTextFieldController = TextEditingController();
  final budgetTextFieldController = TextEditingController();

  DateTime _dateTime;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Init with a default so that we don't get a null error on startup
    level1ActualObject = level1AccountsList[0];
    level1BudgetObject = level1AccountsList[0];
    level2ActualObject = level2AccountsList[0];
    level2BudgetObject = level2AccountsList[0];
    level3ActualObject = level3AccountsList[0];
    level3BudgetObject = level3AccountsList[0];
    costTypeObjectActual = costTypesList[0];
    costTypeObjectBudget = costTypesList[0];

    _dateTime = DateTime.parse(INIT_DATETIME);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    checkForChanges(true, fetchAccountsAndCostTypes);
  }

  void checkForChanges(bool onStartup, bool fetch) async {
    print("Checking for changes $onStartup");

    if (fetch || onStartup) {
      level1AccountsJson =
          await http.read('http://192.168.0.21:5000/api/ffd/accounts/1');
      level2AccountsJson =
          await http.read('http://192.168.0.21:5000/api/ffd/accounts/2');
      level3AccountsJson =
          await http.read('http://192.168.0.21:5000/api/ffd/accounts/3');
      costTypesJson =
          await http.read('http://192.168.0.21:5000/api/ffd/costtypes/');
    }

    var parsedAccountLevel1 = json.decode(level1AccountsJson);
    var parsedAccountLevel2 = json.decode(level2AccountsJson);
    var parsedAccountLevel3 = json.decode(level3AccountsJson);
    var parsedCostTypes = json.decode(costTypesJson);

    Account accountToAdd;
    CostType typeToAdd;

    for (var account in parsedAccountLevel1) {
      accountToAdd = new Account(
          account['id'], account['name'], account['parent_account']);
      Account existingItem = level1AccountsList.firstWhere(
          (itemToCheck) => itemToCheck.id == accountToAdd.id,
          orElse: () => null);

      if (existingItem == null) {
        level1AccountsList.add(accountToAdd);
      }
    }

    for (var account in parsedAccountLevel2) {
      accountToAdd = new Account(
          account['id'], account['name'], account['parent_account']);
      Account existingItem = level2AccountsList.firstWhere(
          (itemToCheck) => itemToCheck.id == accountToAdd.id,
          orElse: () => null);

      if (account['name'] == 'GAS') print(account['parent_account']);

      if (existingItem == null) {
        level2AccountsList.add(accountToAdd);
      }
    }

    for (var account in parsedAccountLevel3) {
      accountToAdd = new Account(
          account['id'], account['name'], account['parent_account']);
      Account existingItem = level3AccountsList.firstWhere(
          (itemToCheck) => itemToCheck.id == accountToAdd.id,
          orElse: () => null);

      if (existingItem == null) {
        level3AccountsList.add(accountToAdd);
      }
    }

    for (var type in parsedCostTypes) {
      typeToAdd = new CostType(type['id'], type['name']);
      CostType existingItem = costTypesList.firstWhere(
          (itemToCheck) => itemToCheck.id == typeToAdd.id,
          orElse: () => null);

      if (existingItem == null) {
        costTypesList.add(typeToAdd);
      }
    }
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
    int level1LocalId;
    int level2LocalId;
    int level3LocalId;
    String costTypeLocal;
    int costTypeLocalId;
    int amount;

    if (type.toLowerCase() == 'actual') {
      level1Local = level1ActualObject.name;
      level2Local = level2ActualObject.name;
      level3Local = level3ActualObject.name;
      level1LocalId = level1ActualObject.id;
      level2LocalId = level2ActualObject.id;
      level3LocalId = level3ActualObject.id;
      costTypeLocal = costTypeObjectActual.name;
      costTypeLocalId = costTypeObjectActual.id;
      amount = int.parse(actualTextFieldController.text);
    } else if (type.toLowerCase() == 'budget') {
      level1Local = level1BudgetObject.name;
      level2Local = level2BudgetObject.name;
      level3Local = level3BudgetObject.name;
      level1LocalId = level1BudgetObject.id;
      level2LocalId = level2BudgetObject.id;
      level3LocalId = level3BudgetObject.id;
      costTypeLocal = costTypeObjectBudget.name;
      costTypeLocalId = costTypeObjectBudget.id;
      amount = int.parse(budgetTextFieldController.text);
    }

    var body = {
      'amount': amount.toString(),
      'level1': level1Local,
      'level2': level2Local,
      'level3': level3Local,
      'level1id': level1LocalId.toString(),
      'level2id': level2LocalId.toString(),
      'level3id': level3LocalId.toString(),
      'costtype': costTypeLocal,
      'costtypeid': costTypeLocalId.toString(),
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
  }

  arrangeAccounts(int level, String type) {
    // Refresh accounts lists, needed because the accounts are cleared from account list and when another level1 or 2 are selected the list only has the level2 and 3 accounts from the other level1 or 2
    checkForChanges(false, true);

    if (level == 1) {
      // Get the first account which matches the level1 account or the default hardcoded account - all can not be deleted as the dropdown must not be empty
      level2ActualObject = level2AccountsList.firstWhere(
          (account) => account.parentAccount == level1ActualObject.id,
          orElse: () => level2AccountsList[0]);
      // Remove all accounts which do not match the parent account but the default hardcoded account - all can not be deleted as the dropdown must not be empty
      level2AccountsList.retainWhere((account) =>
          account.parentAccount == level1ActualObject.id || account.id < 0);

      // Same as above for level3
      level3ActualObject = level3AccountsList.firstWhere(
          (account) => account.parentAccount == level2ActualObject.id,
          orElse: () => level3AccountsList[0]);
      level3AccountsList.retainWhere((account) =>
          account.parentAccount == level2ActualObject.id || account.id < 0);
    } else if (level == 2) {
      // Get the first account which matches the level1 account or the default hardcoded account - all can not be deleted as the dropdown must not be empty
      level3ActualObject = level3AccountsList.firstWhere(
          (account) => account.parentAccount == level2ActualObject.id,
          orElse: () => level3AccountsList[0]);
      // Remove all accounts which do not match the parent account but the default hardcoded account - all can not be deleted as the dropdown must not be empty
      level3AccountsList.retainWhere((account) =>
          account.parentAccount == level2ActualObject.id || account.id < 0);
    }
  }

  /// Display date picker.
  void _showDatePicker() {
    DatePicker.showDatePicker(
      context,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
        confirm: Text('Save', style: TextStyle(color: Color(0xff0957FF))),
        cancel: Text('Cancel', style: TextStyle(color: Colors.black)),
      ),
      minDateTime: DateTime.parse(MIN_DATETIME),
      maxDateTime: DateTime.parse(MAX_DATETIME),
      initialDateTime: _dateTime,
      onClose: () => print("----- onClose -----"),
      onCancel: () => print('onCancel'),
      onChange: (dateTime, List<int> index) {
        setState(() {
          _dateTime = dateTime;
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _dateTime = dateTime;
        });
      },
    );
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
            checkForChanges(false, fetchAccountsAndCostTypes);
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
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Select a different date   ',
                              style: TextStyle(fontSize: 15),
                            ),
                            FloatingActionButton(
                              onPressed: _showDatePicker,
                              tooltip: 'Select a different date',
                              child: Icon(Icons.date_range),
                              backgroundColor: Color(0xff0957FF),

                            )
                          ]),
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

                            print(level1ActualObject.name);

                            arrangeAccounts(1, 'actual');
                          },
                          items: level1AccountsList.map((Account account) {
                            return new DropdownMenuItem<Account>(
                              value: account,
                              child: new Text(
                                account.name,
                              ),
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
                        child: DropdownButton<Account>(
                          value: level2ActualObject,
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
                          onChanged: (Account newValue) {
                            setState(() {
                              level2ActualObject = newValue;
                            });

                            arrangeAccounts(2, 'actual');
                          },
                          items: level2AccountsList.map((Account account) {
                            return new DropdownMenuItem<Account>(
                              value: account,
                              child: new Text(
                                account.name,
                              ),
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
                        alignment: Alignment.center,
                        child: DropdownButton<Account>(
                          value: level3ActualObject,
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
                          onChanged: (Account newValue) {
                            setState(() {
                              level3ActualObject = newValue;
                            });

                            arrangeAccounts(3, 'actual');
                          },
                          items: level3AccountsList.map((Account account) {
                            return new DropdownMenuItem<Account>(
                              value: account,
                              child: new Text(
                                account.name,
                              ),
                            );
                          }).toList(),
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
                          child: DropdownButton<CostType>(
                            value: costTypeObjectActual,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(color: Color(0xff0957FF)),
                            underline: Container(
                              height: 2,
                              width: 2000,
                              color: Color(0xff0957FF),
                            ),
                            onChanged: (CostType newValue) {
                              setState(() {
                                costTypeObjectActual = newValue;
                              });

                              arrangeAccounts(0, 'costtypes');
                            },
                            items: costTypesList.map((CostType type) {
                              return new DropdownMenuItem<CostType>(
                                value: type,
                                child: new Text(
                                  type.name,
                                ),
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
                        child: DropdownButton<Account>(
                          value: level1BudgetObject,
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
                              level1BudgetObject = newValue;
                            });

                            arrangeAccounts(1, 'budget');
                          },
                          items: level1AccountsList.map((Account account) {
                            return new DropdownMenuItem<Account>(
                              value: account,
                              child: new Text(
                                account.name,
                              ),
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
                        child: DropdownButton<Account>(
                          value: level2BudgetObject,
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
                          onChanged: (Account newValue) {
                            setState(() {
                              level2BudgetObject = newValue;
                            });

                            arrangeAccounts(2, 'budget');
                          },
                          items: level2AccountsList.map((Account account) {
                            return new DropdownMenuItem<Account>(
                              value: account,
                              child: new Text(
                                account.name,
                              ),
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
                        alignment: Alignment.center,
                        child: DropdownButton<Account>(
                          value: level3BudgetObject,
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
                          onChanged: (Account newValue) {
                            setState(() {
                              level3BudgetObject = newValue;
                            });

                            arrangeAccounts(3, 'budget');
                          },
                          items: level3AccountsList.map((Account account) {
                            return new DropdownMenuItem<Account>(
                              value: account,
                              child: new Text(
                                account.name,
                              ),
                            );
                          }).toList(),
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
                          child: DropdownButton<CostType>(
                            value: costTypeObjectBudget,
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
                            onChanged: (CostType newValue) {
                              setState(() {
                                costTypeObjectBudget = newValue;
                              });

                              arrangeAccounts(0, 'costtpyes');
                            },
                            items: costTypesList.map((CostType type) {
                              return new DropdownMenuItem<CostType>(
                                value: type,
                                child: new Text(
                                  type.name,
                                ),
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
