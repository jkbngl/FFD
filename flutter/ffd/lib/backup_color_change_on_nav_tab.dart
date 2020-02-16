import 'dart:developer';
import 'dart:io';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:ffd/DonutPieChart.dart';
import 'package:ffd/StackedBarTargetLineChart.dart';
import 'package:ffd/SimpleBarChart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:async';

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

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
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

class CompanySizeVsNumberOfCompanies {
  String companySize;
  double numberOfCompanies;
  int accountId;

  CompanySizeVsNumberOfCompanies(this.companySize, this.numberOfCompanies, this.accountId);
}

class homescreenPie {
  String type;
  double amount;

  homescreenPie(this.type, this.amount);
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

String MIN_DATETIME = (DateTime.now().year - 5).toString() +
    '-' +
    DateTime.now().month.toString().padLeft(2, '0') +
    '-' +
    DateTime.now().day.toString().padLeft(2, '0');
String MAX_DATETIME = (DateTime.now().year + 5).toString() +
    '-' +
    DateTime.now().month.toString().padLeft(2, '0') +
    '-' +
    DateTime.now().day.toString().padLeft(2, '0');
String INIT_DATETIME = DateTime.now().year.toString() +
    '-' +
    DateTime.now().month.toString().padLeft(2, '0') +
    '-' +
    DateTime.now().day.toString().padLeft(2, '0');
String _format = 'yyyy-MMMM';

class _MyHomePageState extends State<MyHomePage>
    with AfterLayoutMixin<MyHomePage> {
  Widget chartContainer = Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [Text('Chart Viewer')],
  );

  int _currentIndex = 0;
  PageController _pageController;

  // Bool which defined if accounts and costTypes needs to be refetched or can be cached
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

  double rating = 0;
  // when a same level2 is selected as is already selected the accounts are multiplicated, this dummyobject checks if the new selected account is the same as the old one
  Account dummyAccount;

  // Json objects which are fetched from API
  var level1AccountsJson;
  var level2AccountsJson;
  var level3AccountsJson;
  var costTypesJson;

  // List has to be filled with 1 default account so that we don't get a null error on startup - Lists with all values for dropdown
  List<Account> level1AccountsList = <Account>[
    const Account(-99, 'UNDEFINED', null),
  ];
  List<Account> level1ActualAccountsList = <Account>[
    const Account(-99, 'UNDEFINED', null),
  ];
  List<Account> level1BudgetAccountsList = <Account>[
    const Account(-99, 'UNDEFINED', null),
  ];
  List<Account> level1AdminAccountsList = <Account>[
    const Account(-99, 'UNDEFINED', null),
  ];

  List<Account> level2AccountsList = <Account>[
    const Account(-100, 'UNDEFINED', null)
  ];
  List<Account> level2ActualAccountsList = <Account>[
    const Account(-100, 'UNDEFINED', null)
  ];
  List<Account> level2BudgetAccountsList = <Account>[
    const Account(-100, 'UNDEFINED', null)
  ];
  List<Account> level2AdminAccountsList = <Account>[
    const Account(-100, 'UNDEFINED', null)
  ];

  List<Account> level3AccountsList = <Account>[
    const Account(-101, 'UNDEFINED', null)
  ];
  List<Account> level3ActualAccountsList = <Account>[
    const Account(-101, 'UNDEFINED', null)
  ];
  List<Account> level3BudgetAccountsList = <Account>[
    const Account(-101, 'UNDEFINED', null)
  ];
  List<Account> level3AdminAccountsList = <Account>[
    const Account(-101, 'UNDEFINED', null)
  ];

  List<CostType> costTypesList = <CostType>[const CostType(-99, 'UNDEFINED')];

  final actualTextFieldController = TextEditingController();
  final budgetTextFieldController = TextEditingController();

  // Datetime object for selecting the date when the actual/ budget should be saved
  DateTime dateTimeActual;
  DateTime dateTimeBudget;
  DateTime dateTimeVisualizer;

  var visualizerData = [
    CompanySizeVsNumberOfCompanies("1-25", 10, -69),
  ];

  var homescreenData = [
    homescreenPie('Dummy1', 10),
    homescreenPie('Dummy2', 10),
    homescreenPie('Dummy3', 10),

  ];

  // booleans loaded from DB to check whether accounts, which account levels and costTypes should be used
  bool areAccountsActive = true;
  bool areLevel1AccountsActive = true;
  bool areLevel2AccountsActive = true;
  bool areLevel3AccountsActive = true;
  bool areCostTypesActive = true;

  // Controllers used which store the value of the new accounts/ CostTypes added
  final newLevel1TextFieldController = TextEditingController();
  final newLevel2TextFieldController = TextEditingController();
  final newLevel3TextFieldController = TextEditingController();
  final newAccountLevel1CommentTextFieldController = TextEditingController();
  final newAccountLevel2CommentTextFieldController = TextEditingController();
  final newAccountLevel3CommentTextFieldController = TextEditingController();
  final newCostTypeTextFieldController = TextEditingController();
  final newCostTypeCommentTextFieldController = TextEditingController();

  // Account and Costtype objedts which are used in the admin page
  Account level1AdminObject;
  Account level2AdminObject;
  Account level3AdminObject;
  CostType costTypeObjectAdmin;

  // Dynamic title at the top of the screen which is changed depending on which page is selected
  var appBarTitleText = new Text("FFD v2");

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Init with a default so that we don't get a null error on startup
    level1ActualObject = level1ActualAccountsList[0];
    level1BudgetObject = level1BudgetAccountsList[0];
    level1AdminObject = level1AdminAccountsList[0];

    level2ActualObject = level2ActualAccountsList[0];
    level2BudgetObject = level2BudgetAccountsList[0];
    level2AdminObject = level2AdminAccountsList[0];

    level3ActualObject = level3ActualAccountsList[0];
    level3BudgetObject = level3BudgetAccountsList[0];
    level3AdminObject = level3AdminAccountsList[0];

    costTypeObjectActual = costTypesList[0];
    costTypeObjectBudget = costTypesList[0];
    costTypeObjectAdmin = costTypesList[0];

    dateTimeActual = DateTime.parse(INIT_DATETIME);
    dateTimeBudget = DateTime.parse(INIT_DATETIME);
    dateTimeVisualizer = DateTime.parse(INIT_DATETIME);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    // Calling the same function "after layout" to resolve the issue.

    //await checkForChanges(true, fetchAccountsAndCostTypes, 'all');
    checkForChanges(true, fetchAccountsAndCostTypes, 'all');

    // Keep loadHomescreen before loadAmount, because if not the state will be set 2 times and it will look strange
    loadHomescreen();
    loadAmount();

    setState(() {

    });
  }

  loadAmount() async {
    int level_type = 1;
    int cost_type = -1;
    int parent_account = -1;
    int year = dateTimeVisualizer.year;
    int month = dateTimeVisualizer.month;
    String _type = 'actual';

    var amounts = await http.read(
        'http://192.168.0.21:5000/api/ffd/amounts/?level_type=$level_type&cost_type=$cost_type&parent_account=$parent_account&year=$year&month=$month&_type=$_type');

    var parsedAmounts = json.decode(amounts);

    final desktopSalesData = [new OrdinalSales('2069', 5)];

    visualizerData.clear();

    for (var amounts in parsedAmounts) {
      visualizerData.add(CompanySizeVsNumberOfCompanies(
          amounts['level$level_type'].toString(), amounts['sum'], amounts['level${level_type.toString()}_fk']));
    }

    final desktopTargetLineData = [
      new OrdinalSales('2014', 25),
      new OrdinalSales('2015', 60),
      new OrdinalSales('2016', 100),
      new OrdinalSales('2017', 110),
    ];

    setState(() {});
  }

  loadHomescreen() async {
    int level_type = -1;
    int cost_type = -1;
    int parent_account = -1;
    int year = 2020;
    int month = 2;
    String _type = 'actual';

    //var amounts = await http.read('http://192.168.0.21:5000/api/ffd/amounts/?level_type=1&cost_type=-1&parent_account=-1&year=2020&month=1&_type=actual');
    var actual = await http.read(
        'http://192.168.0.21:5000/api/ffd/amounts/?level_type=$level_type&cost_type=$cost_type&parent_account=$parent_account&year=$year&month=$month&_type=$_type');

    _type = 'budget';

    var budget = await http.read(
        'http://192.168.0.21:5000/api/ffd/amounts/?level_type=$level_type&cost_type=$cost_type&parent_account=$parent_account&year=$year&month=$month&_type=$_type');

    var parsedActual = json.decode(actual);
    var parsedBudget = json.decode(budget);

    final actualArray = [new homescreenPie('DUMMY2', 5)];
    final budgetArray = [new homescreenPie('DUMMY3', 5)];

    homescreenData.clear();

    for (var amount in parsedActual) {
      homescreenData.add(homescreenPie('Actual', amount['sum']));
    }

    for (var amount in parsedBudget) {
      homescreenData.add(
          homescreenPie('Budget', amount['sum'] - homescreenData[0].amount));
    }

    for (var amount in parsedBudget) {
      homescreenData.add(
          homescreenPie('OverallBudget', amount['sum']));
    }

    final desktopTargetLineData = [
      new OrdinalSales('2014', 25),
      new OrdinalSales('2015', 60),
      new OrdinalSales('2016', 100),
      new OrdinalSales('2017', 110),
    ];

    setState(() {});
  }

  void checkForChanges(bool onStartup, bool fetch, String type) async {
    print("Checking for changes $onStartup - $fetch, for type $type");

    Account accountToAdd;
    CostType typeToAdd;

    List<CostType> costTypesToRemove = <CostType>[];
    List<Account> accountsToRemove = <Account>[];

    List<Account> accountsListStating = <Account>[
      const Account(-99, 'UNDEFINED', null)
    ];
    List<CostType> costTypesListStating = <CostType>[
      const CostType(-99, 'UNDEFINED')
    ];

    bool remove = true;

    if (fetch || onStartup) {
      level1AccountsJson =
          await http.read('http://192.168.0.21:5000/api/ffd/accounts/1');
      level2AccountsJson =
          await http.read('http://192.168.0.21:5000/api/ffd/accounts/2');
      level3AccountsJson =
          await http.read('http://192.168.0.21:5000/api/ffd/accounts/3');
      costTypesJson =
          await http.read('http://192.168.0.21:5000/api/ffd/costtypes/');

      var parsedAccountLevel1 = json.decode(level1AccountsJson);
      var parsedAccountLevel2 = json.decode(level2AccountsJson);
      var parsedAccountLevel3 = json.decode(level3AccountsJson);
      var parsedCostTypes = json.decode(costTypesJson);

      for (var account in parsedAccountLevel1) {
        accountToAdd = new Account(
            account['id'], account['name'], account['parent_account']);

        // This additional step would not be needed for level1 (#40 but to have all the same)
        Account existingItem;
        if (type == 'actual') {
          existingItem = level1ActualAccountsList.firstWhere(
              (itemToCheck) => itemToCheck.id == accountToAdd.id,
              orElse: () => null);
        } else if (type == 'budget') {
          existingItem = level1BudgetAccountsList.firstWhere(
              (itemToCheck) => itemToCheck.id == accountToAdd.id,
              orElse: () => null);
        } else if (type == 'admin') {
          existingItem = level1AdminAccountsList.firstWhere(
              (itemToCheck) => itemToCheck.id == accountToAdd.id,
              orElse: () => null);
        } else {
          existingItem = level1AccountsList.firstWhere(
              (itemToCheck) => itemToCheck.id == accountToAdd.id,
              orElse: () => null);
        }

        accountsListStating.add(accountToAdd);

        if (existingItem == null) {
          if (type == 'actual' || onStartup) {
            level1ActualAccountsList.add(accountToAdd);
          }
          if (type == 'budget' || onStartup) {
            level1BudgetAccountsList.add(accountToAdd);
          }
          if (type == 'admin' || onStartup) {
            level1AdminAccountsList.add(accountToAdd);
          }

          level1AccountsList.add(accountToAdd);
        }
      }

      // Loop through all level1 accounts ever added on runtime, check with the ones added on the last run and add the ones which are not in the new list to another list
      level1AccountsList.forEach((element) {
        remove = true;

        // If an item is not in the staging list and is also not the undefined default account
        for (int i = 0; i < accountsListStating.length; i++) {
          if (accountsListStating[i].id == element.id) {
            remove = false;
          }
        }
        if (remove && element.id > 0) {
          accountsToRemove.add(element);
        }
      });

      //print("REMOVING (ACCOUNTLEVEL1): ");
      accountsToRemove.forEach((element) {
        //print(element.name);
        level1AccountsList.remove(element);

        level1ActualAccountsList.remove(element);
        level1BudgetAccountsList.remove(element);
        level1AdminAccountsList.remove(element);
      });

      //print("HAVING (ACCOUNTLEVEL1): ");
      level1AccountsList.forEach((element) {
        //print(element.name);
      });

      accountsListStating.clear();
      accountsToRemove.clear();

      for (var account in parsedAccountLevel2) {
        accountToAdd = new Account(
            account['id'], account['name'], account['parent_account']);

        // #40
        Account existingItem;
        if (type == 'actual') {
          existingItem = level2ActualAccountsList.firstWhere(
              (itemToCheck) => itemToCheck.id == accountToAdd.id,
              orElse: () => null);
        } else if (type == 'budget') {
          existingItem = level2BudgetAccountsList.firstWhere(
              (itemToCheck) => itemToCheck.id == accountToAdd.id,
              orElse: () => null);
        } else if (type == 'admin') {
          existingItem = level2AdminAccountsList.firstWhere(
              (itemToCheck) => itemToCheck.id == accountToAdd.id,
              orElse: () => null);
        } else {
          existingItem = level2AccountsList.firstWhere(
              (itemToCheck) => itemToCheck.id == accountToAdd.id,
              orElse: () => null);
        }

        accountsListStating.add(accountToAdd);

        if (existingItem == null) {
          if (type == 'actual' || onStartup) {
            level2ActualAccountsList.add(accountToAdd);

            print("READDED");
          }
          if (type == 'budget' || onStartup) {
            level2BudgetAccountsList.add(accountToAdd);
          }
          if (type == 'admin' || onStartup) {
            level2AdminAccountsList.add(accountToAdd);
          }

          level2AccountsList.add(accountToAdd);
        }
      }

      // Loop through all level1 accounts ever added on runtime, check with the ones added on the last run and add the ones which are not in the new list to another list
      level2AccountsList.forEach((element) {
        remove = true;

        // If an item is not in the staging list and is also not the undefined default account
        for (int i = 0; i < accountsListStating.length; i++) {
          if (accountsListStating[i].id == element.id) {
            remove = false;
          }
        }
        if (remove && element.id > 0) {
          accountsToRemove.add(element);
        }
      });

      //print("REMOVING (ACCOUNTLEVEL2): ");
      accountsToRemove.forEach((element) {
        //print(element.name);
        level2AccountsList.remove(element);

        level2ActualAccountsList.remove(element);
        level2BudgetAccountsList.remove(element);
        level2AdminAccountsList.remove(element);
      });

      //print("HAVING (ACCOUNTLEVEL1): ");
      level2AccountsList.forEach((element) {
        //print(element.name);
      });

      accountsListStating.clear();
      accountsToRemove.clear();

      for (var account in parsedAccountLevel3) {
        accountToAdd = new Account(
            account['id'], account['name'], account['parent_account']);
        // #40
        Account existingItem;
        if (type == 'actual') {
          existingItem = level3ActualAccountsList.firstWhere(
              (itemToCheck) => itemToCheck.id == accountToAdd.id,
              orElse: () => null);
        } else if (type == 'budget') {
          existingItem = level3BudgetAccountsList.firstWhere(
              (itemToCheck) => itemToCheck.id == accountToAdd.id,
              orElse: () => null);
        } else if (type == 'admin') {
          existingItem = level3AdminAccountsList.firstWhere(
              (itemToCheck) => itemToCheck.id == accountToAdd.id,
              orElse: () => null);
        } else {
          existingItem = level3AccountsList.firstWhere(
              (itemToCheck) => itemToCheck.id == accountToAdd.id,
              orElse: () => null);
        }

        accountsListStating.add(accountToAdd);

        if (existingItem == null) {
          level3AccountsList.add(accountToAdd);

          level3ActualAccountsList.add(accountToAdd);
          level3BudgetAccountsList.add(accountToAdd);
          level3AdminAccountsList.add(accountToAdd);
        }
      }

      // Loop through all level1 accounts ever added on runtime, check with the ones added on the last run and add the ones which are not in the new list to another list
      level3AccountsList.forEach((element) {
        remove = true;

        // If an item is not in the staging list and is also not the undefined default account
        for (int i = 0; i < accountsListStating.length; i++) {
          if (accountsListStating[i].id == element.id) {
            remove = false;
          }
        }
        if (remove && element.id > 0) {
          accountsToRemove.add(element);
        }
      });

      //print("REMOVING (ACCOUNTLEVEL3): ");
      accountsToRemove.forEach((element) {
        //print(element.name);
        level3AccountsList.remove(element);

        level3ActualAccountsList.remove(element);
        level3BudgetAccountsList.remove(element);
        level3AdminAccountsList.remove(element);
      });

      //print("HAVING (ACCOUNTLEVEL3): ");
      level3AccountsList.forEach((element) {
        //print(element.name);
      });

      accountsListStating.clear();
      accountsToRemove.clear();

      for (var type in parsedCostTypes) {
        typeToAdd = new CostType(type['id'], type['name']);
        CostType existingItem = costTypesList.firstWhere(
            (itemToCheck) => itemToCheck.id == typeToAdd.id,
            orElse: () => null);

        costTypesListStating.add(typeToAdd);

        if (existingItem == null) {
          costTypesList.add(typeToAdd);
        }
      }

      // Loop through all costtypes ever added on runtime, check with the ones added on the last run and add the ones which are not in the new list to another list
      costTypesList.forEach((element) {
        remove = true;

        // If an item is not in the staging list and is also not the undefined default account
        for (int i = 0; i < costTypesListStating.length; i++) {
          if (costTypesListStating[i].id == element.id) {
            remove = false;
          }
        }
        if (remove && element.id > 0) {
          costTypesToRemove.add(element);
        }
      });

      //print("REMOVING (COSTTYPE: ");
      costTypesToRemove.forEach((element) {
        //print(element.name);
        costTypesList.remove(element);
      });

      //print("HAVING (COSTTYPES): ");
      costTypesList.forEach((element) {
        //print(element.name);
      });
    }

    fetchAccountsAndCostTypes = false;

    // needed to reinitialize dropdowns with new values
    setState(() {});
  }

  Future<String> fetchPost() async {
    int level_type = 1;
    int cost_type = -1;
    int parent_account = -1;
    int year = 2020;
    int month = 2;
    String _type = 'actual';

    final response = await http.get(
        'http://192.168.0.21:5000/api/ffd/amounts/?level_type=$level_type&cost_type=$cost_type&parent_account=$parent_account&year=$year&month=$month&_type=$_type');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      return response.body;
    } else {
      // If the server did not return a 200 OK response, then throw an exception.
      throw Exception('Failed to load post');
    }
  }

  void sendBackend(String type) async {
    var url = 'http://192.168.0.21:5000/api/ffd/';

    // Whenever with the backend is communicated its best to reload the accounts and costtpyes
    if (type.contains('add') || type.contains('delete'))
      fetchAccountsAndCostTypes = true;

    // Are here in case needed sometimes later
    var params = {
      "user": "DOC000506", // TODO GET FIREBASE USER OBJECT HERE
    };

    var body = {
      'type': type,
      'amount': type == 'actual'
          ? actualTextFieldController.text
          : budgetTextFieldController.text,
      'level1':
          type == 'actual' ? level1ActualObject.name : level1BudgetObject.name,
      'level2':
          type == 'actual' ? level2ActualObject.name : level2BudgetObject.name,
      'level3':
          type == 'actual' ? level3ActualObject.name : level3BudgetObject.name,
      'level1id': type == 'actual'
          ? level1ActualObject.id.toString()
          : level1BudgetObject.id.toString(),
      'level2id': type == 'actual'
          ? level2ActualObject.id.toString()
          : level2BudgetObject.id.toString(),
      'level3id': type == 'actual'
          ? level3ActualObject.id.toString()
          : level3BudgetObject.id.toString(),
      'costtype': type == 'actual'
          ? costTypeObjectActual.name
          : costTypeObjectBudget.name,
      'costtypeid': type == 'actual'
          ? costTypeObjectActual.id.toString()
          : costTypeObjectBudget.id.toString(),
      'date': type == 'actual'
          ? dateTimeActual.toString()
          : dateTimeBudget.toString(),
      'year': type == 'actual'
          ? dateTimeActual.year.toString()
          : dateTimeBudget.year.toString(),
      'month': type == 'actual'
          ? dateTimeActual.month.toString()
          : dateTimeBudget.month.toString(),
      'costtypetoadd': newCostTypeTextFieldController.text,
      'costtypetoaddcomment': newCostTypeCommentTextFieldController.text,
      'costtypetodeleteid': costTypeObjectAdmin.id.toString(),
      'costtypetodelete': costTypeObjectAdmin.name,
      'adminaccountlevel1id': level1AdminObject.id.toString(),
      'adminaccountlevel2id': level2AdminObject.id.toString(),
      'adminaccountlevel3id': level3AdminObject.id.toString(),
      'adminaccountlevel1': level1AdminObject.name,
      'adminaccountlevel2': level2AdminObject.name,
      'adminaccountlevel3': level3AdminObject.name,
      'accounttoaddlevel1': newLevel1TextFieldController.text,
      'accounttoaddlevel2': newLevel2TextFieldController.text,
      'accounttoaddlevel3': newLevel3TextFieldController.text,
      'accounttoaddlevel1comment':
          newAccountLevel1CommentTextFieldController.text,
      'accounttoaddlevel2comment':
          newAccountLevel2CommentTextFieldController.text,
      'accounttoaddlevel3comment':
          newAccountLevel3CommentTextFieldController.text,
      'accountfornewlevel2parentaccount': level1AdminObject.id
          .toString(), // ID of the selected level2 object, to match the parentID
      'accountfornewlevel3parentaccount': level2AdminObject.id
          .toString(), // ID of the selected level2 object, to match the parentID - not needed for level1 as level1s have no parent
      'status': 'IP',
      'user': '1',
      'group': '-1',
      'company': '-1',
    };

    print(url);
    print(body);

    var response = await http.post(url, body: body);

    showCustomDialog(
        _currentIndex, response.statusCode == 500 ? 'error' : 'success');
    print(response.statusCode);

    /*
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
    );*/
  }

  arrangeAccounts(int level, String type) async {
    // Refresh accounts lists, needed because the accounts are cleared from account list and when another level1 or 2 are selected the list only has the level2 and 3 accounts from the other level1 or 2

    await checkForChanges(false, true,
        type); // This await waits for all accounts to be loaded before continung

    if (level == 1) {
      if (type == 'actual') {
        // Get the first account which matches the level1 account or the default hardcoded account - all can not be deleted as the dropdown must not be empty
        level2ActualObject = level2ActualAccountsList.firstWhere(
            (account) => account.parentAccount == level1ActualObject.id,
            orElse: () => level2ActualAccountsList[0]);

        // Remove all accounts which do not match the parent account but the default hardcoded account - all can not be deleted as the dropdown must not be empty
        level2ActualAccountsList.retainWhere((account) =>
            account.parentAccount == level1ActualObject.id || account.id < 0);

        // Remove all accounts also from normal accounts list, as the check if the items are still in the list is done on this list soit has to contain the same items as the other lists
        level2AccountsList.retainWhere((account) =>
            account.parentAccount == level1ActualObject.id || account.id < 0);

        // Same as above for level3
        level3ActualObject = level3ActualAccountsList.firstWhere(
            (account) => account.parentAccount == level2ActualObject.id,
            orElse: () => level3ActualAccountsList[0]);

        level3ActualAccountsList.retainWhere((account) =>
            account.parentAccount == level2ActualObject.id || account.id < 0);
        // Remove all accounts also from normal accounts list, as the check if the items are still in the list is done on this list soit has to contain the same items as the other lists
        level3AccountsList.retainWhere((account) =>
            account.parentAccount == level2ActualObject.id || account.id < 0);
      } else if (type == 'budget') {
        level2BudgetObject = level2BudgetAccountsList.firstWhere(
            (account) => account.parentAccount == level1BudgetObject.id,
            orElse: () => level2BudgetAccountsList[0]);

        // Remove all accounts which do not match the parent account but the default hardcoded account - all can not be deleted as the dropdown must not be empty
        level2BudgetAccountsList.retainWhere((account) =>
            account.parentAccount == level1BudgetObject.id || account.id < 0);

        // Remove all accounts also from normal accounts list, as the check if the items are still in the list is done on this list soit has to contain the same items as the other lists
        level2AccountsList.retainWhere((account) =>
            account.parentAccount == level1BudgetObject.id || account.id < 0);

        // Same as above for level3
        level3BudgetObject = level3BudgetAccountsList.firstWhere(
            (account) => account.parentAccount == level2BudgetObject.id,
            orElse: () => level3BudgetAccountsList[0]);

        level3BudgetAccountsList.retainWhere((account) =>
            account.parentAccount == level2BudgetObject.id || account.id < 0);

        // Remove all accounts also from normal accounts list, as the check if the items are still in the list is done on this list soit has to contain the same items as the other lists
        level3AccountsList.retainWhere((account) =>
            account.parentAccount == level1BudgetObject.id || account.id < 0);
      } else if (type == 'admin') {
        // For the admin, don't auto set the first matching parent account, as this might be confusing when I want to add a new account
        level2AdminObject = level2AdminAccountsList[0];

        // Remove all accounts which do not match the parent account but the default hardcoded account - all can not be deleted as the dropdown must not be empty
        level2AdminAccountsList.retainWhere((account) =>
            account.parentAccount == level1AdminObject.id || account.id < 0);

        // Remove all accounts also from normal accounts list, as the check if the items are still in the list is done on this list soit has to contain the same items as the other lists
        level2AccountsList.retainWhere((account) =>
            account.parentAccount == level1AdminObject.id || account.id < 0);

        // Same as above for level3
        level3AdminObject = level3AdminAccountsList.firstWhere(
            (account) => account.parentAccount == level2AdminObject.id,
            orElse: () => level3AdminAccountsList[0]);

        level3AdminAccountsList.retainWhere((account) =>
            account.parentAccount == level2AdminObject.id || account.id < 0);

        // Remove all accounts also from normal accounts list, as the check if the items are still in the list is done on this list soit has to contain the same items as the other lists
        level3AccountsList.retainWhere((account) =>
            account.parentAccount == level2AdminObject.id || account.id < 0);
      }
    } else if (level == 2) {
      if (type == 'actual') {
        // Get the first account which matches the level1 account or the default hardcoded account - all can not be deleted as the dropdown must not be empty
        level3ActualObject = level3ActualAccountsList.firstWhere(
            (account) => account.parentAccount == level2ActualObject.id,
            orElse: () => level3ActualAccountsList[0]);

        // Remove all accounts which do not match the parent account but the default hardcoded account - all can not be deleted as the dropdown must not be empty
        level3ActualAccountsList.retainWhere((account) =>
            account.parentAccount == level2ActualObject.id || account.id < 0);

        // Remove all accounts also from normal accounts list, as the check if the items are still in the list is done on this list soit has to contain the same items as the other lists
        level3AccountsList.retainWhere((account) =>
            account.parentAccount == level2ActualObject.id || account.id < 0);
      } else if (type == 'budget') {
        // Get the first account which matches the level1 account or the default hardcoded account - all can not be deleted as the dropdown must not be empty
        level3BudgetObject = level3BudgetAccountsList.firstWhere(
            (account) => account.parentAccount == level2BudgetObject.id,
            orElse: () => level3BudgetAccountsList[0]);
        // Remove all accounts which do not match the parent account but the default hardcoded account - all can not be deleted as the dropdown must not be empty
        // Remove all accounts which do not match the parent account but the default hardcoded account - all can not be deleted as the dropdown must not be empty
        level3BudgetAccountsList.retainWhere((account) =>
            account.parentAccount == level2BudgetObject.id || account.id < 0);

        // Remove all accounts also from normal accounts list, as the check if the items are still in the list is done on this list soit has to contain the same items as the other lists
        level3AccountsList.retainWhere((account) =>
            account.parentAccount == level1BudgetObject.id || account.id < 0);
      } else if (type == 'admin') {
        // For the admin, don't auto set the first matching parent account, as this might be confusing when I want to add a new account
        level3AdminObject = level3AdminAccountsList[0];

        // Remove all accounts which do not match the parent account but the default hardcoded account - all can not be deleted as the dropdown must not be empty
        level3AdminAccountsList.retainWhere((account) =>
            account.parentAccount == level2AdminObject.id || account.id < 0);

        // Remove all accounts also from normal accounts list, as the check if the items are still in the list is done on this list soit has to contain the same items as the other lists
        level3AccountsList.retainWhere((account) =>
            account.parentAccount == level2AdminObject.id || account.id < 0);
      }
    }

    // Not sure if this needs to be done for all or if this is just a workaround and needs to be called once for all values
    setState(() {
      level2ActualObject = level2ActualObject;
    });
  }

  /// Display date picker.
  void _showDatePicker(String type, DateTime actualOrBudgetOrVisualizer) {
    DatePicker.showDatePicker(
      context,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
        confirm: Text('Save', style: TextStyle(color: Color(0xff0957FF))),
        cancel: Text('Cancel', style: TextStyle(color: Colors.grey)),
      ),
      minDateTime: DateTime.parse(MIN_DATETIME),
      maxDateTime: DateTime.parse(MAX_DATETIME),
      initialDateTime: actualOrBudgetOrVisualizer,
      onClose: () => print("----- onClose $type -----"),
      onCancel: () => print('onCancel'),
      dateFormat: _format,
      onChange: (dateTime, List<int> index) {
        setState(() {
          if (type == 'actual') {
            dateTimeActual = dateTime;
          } else if (type == 'budget') {
            dateTimeBudget = dateTime;
          } else if (type == 'visualizer') {
            dateTimeVisualizer = dateTime;
          }
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          if (type == 'actual') {
            dateTimeActual = dateTime;
          } else if (type == 'budget') {
            dateTimeBudget = dateTime;
          } else if (type == 'visualizer') {
            dateTimeVisualizer = dateTime;
          }
        });
      },
    );
  }

  commentInput(
      BuildContext context,
      String type,
      TextEditingController dependingController,
      TextEditingController dependingController2,
      TextEditingController dependingController3) async {
    // cache the name of the entered level1 or costtype to display it in the title of the comment dialog
    var level1OrCostTypeName = dependingController.text;

    if (type == 'costtype') {
      dependingController = newCostTypeCommentTextFieldController;
    } else if (type == 'account') {
      dependingController = newAccountLevel1CommentTextFieldController;
    }

    print("1 " +
        (type == 'costtype').toString() +
        " - " +
        (dependingController.text.length > 0).toString());

    // When a costType is added or a new level1 was entered, if no level1 is entered it might still be the case the a new level2 was entered with a linked level1 account
    if (type == 'costtype' || newLevel1TextFieldController.text.length > 0) {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              //Enter a comment for '
              title: Center(
                child: RichText(
                  text: TextSpan(
                      text: 'Enter a comment for ',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      children: <TextSpan>[
                        TextSpan(
                          text: '$level1OrCostTypeName',
                          style:
                              TextStyle(color: Color(0xFF0957FF), fontSize: 18),
                        )
                      ]),
                ),
              ),
              content: TextField(
                controller: dependingController,
                decoration: InputDecoration(hintText: "comment"),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('CANCEL'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  child: new Text('SAVE'),
                  onPressed: () {
                    if (type != 'account') {
                      sendBackend('new${type}add');
                    } else if (dependingController2.text.length <= 0) {
                      sendBackend('new${type}add');
                    }

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }

    if (dependingController2 != null && dependingController2.text.length > 0) {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Center(
                child: RichText(
                  text: TextSpan(
                      text: 'Enter a comment for ',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${dependingController2.text}',
                          style:
                              TextStyle(color: Color(0xff73D700), fontSize: 18),
                        )
                      ]),
                ),
              ),
              content: TextField(
                controller: newAccountLevel2CommentTextFieldController,
                decoration: InputDecoration(hintText: "comment"),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('CANCEL'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  child: new Text('SAVE'),
                  onPressed: () {
                    // Send directly to backend if no additional level3 was entered which has to be saved in the Backend -> DB
                    if (dependingController3.text.length <= 0) {
                      sendBackend('new${type}add');
                    }

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }

    if (dependingController3 != null && dependingController3.text.length > 0) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Center(
                child: RichText(
                  text: TextSpan(
                      text: 'Enter a comment for ',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${dependingController3.text}',
                          style:
                              TextStyle(color: Color(0xffDB002A), fontSize: 18),
                        )
                      ]),
                ),
              ),
              content: TextField(
                controller: newAccountLevel3CommentTextFieldController,
                decoration: InputDecoration(hintText: "comment"),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('CANCEL'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  child: new Text('SAVE'),
                  onPressed: () {
                    sendBackend('new${type}add');

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  showCustomDialog(int index, String page) {
    Icon icon = Icon(Icons.device_unknown, size: 70);
    Color color = Colors.yellow;

    if (page == 'help') {
      icon = Icon(Icons.help, size: 70);
      color = Color(0xff0957FF);
    } else if (page == 'success') {
      icon = Icon(Icons.thumb_up, size: 70);
      color = Colors.green;
    } else if (page == 'error') {
      icon = Icon(Icons.thumb_down, size: 70);
      color = Colors.red;
    }

    showDialog(
        context: context,
        barrierDismissible: true, // set to false if you want to force a rating
        builder: (context) {
          return RatingDialog(
            icon: icon, // set your own image/icon widget
            title: "The Rating Dialog",
            description:
                "Tap a star to set your rating. Add more description here if you want.",
            submitButton: "SUBMIT",
            alternativeButton: "Contact us instead?", // optional
            positiveComment: "We are so happy to hear :)", // optional
            negativeComment: "We're sad to hear :(", // optional
            accentColor: color, // optional
            onSubmitPressed: (int rating) {
              print("onSubmitPressed: rating = $rating");
              // TODO: open the app's page on Google Play / Apple App Store
            },
            onAlternativePressed: () {
              print("onAlternativePressed: do something");
              // TODO: maybe you want the user to contact you instead of rating a bad review
            },
          );
        });
  }


  _onSelectionChanged(charts.SelectionModel model)
  {
    final selectedDatum = model.selectedDatum;
    final selectedDatum2 = model.selectedSeries;

    if (selectedDatum.isNotEmpty) {
      //time = selectedDatum.first.datum.toString();
      selectedDatum.forEach((charts.SeriesDatum datumPair) {
        print(datumPair.datum.numberOfCompanies);
        print(datumPair.datum.companySize);
        print(datumPair.datum.accountId);
      });
    }

    print(selectedDatum.first.datum.toString());
  }


  @override
  Widget build(BuildContext context) {
    final children =  Scaffold(
      appBar: AppBar(
        title: appBarTitleText,
        actions: <Widget>[
          // action button
          IconButton(
              icon: Icon(Icons.refresh),
              color: Color(0xffEEEEEE),
              iconSize: 24,
              onPressed: () {
                if (_currentIndex == 0) {
                  //print("REFRESHING ${homescreenData[0].amount} and ${homescreenData[1].amount}");
                  loadHomescreen();
                } else if (_currentIndex == 1) {
                  checkForChanges(false, true, 'actual');
                } else if (_currentIndex == 2) {
                  checkForChanges(false, true, 'budget');
                } else if (_currentIndex == 3) {
                  print("REFRESHING ${visualizerData[0].companySize}");
                  loadAmount();
                }
              })
        ],
        leading: IconButton(
            icon: Icon(Icons.help),
            color: Color(0xffEEEEEE),
            iconSize: 24,
            onPressed: () {
              showCustomDialog(_currentIndex, 'help');
            }),
      ),
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            // Check if something in the settings has been changed, if yes set the vars and widgets accordingly
            if (index == 1 || index == 2) {
              /// #46 fetched both accounts for actual and budget
              if (fetchAccountsAndCostTypes) {
                checkForChanges(false, fetchAccountsAndCostTypes, 'actual');
                checkForChanges(false, true, 'budget');
              } else {
                if (index == 1) {
                  checkForChanges(false, fetchAccountsAndCostTypes, 'actual');
                } else if (index == 2) {
                  checkForChanges(false, fetchAccountsAndCostTypes, 'budget');
                }
              }
            }
            /*
            else if(index == 3)
            {
              loadAmount();
            }
            */

            setState(() => _currentIndex = index);

            switch (index) {
              case 0:
                {
                  appBarTitleText = Text('FFD - Home');
                  break;
                }
              case 1:
                {
                  appBarTitleText = Text('FFD - Actual');
                  break;
                }
              case 2:
                {
                  appBarTitleText = Text('FFD - Budget');
                  break;
                }
              case 3:
                {
                  appBarTitleText = Text('FFD - Visualizer');
                  break;
                }
              case 4:
                {
                  appBarTitleText = Text('FFD - Settings');
                  break;
                }
            }
          },
          children: <Widget>[
            CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    color: Color(0xfff9f9f9),
                    //color: Color(0xffffffff),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
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
                                      ListTile(
                                        leading: Icon(Icons.album, size: 70),
                                        title: Text('Actual',
                                            style:
                                                TextStyle(color: Colors.white)),
                                        subtitle: Text(homescreenData[0].amount.toString(),
                                            style:
                                                TextStyle(color: Colors.white)),
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
                                      ListTile(
                                        leading: Icon(Icons.album, size: 70),
                                        title: Text('Budget',
                                            style:
                                                TextStyle(color: Colors.white)),
                                        subtitle: Text(homescreenData[1].amount.toString() + '\n' + homescreenData[2].amount.toString(),
                                            style:
                                                TextStyle(color: Colors.white)),
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
                          ),
                          // TODO make with variable, just a test for #25
                          true == true
                              ? Container(
                                  margin: const EdgeInsets.all(10.0),
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height * .4,
                                  child: charts.PieChart(
                                    [
                                      charts.Series<homescreenPie, String>(
                                          id: 'CompanySizeVsNumberOfCompanies',
                                          domainFn:
                                              (homescreenPie dataPoint, _) =>
                                                  dataPoint.type,
                                          labelAccessorFn:
                                              (homescreenPie row, _) =>
                                                  '${row.type}\n${row.amount}',
                                          measureFn:
                                              (homescreenPie dataPoint, _) =>
                                                  dataPoint.amount,
                                          data: homescreenData.sublist(0, 2) /*Only first 2 elements not also the overall budget*/)
                                    ],
                                    defaultRenderer:
                                        new charts.ArcRendererConfig(
                                      arcRendererDecorators: [
                                        new charts.ArcLabelDecorator(
                                            //labelPadding:-25,
                                            labelPosition: charts
                                                .ArcLabelPosition.outside),
                                      ],
                                      arcWidth: 50,
                                    ),
                                    animate: true,
                                    behaviors: [
                                      charts.ChartTitle('Actual vs Budget'),
                                    ],
                                  ),
                                )
                              : new Container()
                        ]),
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
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Select the month',
                              style: TextStyle(fontSize: 15),
                            ),
                            FloatingActionButton(
                              onPressed: () =>
                                  _showDatePicker('actual', dateTimeActual),
                              tooltip:
                                  'Select a different date where the booking should be added in',
                              child: Icon(Icons.date_range),
                              backgroundColor: Color(0xff0957FF),
                            ),
                            Text(
                                'Choosen: ${dateTimeActual.year.toString()}-${dateTimeActual.month.toString().padLeft(2, '0')}'),
                          ]),
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
                          //autofocus: true,
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
                          items:
                              level1ActualAccountsList.map((Account account) {
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
                            dummyAccount = level2ActualObject;

                            setState(() {
                              level2ActualObject = newValue;
                            });

                            if (dummyAccount.id != newValue.id) {
                              arrangeAccounts(2, 'actual');
                            } else {
                              print("RESELECTED");
                            }
                          },
                          items:
                              level2ActualAccountsList.map((Account account) {
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

                            // TODO probably not needed as change in level3 has no affect in anything
                            // arrangeAccounts(3, 'actual');
                          },
                          items:
                              level3ActualAccountsList.map((Account account) {
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

                                setState(() {
                                  level1ActualObject =
                                      level1ActualAccountsList[0];
                                  level2ActualObject =
                                      level2ActualAccountsList[0];
                                  level3ActualObject =
                                      level3ActualAccountsList[0];

                                  costTypeObjectActual = costTypesList[0];
                                });
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
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Select the month',
                              style: TextStyle(fontSize: 15),
                            ),
                            FloatingActionButton(
                              onPressed: () =>
                                  _showDatePicker('budget', dateTimeBudget),
                              tooltip:
                                  'Select a different date where the booking should be added in',
                              child: Icon(Icons.date_range),
                              backgroundColor: Color(0xff0957FF),
                            ),
                            Text(
                                'Choosen: ${dateTimeBudget.year.toString()}-${dateTimeBudget.month.toString().padLeft(2, '0')}')
                          ]),
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
                          //autofocus: true,
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
                          items:
                              level1BudgetAccountsList.map((Account account) {
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
                          items:
                              level2BudgetAccountsList.map((Account account) {
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

                            // TODO probably not needed as change in level3 has no affect in anything
                            // arrangeAccounts(3, 'budget');
                          },
                          items:
                              level3BudgetAccountsList.map((Account account) {
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
                                setState(() {
                                  level1BudgetObject =
                                      level1BudgetAccountsList[0];
                                  level2BudgetObject =
                                      level2BudgetAccountsList[0];
                                  level3BudgetObject =
                                      level3BudgetAccountsList[0];

                                  costTypeObjectBudget = costTypesList[0];
                                });
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
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Select the month',
                        style: TextStyle(fontSize: 15),
                      ),
                      FloatingActionButton(
                        onPressed: () =>
                            _showDatePicker('visualizer', dateTimeVisualizer),
                        tooltip:
                            'Select a different date where the booking should be added in',
                        child: Icon(Icons.date_range),
                        backgroundColor: Color(0xff0957FF),
                      ),
                      Text(
                          'Choosen: ${dateTimeVisualizer.year.toString()}-${dateTimeVisualizer.month.toString().padLeft(2, '0')}'),
                    ]),
                Text(
                  'Visualizer',
                  style: TextStyle(fontSize: 30),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * .4,
                  child: charts.BarChart(
                    [
                      charts.Series<CompanySizeVsNumberOfCompanies, String>(
                          id: 'CompanySizeVsNumberOfCompanies',
                          domainFn: (CompanySizeVsNumberOfCompanies sales, _) =>
                              sales.companySize,
                          measureFn:
                              (CompanySizeVsNumberOfCompanies sales, _) =>
                                  sales.numberOfCompanies,
                          labelAccessorFn: (CompanySizeVsNumberOfCompanies
                                      sales,
                                  _) =>
                              '${sales.companySize}: € ${sales.numberOfCompanies.toString()}',
                          data: visualizerData)
                    ],
                    animate: true,
                    selectionModels: [
                      new charts.SelectionModelConfig(
                        type: charts.SelectionModelType.info,
                        changedListener: _onSelectionChanged
                      )
                    ],
                    vertical: false,
                    // Hide domain axis.
                    barRendererDecorator:
                        new charts.BarLabelDecorator<String>(),
                    // Hide domain axis.
                    domainAxis: new charts.OrdinalAxisSpec(
                        renderSpec: new charts.NoneRenderSpec()),
                    behaviors: [
                      charts.ChartTitle('Spendings per Accounts'),
                      charts.ChartTitle('Accounts',
                          behaviorPosition: charts.BehaviorPosition.start),
                      charts.ChartTitle('Amounts',
                          behaviorPosition: charts.BehaviorPosition.bottom)
                    ],
                  ),
                )

//                RaisedButton(
//                  child: Text('Simple'),
//                  onPressed: () {
//                    setState(() {
//                      chartContainer = SimpleBarChart.withSampleData();
//                    });
//                  },
//                ),
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
                          color: Color(0xff003680),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.home,
                                  color: Colors.white,
                                ),
                                Text(
                                  "General",
                                  style: TextStyle(color: Colors.white),
                                )
                              ]),
                        ),
                      ),
                      Tab(
                        child: Container(
                          alignment: Alignment.center,
                          constraints: BoxConstraints.expand(),
                          color: Color(0xff73D700),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.home,
                                  color: Colors.white,
                                ),
                                Text(
                                  "Accounts",
                                  style: TextStyle(color: Colors.white),
                                )
                              ]),
                        ),
                      ),
                      Tab(
                        child: Container(
                          alignment: Alignment.center,
                          constraints: BoxConstraints.expand(),
                          color: Color(0xffDB002A),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.home, color: Colors.white),
                                Text(
                                  "Costtypes",
                                  style: TextStyle(color: Colors.white),
                                )
                              ]),
                        ),
                      ),
                    ]),
                  ),
                  Expanded(
                    child: Container(
                      child: TabBarView(children: [
                        CustomScrollView(slivers: [
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text("Use Costtypes:",
                                            style: TextStyle(fontSize: 25)),
                                        Switch(
                                          value: true,
                                          onChanged: (value) {
                                            setState(() {
                                              areAccountsActive = value;
                                            });
                                          },
                                          activeTrackColor: Color(0xffEEEEEE),
                                          activeColor: Color(0xff0957FF),
                                        ),
                                      ]),
                                  Divider(color: Colors.black87),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text("Use Accounts:",
                                            style: TextStyle(fontSize: 25)),
                                        Switch(
                                          value: true,
                                          onChanged: (value) {
                                            setState(() {
                                              areAccountsActive = value;
                                            });
                                          },
                                          activeTrackColor: Color(0xffEEEEEE),
                                          activeColor: Color(0xff0957FF),
                                        ),
                                      ]),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text("Use Level 1:",
                                            style: TextStyle(fontSize: 25)),
                                        Switch(
                                          value: true,
                                          onChanged: (value) {
                                            setState(() {
                                              areAccountsActive = value;
                                            });
                                          },
                                          activeTrackColor: Color(0xffEEEEEE),
                                          activeColor: Color(0xff0957FF),
                                        ),
                                      ]),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text("Use Level 2:",
                                            style: TextStyle(fontSize: 25)),
                                        Switch(
                                          value: true,
                                          onChanged: (value) {
                                            setState(() {
                                              areAccountsActive = value;
                                            });
                                          },
                                          activeTrackColor: Color(0xffEEEEEE),
                                          activeColor: Color(0xff0957FF),
                                        ),
                                      ]),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text("Use Level 3:",
                                            style: TextStyle(fontSize: 25)),
                                        Switch(
                                          value: true,
                                          onChanged: (value) {
                                            setState(() {
                                              areAccountsActive = value;
                                            });
                                          },
                                          activeTrackColor: Color(0xffEEEEEE),
                                          activeColor: Color(0xff0957FF),
                                        ),
                                      ]),
                                ]),
                          ),
                        ]),
                        CustomScrollView(slivers: [
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text("Account Administration",
                                      style: TextStyle(fontSize: 25)),
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 30.0,
                                        top: 0,
                                        right: 30,
                                        bottom: 0),
                                    //color: Colors.blue[600],
                                    alignment: Alignment.center,
                                    //child: Text('Submit'),
                                    child: DropdownButton<Account>(
                                      value: level1AdminObject,
                                      hint: Text(
                                        "Select a level 1 account",
                                        /*style: TextStyle(
                              color,
                            ),*/
                                      ),
                                      icon: Icon(Icons.arrow_downward),
                                      iconSize: 24,
                                      elevation: 16,
                                      style:
                                          TextStyle(color: Color(0xff0957FF)),
                                      isExpanded: true,
                                      underline: Container(
                                        height: 2,
                                        width: 5000,
                                        color: Color(0xff0957FF),
                                      ),
                                      onChanged: (Account newValue) {
                                        setState(() {
                                          level1AdminObject = newValue;
                                        });

                                        arrangeAccounts(1, 'admin');
                                      },
                                      items: level1AdminAccountsList
                                          .map((Account account) {
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
                                    padding: const EdgeInsets.only(
                                        left: 30.0,
                                        top: 0,
                                        right: 30,
                                        bottom: 40),
                                    //color: Colors.blue[600],
                                    alignment: Alignment.center,
                                    //child: Text('Submit'),
                                    child: TextFormField(
                                      // keyboardType: TextInputType.number, //keyboard with numbers only will appear to the screen
                                      style: TextStyle(
                                          height:
                                              2), //increases the height of cursor
                                      // autofocus: true,
                                      controller: newLevel1TextFieldController,
                                      decoration: InputDecoration(
                                          hintText:
                                              'Select an existing or create a new level 1',
                                          hintStyle: TextStyle(
                                              height: 1.75,
                                              color: Color(0xff0957FF)),
                                          /*icon: Icon(
                                            Icons.attach_money,
                                            color: Color(0xff0957FF),
                                          ),*/
                                          //prefixIcon: Icon(Icons.attach_money),
                                          //labelStyle: TextStyle(color: Color(0xff0957FF)),
                                          enabledBorder:
                                              new UnderlineInputBorder(
                                                  borderSide: new BorderSide(
                                                      color:
                                                          Color(0xff0957FF)))),
                                    ),
                                  ),
                                  /*
                                  Divider(
                                    color: Colors.black,
                                  ),
                                  */
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 30.0,
                                        top: 0,
                                        right: 30,
                                        bottom: 0),
                                    //color: Colors.blue[600],
                                    alignment: Alignment.center,
                                    //child: Text('Submit'),
                                    child: DropdownButton<Account>(
                                      value: level2AdminObject,
                                      hint: Text(
                                        "Select a level 2 account",
                                        /*style: TextStyle(
                              color,
                            ),*/
                                      ),
                                      icon: Icon(Icons.arrow_downward),
                                      iconSize: 24,
                                      elevation: 16,
                                      style:
                                          TextStyle(color: Color(0xff0957FF)),
                                      isExpanded: true,
                                      underline: Container(
                                        height: 2,
                                        width: 5000,
                                        color: Color(0xff0957FF),
                                      ),
                                      onChanged: (Account newValue) {
                                        setState(() {
                                          level2AdminObject = newValue;
                                        });

                                        arrangeAccounts(2, 'admin');
                                      },
                                      items: level2AdminAccountsList
                                          .map((Account account) {
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
                                    padding: const EdgeInsets.only(
                                        left: 30.0,
                                        top: 0,
                                        right: 30,
                                        bottom: 40),
                                    //color: Colors.blue[600],
                                    alignment: Alignment.center,
                                    //child: Text('Submit'),
                                    child: TextFormField(
                                      // keyboardType: TextInputType.number, //keyboard with numbers only will appear to the screen
                                      style: TextStyle(
                                          height:
                                              2), //increases the height of cursor
                                      // autofocus: true,
                                      controller: newLevel2TextFieldController,
                                      decoration: InputDecoration(
                                          hintText:
                                              'Select an existing or create a new level 2',
                                          hintStyle: TextStyle(
                                              height: 1.75,
                                              color: Color(0xff0957FF)),
                                          /*icon: Icon(
                                            Icons.attach_money,
                                            color: Color(0xff0957FF),
                                          ),*/
                                          //prefixIcon: Icon(Icons.attach_money),
                                          //labelStyle: TextStyle(color: Color(0xff0957FF)),
                                          enabledBorder:
                                              new UnderlineInputBorder(
                                                  borderSide: new BorderSide(
                                                      color:
                                                          Color(0xff0957FF)))),
                                    ),
                                  ),
                                  /*
                                  Divider(
                                    color: Colors.black,
                                  ), */
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 30.0,
                                        top: 0,
                                        right: 30,
                                        bottom: 0),
                                    //color: Colors.blue[600],
                                    alignment: Alignment.center,
                                    //child: Text('Submit'),
                                    child: DropdownButton<Account>(
                                      value: level3AdminObject,
                                      hint: Text(
                                        "Select a level 3 account",
                                        /*style: TextStyle(
                              color,
                            ),*/
                                      ),
                                      icon: Icon(Icons.arrow_downward),
                                      iconSize: 24,
                                      elevation: 16,
                                      style:
                                          TextStyle(color: Color(0xff0957FF)),
                                      isExpanded: true,
                                      underline: Container(
                                        height: 2,
                                        width: 5000,
                                        color: Color(0xff0957FF),
                                      ),
                                      onChanged: (Account newValue) {
                                        setState(() {
                                          level3AdminObject = newValue;
                                        });

                                        // TODO probably not needed as change in level3 has no affect in anything
                                        //arrangeAccounts(3, 'admin');
                                      },
                                      items: level3AdminAccountsList
                                          .map((Account account) {
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
                                    padding: const EdgeInsets.only(
                                        left: 30.0,
                                        top: 0,
                                        right: 30,
                                        bottom: 0),
                                    //color: Colors.blue[600],
                                    alignment: Alignment.center,
                                    //child: Text('Submit'),
                                    child: TextFormField(
                                      // keyboardType: TextInputType.number, //keyboard with numbers only will appear to the screen
                                      style: TextStyle(
                                          height:
                                              2), //increases the height of cursor
                                      // autofocus: true,
                                      controller: newLevel3TextFieldController,
                                      decoration: InputDecoration(
                                          hintText:
                                              'Select an existing or create a new level 3',
                                          hintStyle: TextStyle(
                                              height: 1.75,
                                              color: Color(0xff0957FF)),
                                          /*icon: Icon(
                                            Icons.attach_money,
                                            color: Color(0xff0957FF),
                                          ),*/
                                          //prefixIcon: Icon(Icons.attach_money),
                                          //labelStyle: TextStyle(color: Color(0xff0957FF)),
                                          enabledBorder:
                                              new UnderlineInputBorder(
                                                  borderSide: new BorderSide(
                                                      color:
                                                          Color(0xff0957FF)))),
                                    ),
                                  ),
                                  ButtonBar(
                                    mainAxisSize: MainAxisSize
                                        .min, // this will take space as minimum as posible(to center)
                                    children: <Widget>[
                                      ButtonTheme(
                                        minWidth: 75.0,
                                        height: 50.0,
                                        child: RaisedButton(
                                          child: Text('Discard'),
                                          color: Color(0xffEEEEEE), // EEEEEE
                                          onPressed: () {
                                            newLevel1TextFieldController.text =
                                                '';
                                            newLevel2TextFieldController.text =
                                                '';
                                            newLevel3TextFieldController.text =
                                                '';
                                            setState(() {
                                              level1AdminObject =
                                                  level1AdminAccountsList[0];
                                              level2AdminObject =
                                                  level2AdminAccountsList[0];
                                              level3AdminObject =
                                                  level3AdminAccountsList[0];
                                            });
                                          },
                                        ),
                                      ),
                                      ButtonTheme(
                                        minWidth: 75.0,
                                        height: 50.0,
                                        child: RaisedButton(
                                          child: Text('Delete \nSelected',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                              )),
                                          color: Colors.red, //df7599 - 0957FF
                                          onPressed: () {
                                            sendBackend('newaccountdelete');

                                            if (level3AdminObject.id > 0) {
                                              // If the acount which has just been deleted was selected, unselect it
                                              if (level3ActualObject.id ==
                                                  level3AdminObject.id) {
                                                level3ActualObject =
                                                    level3ActualAccountsList[0];
                                              }

                                              if (level3BudgetObject.id ==
                                                  level3AdminObject.id) {
                                                level3BudgetObject =
                                                    level3BudgetAccountsList[0];
                                              }

                                              level3AdminObject =
                                                  level3AdminAccountsList[0];
                                            } else if (level2AdminObject.id >
                                                0) {
                                              // If the acount which has just been deleted was selected, unselect it
                                              if (level2ActualObject.id ==
                                                  level2AdminObject.id) {
                                                level2ActualObject =
                                                    level2ActualAccountsList[0];
                                              }

                                              if (level2BudgetObject.id ==
                                                  level2AdminObject.id) {
                                                level2BudgetObject =
                                                    level2BudgetAccountsList[0];
                                              }

                                              level2AdminObject =
                                                  level2AdminAccountsList[0];
                                            } else if (level1AdminObject.id >
                                                0) {
                                              // If the acount which has just been deleted was selected, unselect it
                                              if (level1ActualObject.id ==
                                                  level1AdminObject.id) {
                                                level1ActualObject =
                                                    level1ActualAccountsList[0];
                                              }

                                              if (level1BudgetObject.id ==
                                                  level1AdminObject.id) {
                                                level1BudgetObject =
                                                    level1BudgetAccountsList[0];
                                              }

                                              level1AdminObject =
                                                  level1AdminAccountsList[0];
                                            }
                                          },
                                        ),
                                      ),
                                      ButtonTheme(
                                        minWidth: 150.0,
                                        height: 70.0,
                                        child: RaisedButton(
                                          child: Text('Save',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20)),
                                          color: Color(
                                              0xff0957FF), //df7599 - 0957FF
                                          onPressed: () {
                                            commentInput(
                                                context,
                                                'account',
                                                newLevel1TextFieldController,
                                                newLevel2TextFieldController,
                                                newLevel3TextFieldController);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ]),
                          )
                        ]),
                        CustomScrollView(slivers: [
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text("Costtype Administration",
                                      style: TextStyle(fontSize: 25)),
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 30.0,
                                        top: 0,
                                        right: 30,
                                        bottom: 0),
                                    //color: Colors.blue[600],
                                    alignment: Alignment.center,
                                    //child: Text('Submit'),
                                    child: DropdownButton<CostType>(
                                      value: costTypeObjectAdmin,
                                      hint: Text(
                                        "Select a costtype to delete",
                                        /*style: TextStyle(
                              color,
                            ),*/
                                      ),
                                      icon: Icon(Icons.arrow_downward),
                                      iconSize: 24,
                                      elevation: 16,
                                      style:
                                          TextStyle(color: Color(0xff0957FF)),
                                      isExpanded: true,
                                      underline: Container(
                                        height: 2,
                                        width: 5000,
                                        color: Color(0xff0957FF),
                                      ),
                                      onChanged: (CostType newValue) {
                                        setState(() {
                                          costTypeObjectAdmin = newValue;
                                        });
                                      },
                                      items: costTypesList
                                          .map((CostType costType) {
                                        return new DropdownMenuItem<CostType>(
                                          value: costType,
                                          child: new Text(
                                            costType.name,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 30.0,
                                        top: 0,
                                        right: 30,
                                        bottom: 40),
                                    //color: Colors.blue[600],
                                    alignment: Alignment.center,
                                    //child: Text('Submit'),
                                    child: TextFormField(
                                      // keyboardType: TextInputType.number, //keyboard with numbers only will appear to the screen
                                      style: TextStyle(
                                          height:
                                              2), //increases the height of cursor
                                      // autofocus: true,
                                      controller:
                                          newCostTypeTextFieldController,
                                      decoration: InputDecoration(
                                          hintText:
                                              'Select an existing or create a new Costtype',
                                          hintStyle: TextStyle(
                                              height: 1.75,
                                              color: Color(0xff0957FF)),
                                          /*icon: Icon(
                                            Icons.attach_money,
                                            color: Color(0xff0957FF),
                                          ),*/
                                          //prefixIcon: Icon(Icons.attach_money),
                                          //labelStyle: TextStyle(color: Color(0xff0957FF)),
                                          enabledBorder:
                                              new UnderlineInputBorder(
                                                  borderSide: new BorderSide(
                                                      color:
                                                          Color(0xff0957FF)))),
                                    ),
                                  ),
                                  /*
                                  Divider(
                                    color: Colors.black,
                                  ),
                                  */

                                  ButtonBar(
                                    mainAxisSize: MainAxisSize
                                        .min, // this will take space as minimum as posible(to center)
                                    children: <Widget>[
                                      ButtonTheme(
                                        minWidth: 75.0,
                                        height: 50.0,
                                        child: RaisedButton(
                                          child: Text('Discard'),
                                          color: Color(0xffEEEEEE), // EEEEEE
                                          onPressed: () {
                                            newCostTypeTextFieldController
                                                .text = '';

                                            setState(() {
                                              costTypeObjectAdmin =
                                                  costTypesList[0];
                                            });
                                          },
                                        ),
                                      ),
                                      ButtonTheme(
                                        minWidth: 75.0,
                                        height: 50.0,
                                        child: RaisedButton(
                                          child: Text('Delete \nSelected',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                              )),
                                          color: Colors.red, //df7599 - 0957FF
                                          onPressed: () {
                                            sendBackend('newcosttypedelete');

                                            // the here selected value was deleted and therefore is no more available, so set it to the first default value to not receive an error
                                            costTypeObjectAdmin =
                                                costTypesList[0];
                                          },
                                        ),
                                      ),
                                      ButtonTheme(
                                        minWidth: 150.0,
                                        height: 70.0,
                                        child: RaisedButton(
                                          child: Text('Save',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20)),
                                          color: Color(
                                              0xff0957FF), //df7599 - 0957FF
                                          onPressed: () {
                                            commentInput(
                                                context,
                                                'costtype',
                                                newCostTypeTextFieldController,
                                                null,
                                                null);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ]),
                          )
                        ]),
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

    return children;

  }
}
