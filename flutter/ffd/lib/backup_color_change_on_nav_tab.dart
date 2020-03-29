import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:ffd/sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'login_page.dart';
import 'package:search_choices/search_choices.dart';

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
  Account(this.id, this.name, this.parentAccount, this.accountLevel);

  int id;
  String name;
  int parentAccount;
  int accountLevel = -1;

  @override
  String toString() {
    return '${name}';
  }
}

class ListItem {
  ListItem(
      this._type,
      this.id,
      this.comment,
      this.amount,
      this.date,
      this.level1,
      this.level1_fk,
      this.level2,
      this.level2_fk,
      this.level3,
      this.level3_fk,
      this.costType,
      this.active);

  String _type; // Actual or Budget
  int id; // Id of the entry in the act_data or bdg_data table
  String comment;
  double amount;
  String date;
  String level1;
  int level1_fk;
  String level2;
  int level2_fk;
  String level3;
  int level3_fk;
  String costType;
  int active;
}

class CostType {
  const CostType(this.id, this.name);

  final int id;
  final String name;

  @override
  String toString() {
    return '${name}';
  }
}

class CompanySizeVsNumberOfCompanies {
  String companySize;
  double numberOfCompanies;
  int accountId;
  int accountLevel;

  CompanySizeVsNumberOfCompanies(this.companySize, this.numberOfCompanies,
      this.accountId, this.accountLevel);
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
  CostType costTypeObjectVisualizer;

  // Items sent to backend to delete the entry in the DB
  ListItem actObjectToDelete = new ListItem('actual', -1, null, null, null,
      null, null, null, null, null, null, null, null);
  ListItem bdgObjectToDelete = new ListItem('actual', -1, null, null, null,
      null, null, null, null, null, null, null, null);

  double rating = 0;
  // when a same level2 is selected as is already selected the accounts are multiplicated, this dummyobject checks if the new selected account is the same as the old one
  Account dummyAccount;

  // Parent_account for visualizer page which is -1 when initializing and changed when clicked on a bar - has to be initialized with 1 as account level
  Account g_parent_account =
      new Account(-69, 'DUMMY G_PARENT_ACCOUNT_FOR_VISUALISATION', null, 1);

  // Text which shows the drilldown level
  String drilldownLevel = "";

  // Json objects which are fetched from API
  var level1AccountsJson;
  var level2AccountsJson;
  var level3AccountsJson;
  var costTypesJson;

  // List has to be filled with 1 default account so that we don't get a null error on startup - Lists with all values for dropdown
  List<Account> level1AccountsList = <Account>[
    Account(-99, 'UNDEFINED', null, null),
  ];
  List<Account> level1ActualAccountsList = <Account>[
    Account(-99, 'UNDEFINED', null, null),
  ];
  List<Account> level1BudgetAccountsList = <Account>[
    Account(-99, 'UNDEFINED', null, null),
  ];
  List<Account> level1AdminAccountsList = <Account>[
    Account(-99, 'UNDEFINED', null, null),
  ];

  List<Account> level2AccountsList = <Account>[
    Account(-100, 'UNDEFINED', null, null)
  ];
  List<Account> level2ActualAccountsList = <Account>[
    Account(-100, 'UNDEFINED', null, null)
  ];
  List<Account> level2BudgetAccountsList = <Account>[
    Account(-100, 'UNDEFINED', null, null)
  ];
  List<Account> level2AdminAccountsList = <Account>[
    Account(-100, 'UNDEFINED', null, null)
  ];

  List<Account> level3AccountsList = <Account>[
    Account(-101, 'UNDEFINED', null, null)
  ];
  List<Account> level3ActualAccountsList = <Account>[
    Account(-101, 'UNDEFINED', null, null)
  ];
  List<Account> level3BudgetAccountsList = <Account>[
    Account(-101, 'UNDEFINED', null, null)
  ];
  List<Account> level3AdminAccountsList = <Account>[
    Account(-101, 'UNDEFINED', null, null)
  ];

  List<CostType> costTypesList = <CostType>[const CostType(-99, 'UNDEFINED')];

  final actualTextFieldController = TextEditingController();
  final budgetTextFieldController = TextEditingController();

  // Datetime object for selecting the date when the actual/ budget should be saved
  DateTime dateTimeHome;
  DateTime dateTimeActual;
  DateTime dateTimeBudget;
  DateTime dateTimeVisualizer;

  var visualizerData = [
    CompanySizeVsNumberOfCompanies("1-25", 10, -69, -69),
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

  // Boolean for visualizer whether it should be shown per month or the full year
  bool showFullYearHome = false;
  bool showFullYear = false;
  bool showAllTimeHome = false;
  bool showAllTime = false;

  // Controllers used which store the value of the new accounts/ CostTypes added
  final newLevel1TextFieldController = TextEditingController();
  final newLevel2TextFieldController = TextEditingController();
  final newLevel3TextFieldController = TextEditingController();
  final newAccountLevel1CommentTextFieldController = TextEditingController();
  final newAccountLevel2CommentTextFieldController = TextEditingController();
  final newAccountLevel3CommentTextFieldController = TextEditingController();
  final newCostTypeTextFieldController = TextEditingController();
  final newCostTypeCommentTextFieldController = TextEditingController();
  final actualCommentTextFieldController = TextEditingController();
  final budgetCommentTextFieldController = TextEditingController();

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
    costTypeObjectVisualizer = costTypesList[0];

    dateTimeHome = DateTime.parse(INIT_DATETIME);
    dateTimeActual = DateTime.parse(INIT_DATETIME);
    dateTimeBudget = DateTime.parse(INIT_DATETIME);
    dateTimeVisualizer = DateTime.parse(INIT_DATETIME);

    welcomeDialog();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    // Resolves the issue that no data is available on login
    await getToken();
    await syncUserInBackend();

    checkForChanges(true, fetchAccountsAndCostTypes, 'all');

    // Keep loadHomescreen before loadAmount, because if not the state will be set 2 times and it will look strange
    loadHomescreen();
    loadAmount();

    loadList('actual');
    loadList('budget');

    // Await is needed here because else the sendBackend for generalAdmin will always overwrite the preferences with the default values defined in the code here
    await loadPreferences();
    // initialize if no preferences are present yet
    sendBackend('generaladmin', true);

    setState(() {});
  }

  // Lists that hold the items in the adjust list
  final List<ListItem> actList = <ListItem>[];
  final List<ListItem> bdgList = <ListItem>[];

  welcomeDialog() async {
    var randomFact =
        await http.read('https://uselessfacts.jsph.pl/random.json?language=en');
    var parsedFact = json.decode(randomFact);

    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        content: new Text(
            'Welcome, good to see you here \n\nAre you up for a fact? did you know that: \n\n${parsedFact['text']}'),
        actions: <Widget>[
          new FlatButton(
            child: new Text('DISMISS'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  syncUserInBackend() async {
    String uri = 'http://192.168.0.21:5000/api/ffd/user/';

    print(uri);

    var params = {
      "accesstoken": token,
    };

    var user = await http.read(uri, headers: params);

    print(user);
  }

  loadList(String type) async {
    String uri = 'http://192.168.0.21:5000/api/ffd/list/?_type=$type';

    print(uri);

    var params = {
      "accesstoken": token,
    };

    try {
      var amounts = await http.read(uri, headers: params);

      var parsedAmounts = json.decode(amounts);

      if (type == 'actual') {
        actList.clear();
      } else if (type == 'budget') {
        bdgList.clear();
      }

      for (var amount in parsedAmounts) {
        if (type == 'actual') {
          actList.add(new ListItem(
              'actual',
              amount['id'],
              amount['comment'],
              amount['amount'],
              amount['data_date'],
              amount['level1'],
              amount['level1_fk'],
              amount['level2'],
              amount['level2_fk'],
              amount['level3'],
              amount['level3_fk'],
              amount['costtype'],
              amount['active']));
        } else if (type == 'budget') {
          bdgList.add(new ListItem(
              'budget',
              amount['id'],
              amount['comment'],
              amount['amount'],
              amount['data_date'],
              amount['level1'],
              amount['level1_fk'],
              amount['level2'],
              amount['level2_fk'],
              amount['level3'],
              amount['level3_fk'],
              amount['costtype'],
              amount['active']));
        }
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          content: new Text("ERROR - $e"),
          actions: <Widget>[
            new FlatButton(
              child: new Text('DISMISS'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
    }
    ;

    setState(() {});
  }

  loadAmount() async {
    int level_type = g_parent_account.accountLevel;
    int cost_type = costTypeObjectVisualizer.id;
    int parent_account = g_parent_account.id;
    int year = showAllTime ? -1 : dateTimeVisualizer.year;
    int month = showFullYear || showAllTime
        ? -1
        : dateTimeVisualizer
            .month; //if the whole year or all time should be shown, use no month filter
    String _type = 'actual';

    String uri =
        'http://192.168.0.21:5000/api/ffd/amounts/?level_type=$level_type&cost_type=$cost_type&parent_account=$parent_account&year=$year&month=$month&_type=$_type';

    print(uri);

    var params = {
      "accesstoken": token,
    };

    var amounts = await http.read(uri, headers: params);

    var parsedAmounts = json.decode(amounts);

    final desktopSalesData = [new OrdinalSales('2069', 5)];

    visualizerData.clear();

    for (var amounts in parsedAmounts) {
      visualizerData.add(CompanySizeVsNumberOfCompanies(
          amounts['level$level_type'].toString(),
          amounts['sum'],
          amounts['level${level_type.toString()}_fk'],
          level_type));
    }

    final desktopTargetLineData = [
      new OrdinalSales('2014', 25),
      new OrdinalSales('2015', 60),
      new OrdinalSales('2016', 100),
      new OrdinalSales('2017', 110),
    ];

    setState(() {});
  }

  loadPreferences() async {
    String uri = 'http://192.168.0.21:5000/api/ffd/preferences';

    print(uri);

    var params = {
      "accesstoken": token,
    };

    var preferences = await http.read(uri, headers: params);

    var parsedPreferences = json.decode(preferences);

    setState(() {
      for (var preference in parsedPreferences) {
        areCostTypesActive = preference['costtypes_active'];
        areAccountsActive = preference['accounts_active'];
        areLevel1AccountsActive = preference['accountslevel1_active'];
        areLevel2AccountsActive = preference['accountslevel2_active'];
        areLevel3AccountsActive = preference['accountslevel3_active'];
      }
    });
  }

  loadHomescreen() async {
    int level_type = -1;
    int cost_type = -1;
    int parent_account = -1;
    int year = dateTimeHome.year;
    int month = showFullYearHome ? -1 : dateTimeHome.month;
    String _type = 'actual';

    print("$year - $month");

    var params = {
      "accesstoken": token,
    };

    //var amounts = await http.read('http://192.168.0.21:5000/api/ffd/amounts/?level_type=1&cost_type=-1&parent_account=-1&year=2020&month=1&_type=actual');
    var actual = await http.read(
        'http://192.168.0.21:5000/api/ffd/amounts/?level_type=$level_type&cost_type=$cost_type&parent_account=$parent_account&year=$year&month=$month&_type=$_type',
        headers: params);

    _type = 'budget';

    var budget = await http.read(
        'http://192.168.0.21:5000/api/ffd/amounts/?level_type=$level_type&cost_type=$cost_type&parent_account=$parent_account&year=$year&month=$month&_type=$_type',
        headers: params);

    var parsedActual = json.decode(actual);
    var parsedBudget = json.decode(budget);

    //homescreenData.clear();

    homescreenData[0].amount =
        parsedActual.length != 0 ? parsedActual[0]['sum'] : 0;
    homescreenData[0].type = parsedActual.length != 0
        ? 'Actual'
        : "No Data found \nfor $year - $month";

    homescreenData[1].amount = parsedBudget.length != 0
        ? parsedBudget[0]['sum'] - homescreenData[0].amount
        : 99;
    homescreenData[1].type = parsedBudget.length != 0
        ? 'Budget'
        : "No Data found \nfor $year - $month";

    homescreenData[2].amount =
        parsedBudget.length != 0 ? parsedBudget[0]['sum'] : 99;
    homescreenData[2].type = parsedBudget.length != 0
        ? 'OverallBudget'
        : "No Data found \nfor $year - $month";

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
      Account(-99, 'UNDEFINED', null, null)
    ];
    List<CostType> costTypesListStating = <CostType>[
      const CostType(-99, 'UNDEFINED')
    ];

    bool remove = true;

    var params = {
      "accesstoken": token,
    };

    if (fetch || onStartup) {
      level1AccountsJson = await http
          .read('http://192.168.0.21:5000/api/ffd/accounts/1', headers: params);
      level2AccountsJson = await http
          .read('http://192.168.0.21:5000/api/ffd/accounts/2', headers: params);
      level3AccountsJson = await http
          .read('http://192.168.0.21:5000/api/ffd/accounts/3', headers: params);
      costTypesJson = await http
          .read('http://192.168.0.21:5000/api/ffd/costtypes/', headers: params);

      var parsedAccountLevel1 = json.decode(level1AccountsJson);
      var parsedAccountLevel2 = json.decode(level2AccountsJson);
      var parsedAccountLevel3 = json.decode(level3AccountsJson);
      var parsedCostTypes = json.decode(costTypesJson);

      for (var account in parsedAccountLevel1) {
        accountToAdd = new Account(account['id'], account['name'],
            account['parent_account'], account['level_type']);

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
        accountToAdd = new Account(account['id'], account['name'],
            account['parent_account'], account['level_type']);

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
        accountToAdd = new Account(account['id'], account['name'],
            account['parent_account'], account['level_type']);
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

  void sendBackend(String type, bool onStartup) async {
    var url = 'http://192.168.0.21:5000/api/ffd/';
    String _token = token;

    // Whenever with the backend is communicated its best to reload the accounts and costtpyes
    if (type.contains('add') || type.contains('delete'))
      fetchAccountsAndCostTypes = true;

    // Are here in case needed sometimes later
    var params = {
      "accesstoken": _token,
    };

    var body = {
      'type': type,
      'amount': type == 'actual'
          ? actualTextFieldController.text
          : budgetTextFieldController.text,
      'actualcomment': actualCommentTextFieldController.text,
      'budgetcomment': budgetCommentTextFieldController.text,
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
      'timezone': DateTime.now().timeZoneName,
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
      'arecosttypesactive': areCostTypesActive.toString(),
      'areaccountsactive': areAccountsActive.toString(),
      'arelevel1accountsactive': areLevel1AccountsActive.toString(),
      'arelevel2accountsactive': areLevel2AccountsActive.toString(),
      'arelevel3accountsactive': areLevel3AccountsActive.toString(),
      'actlistitemtodelete': actObjectToDelete.id.toString(),
      'bdglistitemtodelete': bdgObjectToDelete.id.toString(),
      'status': 'IP',
      'mailFrontend': email,
      'group': '-1',
      'company': '-1'
    };

    print(url);
    print(body);

    var response = await http.post(url, body: body, headers: params);

    if (!onStartup) {
      showCustomDialog(
          _currentIndex,
          response.statusCode == 200 ? 'success' : 'error',
          response.statusCode);
      print(response.statusCode);
    }

    // When an entry was deleted or restored, or a new entry was made in the input page
    if (type == 'actlistdelete' || type == 'actual') {
      loadList('actual');
    } else if (type == 'bdglistdelete' || type == 'budget') {
      loadList('budget');
    }

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
            (account) =>
                account.parentAccount == level1ActualObject.id &&
                areLevel2AccountsActive,
            orElse: () => level2ActualAccountsList[0]);

        // Remove all accounts which do not match the parent account but the default hardcoded account - all can not be deleted as the dropdown must not be empty
        level2ActualAccountsList.retainWhere((account) =>
            account.parentAccount == level1ActualObject.id || account.id < 0);

        // Remove all accounts also from normal accounts list, as the check if the items are still in the list is done on this list soit has to contain the same items as the other lists
        level2AccountsList.retainWhere((account) =>
            account.parentAccount == level1ActualObject.id || account.id < 0);

        // Same as above for level3
        level3ActualObject = level3ActualAccountsList.firstWhere(
            (account) =>
                account.parentAccount == level2ActualObject.id &&
                areLevel3AccountsActive,
            orElse: () => level3ActualAccountsList[0]);

        level3ActualAccountsList.retainWhere((account) =>
            account.parentAccount == level2ActualObject.id || account.id < 0);

        // Remove all accounts also from normal accounts list, as the check if the items are still in the list is done on this list soit has to contain the same items as the other lists
        level3AccountsList.retainWhere((account) =>
            account.parentAccount == level2ActualObject.id || account.id < 0);
      } else if (type == 'budget') {
        level2BudgetObject = level2BudgetAccountsList.firstWhere(
            (account) =>
                account.parentAccount == level1BudgetObject.id &&
                areLevel2AccountsActive,
            orElse: () => level2BudgetAccountsList[0]);

        // Remove all accounts which do not match the parent account but the default hardcoded account - all can not be deleted as the dropdown must not be empty
        level2BudgetAccountsList.retainWhere((account) =>
            account.parentAccount == level1BudgetObject.id || account.id < 0);

        // Remove all accounts also from normal accounts list, as the check if the items are still in the list is done on this list soit has to contain the same items as the other lists
        level2AccountsList.retainWhere((account) =>
            account.parentAccount == level1BudgetObject.id || account.id < 0);

        // Same as above for level3
        level3BudgetObject = level3BudgetAccountsList.firstWhere(
            (account) =>
                account.parentAccount == level2BudgetObject.id &&
                areLevel3AccountsActive,
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
            (account) =>
                account.parentAccount == level2ActualObject.id &&
                areLevel3AccountsActive,
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
            (account) =>
                account.parentAccount == level2BudgetObject.id &&
                areLevel3AccountsActive,
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

    print("${level2ActualObject.id} - ${level2ActualObject.name}");
    print("${level3ActualObject.id} - ${level3ActualObject.name}");
  }

  int value = 2;

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
        if (type == 'home') {
          dateTimeHome = dateTime;
        } else if (type == 'actual') {
          dateTimeActual = dateTime;
        } else if (type == 'budget') {
          dateTimeBudget = dateTime;
        } else if (type == 'visualizer') {
          dateTimeVisualizer = dateTime;
        }
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          if (type == 'home') {
            loadHomescreen();
            dateTimeHome = dateTime;
          } else if (type == 'actual') {
            dateTimeActual = dateTime;
          } else if (type == 'budget') {
            dateTimeBudget = dateTime;
          } else if (type == 'visualizer') {
            loadAmount();
            dateTimeVisualizer = dateTime;
          }
        });
      },
    );
  }

  _showProfile() {
    showDialog(
        context: context,
        barrierDismissible: true, // set to false if you want to force a rating
        builder: (context) {
          return RatingDialog(
            icon: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(), // Empty container, so that the iconbutton is at the right end
                      Spacer(),
                      IconButton(
                          icon: Icon(Icons.help),
                          color: Color(0xff003680),
                          iconSize: 30,
                          onPressed: () {
                            showCustomDialog(_currentIndex, 'help', -1);
                          }),
                    ],
                  ),
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      imageUrl,
                    ),
                    radius: 60,
                    backgroundColor: Colors.transparent,
                  ),
                ]), // set your own image/icon widget
            title: name,
            description: email,
            submitButton: "SUBMIT",
            alternativeButton: "Contact us instead?", // optional
            positiveComment: "We are so happy to hear :)", // optional
            negativeComment: "We're sad to hear :(", // optional
            accentColor: Color(0xff003680), // optional
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

    Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.blue[100], Colors.blue[400]],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(
                imageUrl,
              ),
              radius: 60,
              backgroundColor: Colors.transparent,
            ),
            SizedBox(height: 40),
            Text(
              'NAME',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            Text(
              name,
              style: TextStyle(
                  fontSize: 25,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'EMAIL',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            Text(
              email,
              style: TextStyle(
                  fontSize: 25,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'TOKEN',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            Text(
              token != null
                  ? token.substring(0, 20) +
                      " - " +
                      token.substring(token.length - 20, token.length)
                  : "initializing",
              style: TextStyle(
                  fontSize: 25,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            RaisedButton(
              onPressed: () {
                validateToken(token);
              },
              color: Colors.deepPurple,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Validate',
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
              ),
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
            ),
            RaisedButton(
              onPressed: () {
                signOutGoogle();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }), ModalRoute.withName('/'));
              },
              color: Colors.deepPurple,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
              ),
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
            )
          ],
        ),
      ),
    );
  }

  commentInput(
      BuildContext context,
      String type,
      TextEditingController dependingController,
      TextEditingController dependingController2,
      TextEditingController dependingController3) async {
    // cache the name of the entered level1 or costtype to display it in the title of the comment dialog
    var level1OrCostTypeName = type != 'actual' && type != 'budget'
        ? dependingController.text
        : 'your $type input';

    if (type == 'costtype') {
      dependingController = newCostTypeCommentTextFieldController;
    } else if (type == 'actual') {
      dependingController = actualCommentTextFieldController;
    } else if (type == 'budget') {
      dependingController = budgetCommentTextFieldController;
    } else if (type == 'account') {
      dependingController = newAccountLevel1CommentTextFieldController;
    }

    // When a costType is added or a new level1 was entered, if no level1 is entered it might still be the case the a new level2 was entered with a linked level1 account
    if (type == 'costtype' ||
        type == 'actual' ||
        type == 'budget' ||
        newLevel1TextFieldController.text.length > 0) {
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
                  child: new Text('SKIP'),
                  onPressed: () {
                    if (type == 'actual') {
                      sendBackend('actual', false);
                    } else if (type == 'budget') {
                      sendBackend('budget', false);
                    } else if (type != 'account') {
                      sendBackend('new${type}add', false);
                    } else if (dependingController2.text.length <= 0) {
                      sendBackend('new${type}add', false);
                    }

                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  child: new Text('SAVE'),
                  onPressed: () {
                    if (type == 'actual') {
                      sendBackend('actual', false);
                    } else if (type == 'budget') {
                      sendBackend('budget', false);
                    } else if (type != 'account') {
                      sendBackend('new${type}add', false);
                    } else if (dependingController2.text.length <= 0) {
                      sendBackend('new${type}add', false);
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
                  child: new Text('SKIP'),
                  onPressed: () {
                    // Send directly to backend if no additional level3 was entered which has to be saved in the Backend -> DB
                    if (dependingController3.text.length <= 0) {
                      sendBackend('new${type}add', false);
                    }

                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  child: new Text('SAVE'),
                  onPressed: () {
                    // Send directly to backend if no additional level3 was entered which has to be saved in the Backend -> DB
                    if (dependingController3.text.length <= 0) {
                      sendBackend('new${type}add', false);
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
                  child: new Text('SKIP'),
                  onPressed: () {
                    sendBackend('new${type}add', false);

                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  child: new Text('SAVE'),
                  onPressed: () {
                    sendBackend('new${type}add', false);

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  showCustomDialog(int index, String page, int code) {
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
            title: "Code: $code",
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

  handleRefresh(index) {
    if (_currentIndex == 0) {
      loadHomescreen();
    } else if (_currentIndex == 1) {
      // Test for #83
      setState(() {
        print("SETTING STATE");
        print(level1ActualObject.name);
        print(level2ActualObject.name);
        print(level3ActualObject.name);
      });

      checkForChanges(false, true, 'actual');
      loadList('actual');
    } else if (_currentIndex == 2) {
      checkForChanges(false, true, 'budget');
      loadList('budget');
    } else if (_currentIndex == 3) {
      //print("REFRESHING ${visualizerData[0].companySize}");
      loadAmount();
    } else if (_currentIndex == 4) {
      checkForChanges(false, true, 'admin');
      loadPreferences();
    }
  }

  onCardTapped(int position) {
    print('Card $position tapped');
  }

  _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;
    final selectedDatum2 = model.selectedSeries;

    if (selectedDatum.isNotEmpty) {
      //time = selectedDatum.first.datum.toString();
      selectedDatum.forEach((charts.SeriesDatum datumPair) {
        print(datumPair.datum.numberOfCompanies);
        print(datumPair.datum.companySize);
        print(datumPair.datum.accountId);
        print(datumPair.datum.accountLevel);

        if (datumPair.datum.accountId > 0 && datumPair.datum.accountLevel < 3) {
          g_parent_account.id = datumPair.datum.accountId;
          g_parent_account.accountLevel =
              datumPair.datum.accountLevel + 1; // we need to next higher one

          drilldownLevel += drilldownLevel.length > 0
              ? " > " + datumPair.datum.companySize
              : datumPair.datum.companySize;
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                title: new Text("No further drilldown possible"),
                content: new Text(datumPair.datum.accountLevel >= 3
                    ? "No drilldown deeper than level3 allowed"
                    : "No deeper level available"), // No drilldown possible as there is no deeper level available
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
        }
      });
    }

    setState(() {
      loadAmount();
    });
  }

  final RefreshController _refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    final children = Scaffold(
      appBar: AppBar(
        title: appBarTitleText,
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.exit_to_app),
            color: Color(0xffEEEEEE),
            iconSize: 24,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => new AlertDialog(
                  title: Text("Are you sure?"),
                  content: new Text('Confirm Logout'),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    new FlatButton(
                      child: new Text('Confirm'),
                      onPressed: () {
                        signOutGoogle();
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) {
                          return LoginPage();
                        }), ModalRoute.withName('/'));
                      },
                    )
                  ],
                ),
              );
            },
          ),
          // TODO REMOVE IconButton after validation of #90
          /*
          IconButton(
              icon: Icon(Icons.refresh),
              color: Color(0xffEEEEEE),
              iconSize: 24,
              onPressed: () {
                handleRefresh(_currentIndex);
          })
          */
        ],
        leading: IconButton(
            icon: Icon(Icons.account_circle),
            color: Color(0xffEEEEEE),
            iconSize: 24,
            onPressed: () {
              print(name);
              print(email);
              print(imageUrl);
              _showProfile();
              //showCustomDialog(_currentIndex, 'help', -1);
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
                  child: SmartRefresher(
                      controller: _refreshController,
                      enablePullDown: true,
                      onRefresh: () async {
                        await handleRefresh(_currentIndex);
                        print("REFRESHING ON SCROLL");
                        // await Future.delayed(Duration(seconds: 2));
                        _refreshController.refreshCompleted();
                      },
                      child: Container(
                        color: Color(0xfff9f9f9),
                        //color: Color(0xffffffff),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      print("Actual clicked");
                                      setState(() => _currentIndex = 1);
                                      _pageController.jumpToPage(1);
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          .48,
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                        ),
                                        /*color: homescreenData[0].amount >
                                                homescreenData[2].amount
                                            ? Colors.red
                                            : Colors
                                                .green, // If Actual bigger budget -> show as red
                                         */
                                        color: Color(0xff003680),
                                        elevation: 10,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            ListTile(
                                              leading: Icon(
                                                  Icons.monetization_on,
                                                  color: Colors.white,
                                                  size: 45),
                                              title: Text('Actual',
                                                  style: TextStyle(
                                                      color:
                                                          Color(0xffF5F5F6))),
                                              subtitle: Text(
                                                  homescreenData[0]
                                                      .amount
                                                      .toStringAsFixed(2),
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      print("Budget clicked");
                                      setState(() => _currentIndex = 2);
                                      _pageController.jumpToPage(2);
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          .48,
                                      decoration: BoxDecoration(
                                        borderRadius: new BorderRadius.only(
                                          topLeft: const Radius.circular(50.0),
                                          topRight: const Radius.circular(50.0),
                                          bottomLeft:
                                              const Radius.circular(50.0),
                                          bottomRight:
                                              const Radius.circular(50.0),
                                        ),
                                      ),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                        ),
                                        /*color: homescreenData[0].amount >
                                                homescreenData[2].amount
                                            ? Colors.red
                                            : Colors.green,
                                        */
                                        color: Color(0xff003680),
                                        elevation: 10,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            ListTile(
                                              leading: Icon(
                                                  Icons.account_balance_wallet,
                                                  color: Colors.white,
                                                  size: 45),
                                              title: Text('Budget',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              subtitle: Text(
                                                  // #91
                                                  /*
                                                    homescreenData[1].amount.toStringAsFixed(2) +'\n' +
                                                  */
                                                  homescreenData[2]
                                                      .amount
                                                      .toStringAsFixed(2),
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // TODO make with variable, just a test for #25
                              SizedBox(height: 30),
                              Text(
                                'Actual vs Budget',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Open Sans',
                                    fontSize: 30),
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Switch(
                                      value: showFullYearHome,
                                      onChanged: (value) {
                                        setState(() {
                                          showFullYearHome = value;
                                          loadHomescreen();
                                        });
                                      },
                                      activeTrackColor: Color(0xffEEEEEE),
                                      activeColor: Color(0xff0957FF),
                                    ),
                                    Text(
                                      'Full Year',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.w900,
                                          fontSize: 25),
                                    ),
                                  ]),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height * .4,
                                child: charts.PieChart(
                                  [
                                    charts.Series<homescreenPie, String>(
                                        id: 'CompanySizeVsNumberOfCompanies',
                                        domainFn:
                                            (homescreenPie dataPoint, _) =>
                                                dataPoint.type,
                                        labelAccessorFn: (homescreenPie row,
                                                _) =>
                                            '${row.type}\n${row.amount.toStringAsFixed(2)}€',
                                        measureFn:
                                            (homescreenPie dataPoint, _) =>
                                                dataPoint.amount,
                                        seriesColor: charts.Color.black,
                                        data: homescreenData.sublist(0,
                                            2) /*Only first 2 elements not also the overall budget*/
                                        )
                                  ],
                                  defaultRenderer: new charts.ArcRendererConfig(
                                    arcRendererDecorators: [
                                      new charts.ArcLabelDecorator(
                                          //labelPadding: 0,
                                          labelPosition:
                                              charts.ArcLabelPosition.outside),
                                    ],
                                    //strokeWidthPx: ,
                                    arcWidth: 50,
                                  ),
                                  animate: true,
                                ),
                              ),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    ButtonTheme(
                                      //minWidth: 150.0,
                                      height: 60.0,
                                      child: FlatButton(
                                        onPressed: () => _showDatePicker(
                                            'home', dateTimeHome),
                                        shape: new RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(40.0),
                                        ),
                                        color: Color(0xff003680),
                                        padding: EdgeInsets.all(10.0),
                                        child: Row(
                                          // Replace with a Row for horizontal icon + text
                                          children: <Widget>[
                                            Text(
                                                " ${dateTimeHome.year.toString()}-${dateTimeHome.month.toString().padLeft(2, '0')}",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17)),
                                            SizedBox(width: 10),
                                            Icon(
                                              Icons.calendar_today,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]),
                              SizedBox(height: 10),
                            ]),
                      )),
                ),
              ],
            ),
            DefaultTabController(
              length: 2,
              child: Column(
                children: <Widget>[
                  Container(
                    //constraints: BoxConstraints.expand(height: 50),
                    child: TabBar(indicatorColor: Color(0xff0957FF), tabs: [
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
                                  "Input",
                                  style: TextStyle(color: Colors.white),
                                )
                              ]),
                        ),
                      ),
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
                                  "Adjust",
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
                        Container(
                          child: CustomScrollView(
                            slivers: [
                              SliverFillRemaining(
                                  child: SmartRefresher(
                                controller: _refreshController,
                                enablePullDown: true,
                                onRefresh: () async {
                                  await handleRefresh(_currentIndex);
                                  print("REFRESHING ON SCROLL");
                                  //await Future.delayed(Duration(seconds: 2));
                                  _refreshController.refreshCompleted();
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          ButtonTheme(
                                            //minWidth: 150.0,
                                            height: 60.0,
                                            child: FlatButton(
                                              onPressed: () => _showDatePicker(
                                                  'actual', dateTimeActual),
                                              shape: new RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        40.0),
                                              ),
                                              color: Color(0xff003680),
                                              padding: EdgeInsets.all(10.0),
                                              child: Row(
                                                // Replace with a Row for horizontal icon + text
                                                children: <Widget>[
                                                  Text(
                                                      " ${dateTimeActual.year.toString()}-${dateTimeActual.month.toString().padLeft(2, '0')}",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 17)),
                                                  SizedBox(width: 10),
                                                  Icon(
                                                    Icons.calendar_today,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ]),
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
                                        keyboardType: TextInputType
                                            .number, //keyboard with numbers only will appear to the screen
                                        style: TextStyle(
                                            height:
                                                2), //increases the height of cursor
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
                                            enabledBorder:
                                                new UnderlineInputBorder(
                                                    borderSide: new BorderSide(
                                                        color: Color(
                                                            0xff0957FF)))),
                                      ),
                                    ),
                                    areLevel1AccountsActive
                                        ? Container(
                                            constraints: BoxConstraints.expand(
                                              height: 80,
                                              //width: MediaQuery.of(context).size.width * .8
                                            ),
                                            padding: const EdgeInsets.only(
                                                left: 30.0,
                                                top: 0,
                                                right: 30,
                                                bottom: 0),
                                            //color: Colors.blue[600],
                                            alignment: Alignment.center,
                                            //child: Text('Submit'),
                                            child: SearchChoices.single(
                                              items: level1ActualAccountsList
                                                  .map((Account account) {
                                                return new DropdownMenuItem<
                                                    Account>(
                                                  value: account,
                                                  child: new Text(
                                                    account.name,
                                                  ),
                                                );
                                              }).toList(),
                                              style: TextStyle(
                                                  color: Color(0xff0957FF)),
                                              value: level1ActualObject,
                                              underline: Container(
                                                height: 2,
                                                width: 5000,
                                                color: Color(0xff0957FF),
                                              ),
                                              hint: "Select one number",
                                              searchHint: "Select one number",
                                              onClear: () {
                                                print("CLEARING");

                                                setState(() {
                                                  level1ActualObject =
                                                      level1ActualAccountsList[
                                                          0];
                                                });
                                              },
                                              onChanged: (value) {
                                                setState(() {
                                                  level1ActualObject = value;
                                                });

                                                print(
                                                    "${level1ActualObject.id} - ${level1ActualObject.name}");

                                                arrangeAccounts(1, 'actual');

                                                print(
                                                    "${level2ActualObject.id} - ${level2ActualObject.name}");
                                              },
                                              dialogBox: true,
                                              isExpanded: true,
                                            ),
                                          )
                                        : Container(),
                                    /*areLevel1AccountsActive
                                        ? Container(
                                            constraints: BoxConstraints.expand(
                                              height: 100,
                                              //width: MediaQuery.of(context).size.width * .8
                                            ),

                                            padding: const EdgeInsets.only(
                                                left: 30.0,
                                                top: 0,
                                                right: 30,
                                                bottom: 0),
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
                                              style: TextStyle(
                                                  color: Color(0xff0957FF)),
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
                                              items: level1ActualAccountsList
                                                  .map((Account account) {
                                                return new DropdownMenuItem<
                                                    Account>(
                                                  value: account,
                                                  child: new Text(
                                                    account.name,
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          )
                                        : Container(),
                                    areLevel2AccountsActive
                                        ? Container(
                                            constraints: BoxConstraints.expand(
                                              height: 50,
                                            ),
                                            padding: const EdgeInsets.only(
                                                left: 30.0,
                                                top: 0,
                                                right: 30,
                                                bottom: 0),
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
                                              style: TextStyle(
                                                  color: Color(0xff0957FF)),
                                              isExpanded: true,
                                              underline: Container(
                                                height: 2,
                                                width: 5000,
                                                color: Color(0xff0957FF),
                                              ),
                                              onChanged: (Account newValue) {
                                                dummyAccount =
                                                    level2ActualObject;

                                                setState(() {
                                                  level2ActualObject = newValue;
                                                });

                                                if (dummyAccount.id !=
                                                    newValue.id) {
                                                  arrangeAccounts(2, 'actual');
                                                } else {
                                                  print("RESELECTED");
                                                }
                                              },
                                              items: level2ActualAccountsList
                                                  .map((Account account) {
                                                return new DropdownMenuItem<
                                                    Account>(
                                                  value: account,
                                                  child: new Text(
                                                    account.name,
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          )
                                        : Container(),*/
                                    areLevel2AccountsActive
                                        ? Container(
                                            constraints: BoxConstraints.expand(
                                              height: 80,
                                              //width: MediaQuery.of(context).size.width * .8
                                            ),
                                            padding: const EdgeInsets.only(
                                                left: 30.0,
                                                top: 0,
                                                right: 30,
                                                bottom: 0),
                                            //color: Colors.blue[600],

                                            alignment: Alignment.center,
                                            //child: Text('Submit'),
                                            child: SearchChoices.single(
                                              items: level2ActualAccountsList
                                                  .map((Account account) {
                                                return new DropdownMenuItem<
                                                    Account>(
                                                  value: account,
                                                  child: new Text(
                                                    account.name,
                                                  ),
                                                );
                                              }).toList(),
                                              style: TextStyle(
                                                  color: Color(0xff0957FF)),
                                              value: level2ActualObject,
                                              readOnly:
                                                  level1ActualObject.id <= 0 ||
                                                      level2ActualAccountsList
                                                              .length ==
                                                          1,
                                              underline: Container(
                                                height: 2,
                                                width: 5000,
                                                color: Color(0xff0957FF),
                                              ),
                                              hint: "Select one number",
                                              searchHint: "Select one number",
                                              onClear: (value) {
                                                setState(() {
                                                  level2ActualObject =
                                                      level2ActualAccountsList[
                                                          0];
                                                });
                                              },
                                              onChanged: (value) {
                                                // Check if a new value was selected or the same was reselected
                                                dummyAccount =
                                                    level2ActualObject;

                                                setState(() {
                                                  level2ActualObject = value;
                                                });

                                                if (dummyAccount.id !=
                                                    value.id) {
                                                  arrangeAccounts(2, 'actual');
                                                } else {
                                                  print("RESELECTED");
                                                }
                                              },
                                              dialogBox: true,
                                              isExpanded: true,
                                            ),
                                          )
                                        : Container(),
                                    /*areLevel3AccountsActive
                                        ? Container(
                                            constraints: BoxConstraints.expand(
                                              height: 100.0,
                                            ),
                                            padding: const EdgeInsets.only(
                                                left: 30.0,
                                                top: 0,
                                                right: 30,
                                                bottom: 0),
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
                                              style: TextStyle(
                                                  color: Color(0xff0957FF)),
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
                                              items: level3ActualAccountsList
                                                  .map((Account account) {
                                                return new DropdownMenuItem<
                                                    Account>(
                                                  value: account,
                                                  child: new Text(
                                                    account.name,
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          )
                                        : Container(),*/
                                    areLevel3AccountsActive
                                        ? Container(
                                            constraints: BoxConstraints.expand(
                                              height: 80,
                                              //width: MediaQuery.of(context).size.width * .8
                                            ),
                                            padding: const EdgeInsets.only(
                                                left: 30.0,
                                                top: 0,
                                                right: 30,
                                                bottom: 0),
                                            //color: Colors.blue[600],
                                            alignment: Alignment.center,
                                            //child: Text('Submit'),
                                            child: SearchChoices.single(
                                              items: level3ActualAccountsList
                                                  .map((Account account) {
                                                return new DropdownMenuItem<
                                                    Account>(
                                                  value: account,
                                                  child: new Text(
                                                    account.name,
                                                  ),
                                                );
                                              }).toList(),
                                              style: TextStyle(
                                                  color: Color(0xff0957FF)),
                                              value: level3ActualObject,
                                              readOnly:
                                                  level2ActualObject.id <= 0 ||
                                                      level3ActualAccountsList
                                                              .length ==
                                                          1,
                                              underline: Container(
                                                height: 2,
                                                width: 5000,
                                                color: Color(0xff0957FF),
                                              ),
                                              hint: "Select one number",
                                              searchHint: "Select one number",
                                              onClear: (value) {
                                                setState(() {
                                                  level3ActualObject =
                                                      level3ActualAccountsList[
                                                          0];
                                                });
                                              }, // The default object is set again
                                              onChanged: (value) {
                                                setState(() {
                                                  level3ActualObject = value;
                                                });

                                                // TODO probably not needed as change in level3 has no affect in anything
                                                // arrangeAccounts(3, 'actual');
                                              },
                                              dialogBox: true,
                                              isExpanded: true,
                                            ),
                                          )
                                        : Container(),
                                    // #52 when a level is deactivated the widgets have no space between
                                    // this adds a little white space between the widget
                                    areLevel3AccountsActive
                                        ? Container()
                                        : SizedBox(height: 20),
                                    areCostTypesActive
                                        ? Container(
                                            constraints: BoxConstraints.expand(
                                              height: 50.0,
                                            ),
                                            padding: const EdgeInsets.only(
                                                left: 30.0,
                                                top: 0,
                                                right: 30,
                                                bottom: 0),
                                            //color: Colors.blue[600],
                                            alignment: Alignment.center,
                                            //child: Text('Submit'),
                                            child: Align(
                                              alignment: Alignment.topRight,
                                              child: SearchChoices.single(
                                                value: costTypeObjectActual,
                                                icon:
                                                    Icon(Icons.arrow_downward),
                                                iconSize: 24,
                                                style: TextStyle(
                                                    color: Color(0xff0957FF)),
                                                underline: Container(
                                                  height: 2,
                                                  width: 2000,
                                                  color: Color(0xff0957FF),
                                                ),
                                                onChanged: (CostType newValue) {
                                                  setState(() {
                                                    costTypeObjectActual =
                                                        newValue;
                                                  });
                                                },
                                                items: costTypesList
                                                    .map((CostType type) {
                                                  return new DropdownMenuItem<
                                                      CostType>(
                                                    value: type,
                                                    child: new Text(
                                                      type.name,
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          )
                                        : Container(),
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
                                              actualTextFieldController.text =
                                                  '';

                                              setState(() {
                                                level1ActualObject =
                                                    level1ActualAccountsList[0];
                                                level2ActualObject =
                                                    level2ActualAccountsList[0];
                                                level3ActualObject =
                                                    level3ActualAccountsList[0];

                                                costTypeObjectActual =
                                                    costTypesList[0];
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
                                                    color: Colors.white,
                                                    fontSize: 17)),
                                            color: Color(
                                                0xff0957FF), //df7599 - 0957FF
                                            onPressed: () {
                                              commentInput(context, 'actual',
                                                  null, null, null);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                        SmartRefresher(
                            controller: _refreshController,
                            enablePullDown: true,
                            onRefresh: () async {
                              await handleRefresh(_currentIndex);
                              print("REFRESHING ON SCROLL");
                              //await Future.delayed(Duration(seconds: 2));
                              _refreshController.refreshCompleted();
                            },
                            child: ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: actList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                      onTap: () {
                                        print(
                                            "Item ${actList[index].id} clicked");
                                        showDialog(
                                          context: context,
                                          builder: (context) => new AlertDialog(
                                            title: Text('Comment'),
                                            content: new Text(
                                                '${actList[index].comment}'),
                                            actions: <Widget>[
                                              new FlatButton(
                                                child: new Text('DISMISS'),
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.all(15.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.blueAccent),
                                          color: actList[index].active == 1
                                              ? Color(0xffEEEEEE)
                                              : Colors.redAccent,
                                          borderRadius:
                                              new BorderRadius.circular(30.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius:
                                                  20.0, // has the effect of softening the shadow
                                              spreadRadius:
                                                  5.0, // has the effect of extending the shadow
                                              offset: Offset(
                                                10.0, // horizontal, move right 10
                                                10.0, // vertical, move down 10
                                              ),
                                            )
                                          ],
                                        ),
                                        child: Center(
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .6,
                                                //height: 300.0,
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      SizedBox(height: 15),
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  .1,
                                                              child: Icon(
                                                                Icons
                                                                    .attach_money,
                                                                color: Color(
                                                                    0xff0957FF),
                                                              ),
                                                            ),
                                                            Text(
                                                              "${actList[index].date}",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xff0957FF),
                                                                  fontSize: 25),
                                                            ),
                                                          ]),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  .1,
                                                              child:
                                                                  Container(),
                                                            ),
                                                            Text(
                                                              "${actList[index].comment}",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 15),
                                                            ),
                                                            Container(),
                                                          ]),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .1,
                                                                //height: 300.0,
                                                                child:
                                                                    Container()),
                                                            Text(
                                                              '${actList[index].level1} > ${actList[index].level2} > ${actList[index].level3} \n${actList[index].costType}',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 13),
                                                            )
                                                          ]),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                    ]),
                                              ),
                                              Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        '${actList[index].amount}'),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .1,
                                                      //height: 300.0,
                                                      child: IconButton(
                                                        icon: new Icon(
                                                          actList[index]
                                                                      .active ==
                                                                  1
                                                              ? Icons.delete
                                                              : Icons.restore,
                                                        ),
                                                        color:
                                                            Color(0xff0957FF),
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) =>
                                                                new AlertDialog(
                                                              title: Text(
                                                                  "Are you sure?"),
                                                              content: RichText(
                                                                text: TextSpan(
                                                                    text:
                                                                        'Entry from ',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold),
                                                                    children: <
                                                                        TextSpan>[
                                                                      TextSpan(
                                                                        text:
                                                                            '${actList[index].date} ',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Color(0xFF0957FF),
                                                                            fontSize: 18),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            'with an amount of ',
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            '${actList[index].amount} ',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Color(0xFF0957FF),
                                                                            fontSize: 18),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            'will be ',
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            '${actList[index].active == 1 ? "deleted" : "restored"}',
                                                                        style: TextStyle(
                                                                            color: actList[index].active == 1
                                                                                ? Colors.red
                                                                                : Colors.green,
                                                                            fontSize: 18),
                                                                      ),
                                                                    ]),
                                                              ),
                                                              actions: <Widget>[
                                                                new FlatButton(
                                                                  child: new Text(
                                                                      'Cancel'),
                                                                  onPressed: () =>
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(),
                                                                ),
                                                                new FlatButton(
                                                                  child: new Text(
                                                                      'Confirm'),
                                                                  onPressed:
                                                                      () {
                                                                    actObjectToDelete
                                                                            .id =
                                                                        actList[index]
                                                                            .id;

                                                                    sendBackend(
                                                                        'actlistdelete',
                                                                        false);
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                )
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  ]),
                                            ])),
                                      ));
                                })),
                      ]),
                    ),
                  )
                ],
              ),
            ),
            DefaultTabController(
              length: 2,
              child: Column(
                children: <Widget>[
                  Container(
                    //constraints: BoxConstraints.expand(height: 50),
                    child: TabBar(indicatorColor: Color(0xff0957FF), tabs: [
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
                                  "Input",
                                  style: TextStyle(color: Colors.white),
                                )
                              ]),
                        ),
                      ),
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
                                  "Adjust",
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
                        Container(
                          child: CustomScrollView(
                            slivers: [
                              SliverFillRemaining(
                                child: SmartRefresher(
                                    controller: _refreshController,
                                    enablePullDown: true,
                                    onRefresh: () async {
                                      await handleRefresh(_currentIndex);
                                      print("REFRESHING ON SCROLL");
                                      //await Future.delayed(Duration(seconds: 2));
                                      _refreshController.refreshCompleted();
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              ButtonTheme(
                                                //minWidth: 150.0,
                                                height: 60.0,
                                                child: FlatButton(
                                                  onPressed: () =>
                                                      _showDatePicker('budget',
                                                          dateTimeBudget),
                                                  shape:
                                                      new RoundedRectangleBorder(
                                                    borderRadius:
                                                        new BorderRadius
                                                            .circular(40.0),
                                                  ),
                                                  color: Color(0xff003680),
                                                  padding: EdgeInsets.all(10.0),
                                                  child: Row(
                                                    // Replace with a Row for horizontal icon + text
                                                    children: <Widget>[
                                                      Text(
                                                          " ${dateTimeBudget.year.toString()}-${dateTimeBudget.month.toString().padLeft(2, '0')}",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 17)),
                                                      SizedBox(width: 10),
                                                      Icon(
                                                        Icons.calendar_today,
                                                        color: Colors.white,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ]),
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
                                            keyboardType: TextInputType
                                                .number, //keyboard with numbers only will appear to the screen
                                            style: TextStyle(
                                                height:
                                                    2), //increases the height of cursor
                                            //autofocus: true,
                                            controller:
                                                budgetTextFieldController,
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
                                                enabledBorder:
                                                    new UnderlineInputBorder(
                                                        borderSide: new BorderSide(
                                                            color: Color(
                                                                0xff0957FF)))),
                                          ),
                                        ),
                                        areLevel1AccountsActive
                                            ? Container(
                                                constraints:
                                                    BoxConstraints.expand(
                                                  height: 80,
                                                  //width: MediaQuery.of(context).size.width * .8
                                                ),
                                                padding: const EdgeInsets.only(
                                                    left: 30.0,
                                                    top: 0,
                                                    right: 30,
                                                    bottom: 0),
                                                //color: Colors.blue[600],
                                                alignment: Alignment.center,
                                                //child: Text('Submit'),
                                                child: SearchChoices.single(
                                                  items:
                                                      level1BudgetAccountsList
                                                          .map((Account
                                                              account) {
                                                    return new DropdownMenuItem<
                                                        Account>(
                                                      value: account,
                                                      child: new Text(
                                                        account.name,
                                                      ),
                                                    );
                                                  }).toList(),
                                                  style: TextStyle(
                                                      color: Color(0xff0957FF)),
                                                  value: level1BudgetObject,
                                                  underline: Container(
                                                    height: 2,
                                                    width: 5000,
                                                    color: Color(0xff0957FF),
                                                  ),
                                                  hint: "Select one number",
                                                  searchHint:
                                                      "Select one number",
                                                  onClear: () {
                                                    print("CLEARING");

                                                    setState(() {
                                                      level1BudgetObject =
                                                          level1BudgetAccountsList[
                                                              0];
                                                    });
                                                  },
                                                  onChanged: (value) {
                                                    setState(() {
                                                      level1BudgetObject =
                                                          value;
                                                    });

                                                    arrangeAccounts(
                                                        1, 'budget');
                                                  },
                                                  dialogBox: true,
                                                  isExpanded: true,
                                                ),
                                              )
                                            : Container(),
                                        areLevel2AccountsActive
                                            ? Container(
                                                constraints:
                                                    BoxConstraints.expand(
                                                  height: 80,
                                                  //width: MediaQuery.of(context).size.width * .8
                                                ),
                                                padding: const EdgeInsets.only(
                                                    left: 30.0,
                                                    top: 0,
                                                    right: 30,
                                                    bottom: 0),
                                                //color: Colors.blue[600],

                                                alignment: Alignment.center,
                                                //child: Text('Submit'),
                                                child: SearchChoices.single(
                                                  items:
                                                      level2BudgetAccountsList
                                                          .map((Account
                                                              account) {
                                                    return new DropdownMenuItem<
                                                        Account>(
                                                      value: account,
                                                      child: new Text(
                                                        account.name,
                                                      ),
                                                    );
                                                  }).toList(),
                                                  style: TextStyle(
                                                      color: Color(0xff0957FF)),
                                                  value: level2BudgetObject,
                                                  readOnly: level1BudgetObject
                                                              .id <=
                                                          0 ||
                                                      level2BudgetAccountsList
                                                              .length ==
                                                          1,
                                                  underline: Container(
                                                    height: 2,
                                                    width: 5000,
                                                    color: Color(0xff0957FF),
                                                  ),
                                                  hint: "Select one number",
                                                  searchHint:
                                                      "Select one number",
                                                  onClear: (value) {
                                                    setState(() {
                                                      level2BudgetObject =
                                                          level2BudgetAccountsList[
                                                              0];
                                                    });
                                                  },
                                                  onChanged: (value) {
                                                    // Check if a new value was selected or the same was reselected
                                                    dummyAccount =
                                                        level2BudgetObject;

                                                    setState(() {
                                                      level2BudgetObject =
                                                          value;
                                                    });

                                                    if (dummyAccount.id !=
                                                        value.id) {
                                                      arrangeAccounts(
                                                          2, 'budget');
                                                    } else {
                                                      print("RESELECTED");
                                                    }
                                                  },
                                                  dialogBox: true,
                                                  isExpanded: true,
                                                ),
                                              )
                                            : Container(),
                                        areLevel3AccountsActive
                                            ? Container(
                                                constraints:
                                                    BoxConstraints.expand(
                                                  height: 80,
                                                  //width: MediaQuery.of(context).size.width * .8
                                                ),
                                                padding: const EdgeInsets.only(
                                                    left: 30.0,
                                                    top: 0,
                                                    right: 30,
                                                    bottom: 0),
                                                //color: Colors.blue[600],
                                                alignment: Alignment.center,
                                                //child: Text('Submit'),
                                                child: SearchChoices.single(
                                                  items:
                                                      level3BudgetAccountsList
                                                          .map((Account
                                                              account) {
                                                    return new DropdownMenuItem<
                                                        Account>(
                                                      value: account,
                                                      child: new Text(
                                                        account.name,
                                                      ),
                                                    );
                                                  }).toList(),
                                                  style: TextStyle(
                                                      color: Color(0xff0957FF)),
                                                  value: level3BudgetObject,
                                                  readOnly: level3BudgetObject
                                                              .id <=
                                                          0 ||
                                                      level3BudgetAccountsList
                                                              .length ==
                                                          1,
                                                  underline: Container(
                                                    height: 2,
                                                    width: 5000,
                                                    color: Color(0xff0957FF),
                                                  ),
                                                  hint: "Select one number",
                                                  searchHint:
                                                      "Select one number",
                                                  onClear: (value) {
                                                    setState(() {
                                                      level3BudgetObject =
                                                          level3BudgetAccountsList[
                                                              0];
                                                    });
                                                  }, // The default object is set again
                                                  onChanged: (value) {
                                                    setState(() {
                                                      level3BudgetObject =
                                                          value;
                                                    });

                                                    // TODO probably not needed as change in level3 has no affect in anything
                                                    // arrangeAccounts(3, 'actual');
                                                  },
                                                  dialogBox: true,
                                                  isExpanded: true,
                                                ),
                                              )
                                            : Container(),
                                        // #52 when a level is deactivated the widgets have no space between
                                        // this adds a little white space between the widget
                                        areLevel3AccountsActive
                                            ? Container()
                                            : SizedBox(height: 20),
                                        areCostTypesActive
                                            ? Container(
                                                constraints:
                                                    BoxConstraints.expand(
                                                  height: 50.0,
                                                ),
                                                padding: const EdgeInsets.only(
                                                    left: 30.0,
                                                    top: 0,
                                                    right: 30,
                                                    bottom: 0),
                                                //color: Colors.blue[600],
                                                alignment: Alignment.center,
                                                //child: Text('Submit'),
                                                child: Align(
                                                  alignment: Alignment.topRight,
                                                  child: SearchChoices.single(
                                                    value: costTypeObjectBudget,
                                                    icon: Icon(
                                                        Icons.arrow_downward),
                                                    iconSize: 24,
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff0957FF)),
                                                    //isExpanded: true,
                                                    underline: Container(
                                                      height: 2,
                                                      width: 2000,
                                                      color: Color(0xff0957FF),
                                                    ),
                                                    onChanged:
                                                        (CostType newValue) {
                                                      setState(() {
                                                        costTypeObjectBudget =
                                                            newValue;
                                                      });
                                                    },
                                                    items: costTypesList
                                                        .map((CostType type) {
                                                      return new DropdownMenuItem<
                                                          CostType>(
                                                        value: type,
                                                        child: new Text(
                                                          type.name,
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        ButtonBar(
                                          mainAxisSize: MainAxisSize
                                              .min, // this will take space as minimum as posible(to center)
                                          children: <Widget>[
                                            ButtonTheme(
                                              minWidth: 75.0,
                                              height: 40.0,
                                              child: RaisedButton(
                                                child: Text('Discard'),
                                                color:
                                                    Color(0xffEEEEEE), // EEEEEE
                                                onPressed: () {
                                                  budgetTextFieldController
                                                      .text = '';
                                                  setState(() {
                                                    level1BudgetObject =
                                                        level1BudgetAccountsList[
                                                            0];
                                                    level2BudgetObject =
                                                        level2BudgetAccountsList[
                                                            0];
                                                    level3BudgetObject =
                                                        level3BudgetAccountsList[
                                                            0];

                                                    costTypeObjectBudget =
                                                        costTypesList[0];
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
                                                        color: Colors.white,
                                                        fontSize: 17)),
                                                color: Color(
                                                    0xff0957FF), //df7599 - 0957FF
                                                onPressed: () {
                                                  commentInput(
                                                      context,
                                                      'budget',
                                                      null,
                                                      null,
                                                      null);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        ),
                        SmartRefresher(
                            controller: _refreshController,
                            enablePullDown: true,
                            onRefresh: () async {
                              await handleRefresh(_currentIndex);
                              print("REFRESHING ON SCROLL");
                              //await Future.delayed(Duration(seconds: 2));
                              _refreshController.refreshCompleted();
                            },
                            child: ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: bdgList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                      onTap: () {
                                        print(
                                            "Item ${bdgList[index].id} clicked");
                                        showDialog(
                                          context: context,
                                          builder: (context) => new AlertDialog(
                                            title: Text('Comment'),
                                            content: new Text(
                                                '${bdgList[index].comment}'),
                                            actions: <Widget>[
                                              new FlatButton(
                                                child: new Text('DISMISS'),
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.all(15.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.blueAccent),
                                          color: bdgList[index].active == 1
                                              ? Color(0xffEEEEEE)
                                              : Colors.redAccent,
                                          borderRadius:
                                              new BorderRadius.circular(30.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius:
                                                  20.0, // has the effect of softening the shadow
                                              spreadRadius:
                                                  5.0, // has the effect of extending the shadow
                                              offset: Offset(
                                                10.0, // horizontal, move right 10
                                                10.0, // vertical, move down 10
                                              ),
                                            )
                                          ],
                                        ),
                                        child: Center(
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .6,
                                                //height: 300.0,
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      SizedBox(height: 15),
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  .1,
                                                              child: Icon(
                                                                Icons
                                                                    .account_balance_wallet,
                                                                color: Color(
                                                                    0xff0957FF),
                                                              ),
                                                            ),
                                                            Text(
                                                              "${bdgList[index].date}",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xff0957FF),
                                                                  fontSize: 25),
                                                            ),
                                                          ]),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  .1,
                                                              child:
                                                                  Container(),
                                                            ),
                                                            Text(
                                                              "${bdgList[index].comment}",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 15),
                                                            ),
                                                            Container(),
                                                          ]),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .1,
                                                                //height: 300.0,
                                                                child:
                                                                    Container()),
                                                            Text(
                                                              '${bdgList[index].level1} > ${bdgList[index].level2} > ${bdgList[index].level3} \n${bdgList[index].costType}',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 13),
                                                            )
                                                          ]),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                    ]),
                                              ),
                                              Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        '${bdgList[index].amount}'),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .1,
                                                      //height: 300.0,
                                                      child: IconButton(
                                                        icon: new Icon(
                                                          bdgList[index]
                                                                      .active ==
                                                                  1
                                                              ? Icons.delete
                                                              : Icons.restore,
                                                        ),
                                                        color:
                                                            Color(0xff0957FF),
                                                        onPressed: () {
                                                          print(
                                                              'TODELETE + ${bdgList[index].id}');

                                                          showDialog(
                                                            context: context,
                                                            builder: (context) =>
                                                                new AlertDialog(
                                                              title: Text(
                                                                  "Are you sure?"),
                                                              content: RichText(
                                                                text: TextSpan(
                                                                    text:
                                                                        'Entry from ',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold),
                                                                    children: <
                                                                        TextSpan>[
                                                                      TextSpan(
                                                                        text:
                                                                            '${bdgList[index].date} ',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Color(0xFF0957FF),
                                                                            fontSize: 18),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            'with an amount of ',
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            '${bdgList[index].amount} ',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Color(0xFF0957FF),
                                                                            fontSize: 18),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            'will be ',
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            '${bdgList[index].active == 1 ? "deleted" : "restored"}',
                                                                        style: TextStyle(
                                                                            color: bdgList[index].active == 1
                                                                                ? Colors.red
                                                                                : Colors.green,
                                                                            fontSize: 18),
                                                                      ),
                                                                    ]),
                                                              ),
                                                              actions: <Widget>[
                                                                new FlatButton(
                                                                  child: new Text(
                                                                      'Cancel'),
                                                                  onPressed: () =>
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(),
                                                                ),
                                                                new FlatButton(
                                                                  child: new Text(
                                                                      'Confirm'),
                                                                  onPressed:
                                                                      () {
                                                                    bdgObjectToDelete
                                                                            .id =
                                                                        bdgList[index]
                                                                            .id;

                                                                    sendBackend(
                                                                        'bdglistdelete',
                                                                        false);
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                )
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  ]),
                                            ])),
                                      ));
                                })),
                      ]),
                    ),
                  )
                ],
              ),
            ),
            CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: SmartRefresher(
                      controller: _refreshController,
                      enablePullDown: true,
                      onRefresh: () async {
                        await handleRefresh(_currentIndex);
                        print("REFRESHING ON SCROLL");
                        //await Future.delayed(Duration(seconds: 2));
                        _refreshController.refreshCompleted();
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                ButtonTheme(
                                  //minWidth: 150.0,
                                  height: 60.0,
                                  child: FlatButton(
                                    onPressed: () => _showDatePicker(
                                        'visualizer', dateTimeVisualizer),
                                    shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(40.0),
                                    ),
                                    color: Color(0xff003680),
                                    padding: EdgeInsets.all(10.0),
                                    child: Row(
                                      // Replace with a Row for horizontal icon + text
                                      children: <Widget>[
                                        Text(
                                            " ${dateTimeVisualizer.year.toString()}-${dateTimeVisualizer.month.toString().padLeft(2, '0')}",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17)),
                                        SizedBox(width: 10),
                                        Icon(
                                          Icons.calendar_today,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                          Container(
                            //color: Colors.blue[600],
                            alignment: Alignment.center,
                            //child: Text('Submit'),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Switch(
                                    value: showFullYear,
                                    onChanged: (value) {
                                      setState(() {
                                        showAllTime = false;
                                        showFullYear = value;
                                        loadAmount();
                                      });
                                    },
                                    activeTrackColor: Color(0xffEEEEEE),
                                    activeColor: Color(0xff0957FF),
                                  ),
                                  Text(
                                    "Full Year",
                                    style: TextStyle(fontSize: 25),
                                  ),
                                  Switch(
                                    value: showAllTime,
                                    onChanged: (value) {
                                      setState(() {
                                        showFullYear = false;
                                        showAllTime = value;
                                        loadAmount();
                                      });
                                    },
                                    activeTrackColor: Color(0xffEEEEEE),
                                    activeColor: Color(0xff0957FF),
                                  ),
                                  Text(
                                    "All Time",
                                    style: TextStyle(fontSize: 25),
                                  ),
                                ]),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.only(
                                  left: 30.0, top: 0, right: 0, bottom: 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Drilldown: " + drilldownLevel,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * .4,
                            child: charts.BarChart(
                              [
                                charts.Series<CompanySizeVsNumberOfCompanies,
                                        String>(
                                    id: 'CompanySizeVsNumberOfCompanies',
                                    colorFn: (_, __) =>
                                        charts.ColorUtil.fromDartColor(
                                            Color(0xFF0957FF)),
                                    domainFn:
                                        (CompanySizeVsNumberOfCompanies sales,
                                                _) =>
                                            sales.companySize,
                                    measureFn:
                                        (CompanySizeVsNumberOfCompanies sales,
                                                _) =>
                                            sales.numberOfCompanies,
                                    labelAccessorFn:
                                        (CompanySizeVsNumberOfCompanies sales,
                                                _) =>
                                            '${sales.companySize}: ${sales.numberOfCompanies.toString()}€',
                                    data: visualizerData)
                              ],
                              animate: true,
                              selectionModels: [
                                new charts.SelectionModelConfig(
                                    type: charts.SelectionModelType.info,
                                    changedListener: _onSelectionChanged)
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
                                    behaviorPosition:
                                        charts.BehaviorPosition.start),
                                charts.ChartTitle('Amounts',
                                    behaviorPosition:
                                        charts.BehaviorPosition.bottom)
                              ],
                            ),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 30.0, top: 0, right: 30, bottom: 0),
                                  //child: Text('Submit'),
                                  child: RaisedButton(
                                    child: Text('Reset'),
                                    color: Color(0xffEEEEEE), // EEEEEE
                                    onPressed: () {
                                      setState(() {
                                        showAllTime = false;
                                        showFullYear = false;
                                        costTypeObjectVisualizer =
                                            costTypesList[0];
                                        dateTimeVisualizer =
                                            DateTime.parse(INIT_DATETIME);

                                        g_parent_account.accountLevel = 1;
                                        g_parent_account.id = -69;

                                        drilldownLevel = "";

                                        loadAmount();
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 30.0,
                                      top: 0,
                                      right: 30,
                                      bottom: 30),
                                  //child: Text('Submit'),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: SearchChoices.single(
                                      value: costTypeObjectVisualizer,
                                      icon: Icon(Icons.arrow_downward),
                                      iconSize: 24,
                                      style:
                                          TextStyle(color: Color(0xff0957FF)),
                                      underline: Container(
                                        height: 2,
                                        width: 2000,
                                        color: Color(0xff0957FF),
                                      ),
                                      onChanged: (CostType newValue) {
                                        setState(() {
                                          costTypeObjectVisualizer = newValue;
                                          loadAmount();
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
                              ])
                        ],
                      )),
                ),
              ],
            ),
            DefaultTabController(
              length: 3,
              child: Column(
                children: <Widget>[
                  Container(
                    //constraints: BoxConstraints.expand(height: 50),
                    child: TabBar(indicatorColor: Color(0xff0957FF), tabs: [
                      Tab(
                        child: Container(
                          alignment: Alignment.center,
                          //constraints: BoxConstraints.expand(width: 200),
                          width: 2000,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xff003680),
                          ),

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
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xff73D700),
                          ),
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
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xffDB002A),
                          ),
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
                            child: SmartRefresher(
                                controller: _refreshController,
                                enablePullDown: true,
                                onRefresh: () async {
                                  await handleRefresh(_currentIndex);
                                  print("REFRESHING ON SCROLL");
                                  //await Future.delayed(Duration(seconds: 2));
                                  _refreshController.refreshCompleted();
                                },
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                              value: areCostTypesActive,
                                              onChanged: (value) {
                                                setState(() {
                                                  areCostTypesActive = value;
                                                });
                                              },
                                              activeTrackColor:
                                                  Color(0xffEEEEEE),
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
                                              value: areAccountsActive,
                                              onChanged: (value) {
                                                setState(() {
                                                  areAccountsActive = value;

                                                  areLevel1AccountsActive =
                                                      areAccountsActive;
                                                  areLevel2AccountsActive =
                                                      areAccountsActive;
                                                  areLevel3AccountsActive =
                                                      areAccountsActive;
                                                });
                                              },
                                              activeTrackColor:
                                                  Color(0xffEEEEEE),
                                              activeColor: Color(0xff0957FF),
                                            ),
                                          ]),
                                      Container(
                                        padding: const EdgeInsets.only(
                                            left: 0,
                                            top: 0,
                                            right: 0,
                                            bottom: 10),
                                      ),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Text("Use Level 1:",
                                                style: TextStyle(fontSize: 25)),
                                            Switch(
                                              value: areLevel1AccountsActive,
                                              onChanged: (value) {
                                                setState(() {
                                                  areLevel1AccountsActive =
                                                      value;
                                                  areAccountsActive = value;

                                                  // Logic that does not allow invalid state of other levels, e.g. level3 active and level1 and level2 inactive
                                                  if (!areLevel1AccountsActive) {
                                                    areLevel2AccountsActive =
                                                        false;
                                                    areLevel3AccountsActive =
                                                        false;
                                                  }
                                                });
                                              },
                                              activeTrackColor:
                                                  Color(0xffEEEEEE),
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
                                              value: areLevel2AccountsActive,
                                              onChanged: (value) {
                                                setState(() {
                                                  areLevel2AccountsActive =
                                                      value;

                                                  // Logic that does not allow invalid state of other levels, e.g. level3 active and level1 and level2 inactive
                                                  if (areLevel2AccountsActive) {
                                                    areLevel1AccountsActive =
                                                        true;
                                                    areAccountsActive = true;
                                                  } else if (!areLevel2AccountsActive) {
                                                    areLevel3AccountsActive =
                                                        false;
                                                  }
                                                });
                                              },
                                              activeTrackColor:
                                                  Color(0xffEEEEEE),
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
                                              value: areLevel3AccountsActive,
                                              onChanged: (value) {
                                                setState(() {
                                                  areLevel3AccountsActive =
                                                      value;

                                                  // Logic that does not allow invalid state of other levels, e.g. level3 active and level1 and level2 inactive
                                                  if (areLevel3AccountsActive) {
                                                    areAccountsActive = true;
                                                    areLevel1AccountsActive =
                                                        true;
                                                    areLevel2AccountsActive =
                                                        true;
                                                  }
                                                });
                                              },
                                              activeTrackColor:
                                                  Color(0xffEEEEEE),
                                              activeColor: Color(0xff0957FF),
                                            ),
                                          ]),
                                      ButtonBar(
                                        mainAxisSize: MainAxisSize
                                            .min, // this will take space as minimum as posible(to center)
                                        children: <Widget>[
                                          ButtonTheme(
                                            minWidth: 75.0,
                                            height: 50.0,
                                            child: RaisedButton(
                                              child: Text('Discard'),
                                              color:
                                                  Color(0xffEEEEEE), // EEEEEE
                                              onPressed: () {
                                                loadPreferences();
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
                                                sendBackend(
                                                    'generaladmin', false);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ])),
                          ),
                        ]),
                        CustomScrollView(slivers: [
                          SliverFillRemaining(
                            child: SmartRefresher(
                                controller: _refreshController,
                                enablePullDown: true,
                                onRefresh: () async {
                                  await handleRefresh(_currentIndex);
                                  print("REFRESHING ON SCROLL");
                                  //await Future.delayed(Duration(seconds: 2));
                                  _refreshController.refreshCompleted();
                                },
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text("Account Administration",
                                          style: TextStyle(fontSize: 25)),
                                      areLevel1AccountsActive
                                          ? Container(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0,
                                                  top: 0,
                                                  right: 30,
                                                  bottom: 0),
                                              //color: Colors.blue[600],
                                              alignment: Alignment.center,
                                              //child: Text('Submit'),
                                              child: SearchChoices.single(
                                                value: level1AdminObject,
                                                hint: Text(
                                                  "Select a level 1 account",
                                                  /*style: TextStyle(
                              color,
                            ),*/
                                                ),
                                                icon:
                                                    Icon(Icons.arrow_downward),
                                                iconSize: 24,
                                                style: TextStyle(
                                                    color: Color(0xff0957FF)),
                                                isExpanded: true,
                                                underline: Container(
                                                  height: 2,
                                                  width: 5000,
                                                  color: Color(0xff0957FF),
                                                ),
                                                onChanged: (Account newValue) {
                                                  setState(() {
                                                    level1AdminObject =
                                                        newValue;
                                                  });

                                                  arrangeAccounts(1, 'admin');
                                                },
                                                items: level1AdminAccountsList
                                                    .map((Account account) {
                                                  return new DropdownMenuItem<
                                                      Account>(
                                                    value: account,
                                                    child: new Text(
                                                      account.name,
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            )
                                          : Container(),
                                      areLevel1AccountsActive
                                          ? Container(
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
                                                    newLevel1TextFieldController,
                                                decoration: InputDecoration(
                                                    hintText:
                                                        'Select an existing or create a new level 1',
                                                    hintStyle: TextStyle(
                                                        height: 1.75,
                                                        color:
                                                            Color(0xff0957FF)),
                                                    /*icon: Icon(
                                            Icons.attach_money,
                                            color: Color(0xff0957FF),
                                          ),*/
                                                    //prefixIcon: Icon(Icons.attach_money),
                                                    //labelStyle: TextStyle(color: Color(0xff0957FF)),
                                                    enabledBorder:
                                                        new UnderlineInputBorder(
                                                            borderSide:
                                                                new BorderSide(
                                                                    color: Color(
                                                                        0xff0957FF)))),
                                              ),
                                            )
                                          : Container(),
                                      /*
                                  Divider(
                                    color: Colors.black,
                                  ),
                                  */
                                      areLevel2AccountsActive
                                          ? Container(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0,
                                                  top: 0,
                                                  right: 30,
                                                  bottom: 0),
                                              //color: Colors.blue[600],
                                              alignment: Alignment.center,
                                              //child: Text('Submit'),
                                              child: SearchChoices.single(
                                                value: level2AdminObject,
                                                hint: Text(
                                                  "Select a level 2 account",
                                                  /*style: TextStyle(
                              color,
                            ),*/
                                                ),
                                                readOnly:
                                                    level1AdminObject.id <= 0 ||
                                                        level2AdminAccountsList
                                                                .length ==
                                                            1,
                                                icon:
                                                    Icon(Icons.arrow_downward),
                                                iconSize: 24,
                                                style: TextStyle(
                                                    color: Color(0xff0957FF)),
                                                isExpanded: true,
                                                underline: Container(
                                                  height: 2,
                                                  width: 5000,
                                                  color: Color(0xff0957FF),
                                                ),
                                                onChanged: (Account newValue) {
                                                  setState(() {
                                                    level2AdminObject =
                                                        newValue;
                                                  });

                                                  arrangeAccounts(2, 'admin');
                                                },
                                                items: level2AdminAccountsList
                                                    .map((Account account) {
                                                  return new DropdownMenuItem<
                                                      Account>(
                                                    value: account,
                                                    child: new Text(
                                                      account.name,
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            )
                                          : Container(),
                                      areLevel2AccountsActive
                                          ? Container(
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
                                                    newLevel2TextFieldController,
                                                decoration: InputDecoration(
                                                    hintText:
                                                        'Select an existing or create a new level 2',
                                                    hintStyle: TextStyle(
                                                        height: 1.75,
                                                        color:
                                                            Color(0xff0957FF)),
                                                    /*icon: Icon(
                                            Icons.attach_money,
                                            color: Color(0xff0957FF),
                                          ),*/
                                                    //prefixIcon: Icon(Icons.attach_money),
                                                    //labelStyle: TextStyle(color: Color(0xff0957FF)),
                                                    enabledBorder:
                                                        new UnderlineInputBorder(
                                                            borderSide:
                                                                new BorderSide(
                                                                    color: Color(
                                                                        0xff0957FF)))),
                                              ),
                                            )
                                          : Container(),
                                      /*
                                  Divider(
                                    color: Colors.black,
                                  ), */
                                      areLevel3AccountsActive
                                          ? Container(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0,
                                                  top: 0,
                                                  right: 30,
                                                  bottom: 0),
                                              //color: Colors.blue[600],
                                              alignment: Alignment.center,
                                              //child: Text('Submit'),
                                              child: SearchChoices.single(
                                                value: level3AdminObject,
                                                hint: Text(
                                                  "Select a level 3 account",
                                                  /*style: TextStyle(
                              color,
                            ),*/
                                                ),
                                                readOnly:
                                                    level2AdminObject.id <= 0 ||
                                                        level3AdminAccountsList
                                                                .length ==
                                                            1,
                                                icon:
                                                    Icon(Icons.arrow_downward),
                                                iconSize: 24,
                                                style: TextStyle(
                                                    color: Color(0xff0957FF)),
                                                isExpanded: true,
                                                underline: Container(
                                                  height: 2,
                                                  width: 5000,
                                                  color: Color(0xff0957FF),
                                                ),
                                                onChanged: (Account newValue) {
                                                  setState(() {
                                                    level3AdminObject =
                                                        newValue;
                                                  });

                                                  // TODO probably not needed as change in level3 has no affect in anything
                                                  //arrangeAccounts(3, 'admin');
                                                },
                                                items: level3AdminAccountsList
                                                    .map((Account account) {
                                                  return new DropdownMenuItem<
                                                      Account>(
                                                    value: account,
                                                    child: new Text(
                                                      account.name,
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            )
                                          : Container(),
                                      areLevel3AccountsActive
                                          ? Container(
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
                                                controller:
                                                    newLevel3TextFieldController,
                                                decoration: InputDecoration(
                                                    hintText:
                                                        'Select an existing or create a new level 3',
                                                    hintStyle: TextStyle(
                                                        height: 1.75,
                                                        color:
                                                            Color(0xff0957FF)),
                                                    /*icon: Icon(
                                            Icons.attach_money,
                                            color: Color(0xff0957FF),
                                          ),*/
                                                    //prefixIcon: Icon(Icons.attach_money),
                                                    //labelStyle: TextStyle(color: Color(0xff0957FF)),
                                                    enabledBorder:
                                                        new UnderlineInputBorder(
                                                            borderSide:
                                                                new BorderSide(
                                                                    color: Color(
                                                                        0xff0957FF)))),
                                              ),
                                            )
                                          : Container(),
                                      ButtonBar(
                                        mainAxisSize: MainAxisSize
                                            .min, // this will take space as minimum as posible(to center)
                                        children: <Widget>[
                                          ButtonTheme(
                                            minWidth: 75.0,
                                            height: 50.0,
                                            child: RaisedButton(
                                              child: Text('Discard'),
                                              color:
                                                  Color(0xffEEEEEE), // EEEEEE
                                              onPressed: () {
                                                newLevel1TextFieldController
                                                    .text = '';
                                                newLevel2TextFieldController
                                                    .text = '';
                                                newLevel3TextFieldController
                                                    .text = '';
                                                setState(() {
                                                  level1AdminObject =
                                                      level1AdminAccountsList[
                                                          0];
                                                  level2AdminObject =
                                                      level2AdminAccountsList[
                                                          0];
                                                  level3AdminObject =
                                                      level3AdminAccountsList[
                                                          0];
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
                                              color:
                                                  Colors.red, //df7599 - 0957FF
                                              onPressed: () {
                                                sendBackend(
                                                    'newaccountdelete', false);

                                                if (level3AdminObject.id > 0) {
                                                  // If the acount which has just been deleted was selected, unselect it
                                                  if (level3ActualObject.id ==
                                                      level3AdminObject.id) {
                                                    level3ActualObject =
                                                        level3ActualAccountsList[
                                                            0];
                                                  }

                                                  if (level3BudgetObject.id ==
                                                      level3AdminObject.id) {
                                                    level3BudgetObject =
                                                        level3BudgetAccountsList[
                                                            0];
                                                  }

                                                  level3AdminObject =
                                                      level3AdminAccountsList[
                                                          0];
                                                } else if (level2AdminObject
                                                        .id >
                                                    0) {
                                                  // If the acount which has just been deleted was selected, unselect it
                                                  if (level2ActualObject.id ==
                                                      level2AdminObject.id) {
                                                    level2ActualObject =
                                                        level2ActualAccountsList[
                                                            0];
                                                  }

                                                  if (level2BudgetObject.id ==
                                                      level2AdminObject.id) {
                                                    level2BudgetObject =
                                                        level2BudgetAccountsList[
                                                            0];
                                                  }

                                                  level2AdminObject =
                                                      level2AdminAccountsList[
                                                          0];
                                                } else if (level1AdminObject
                                                        .id >
                                                    0) {
                                                  // If the acount which has just been deleted was selected, unselect it
                                                  if (level1ActualObject.id ==
                                                      level1AdminObject.id) {
                                                    level1ActualObject =
                                                        level1ActualAccountsList[
                                                            0];
                                                  }

                                                  if (level1BudgetObject.id ==
                                                      level1AdminObject.id) {
                                                    level1BudgetObject =
                                                        level1BudgetAccountsList[
                                                            0];
                                                  }

                                                  level1AdminObject =
                                                      level1AdminAccountsList[
                                                          0];
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
                                    ])),
                          )
                        ]),
                        CustomScrollView(slivers: [
                          SliverFillRemaining(
                            child: SmartRefresher(
                                controller: _refreshController,
                                enablePullDown: true,
                                onRefresh: () async {
                                  await handleRefresh(_currentIndex);
                                  print("REFRESHING ON SCROLL");
                                  //await Future.delayed(Duration(seconds: 2));
                                  _refreshController.refreshCompleted();
                                },
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                        child: SearchChoices.single(
                                          value: costTypeObjectAdmin,
                                          hint: Text(
                                            "Select a costtype to delete",
                                            /*style: TextStyle(
                              color,
                            ),*/
                                          ),
                                          icon: Icon(Icons.arrow_downward),
                                          iconSize: 24,
                                          style: TextStyle(
                                              color: Color(0xff0957FF)),
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
                                            return new DropdownMenuItem<
                                                CostType>(
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
                                                          color: Color(
                                                              0xff0957FF)))),
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
                                              color:
                                                  Color(0xffEEEEEE), // EEEEEE
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
                                              color:
                                                  Colors.red, //df7599 - 0957FF
                                              onPressed: () {
                                                sendBackend(
                                                    'newcosttypedelete', false);

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
                                    ])),
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
