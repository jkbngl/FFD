import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:after_layout/after_layout.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:search_choices/search_choices.dart';
import 'package:slide_to_confirm/slide_to_confirm.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import 'package:ffd/sign_in.dart';
import 'app_localizations.dart';

import 'package:http/http.dart' as http;
import 'dart:ui';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:math';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FFD Demo - ',
      supportedLocales: [
        Locale('en', ''),
        Locale('de', ''),
        Locale('it', ''),
        Locale('es', ''),
        Locale('fr', ''),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: colorCustom,
        fontFamily: 'Montserrat',
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
  ListItem(this._type,
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

class ChartObject {
  String accountName;
  double amount;
  int accountId;
  int accountLevel;
  double budgetEntry;
  final charts.Color color;

  ChartObject(this.accountName,
      this.amount,
      this.accountId,
      this.accountLevel,
      this.budgetEntry,
      this.color);
}

class homescreenPie {
  String type;
  double amount;
  charts.Color color;

  homescreenPie(this.type, this.amount, this.color);
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

String MIN_DATETIME = (DateTime
    .now()
    .year - 5).toString() +
    '-' +
    DateTime
        .now()
        .month
        .toString()
        .padLeft(2, '0') +
    '-' +
    DateTime
        .now()
        .day
        .toString()
        .padLeft(2, '0');
String MAX_DATETIME = (DateTime
    .now()
    .year + 5).toString() +
    '-' +
    DateTime
        .now()
        .month
        .toString()
        .padLeft(2, '0') +
    '-' +
    DateTime
        .now()
        .day
        .toString()
        .padLeft(2, '0');
String INIT_DATETIME = DateTime
    .now()
    .year
    .toString() +
    '-' +
    DateTime
        .now()
        .month
        .toString()
        .padLeft(2, '0') +
    '-' +
    DateTime
        .now()
        .day
        .toString()
        .padLeft(2, '0');
String _format = 'yyyy-MMMM';

class _MyHomePageState extends State<MyHomePage>
    with AfterLayoutMixin<MyHomePage> {

  Widget chartContainer = Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [Text('Chart Viewer', style: GoogleFonts.lato(),)],
  );

  int _currentIndex = 0;
  PageController _pageController;

  // Bool which defined if accounts and costTypes needs to be refetched or can be cached
  bool fetchAccountsAndCostTypes = false;

  double dailyExpense = 0;
  double thisMonthAverage = 0;

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
  ListItem actObjectToDelete = new ListItem(
      'actual',
      -1,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null);
  ListItem bdgObjectToDelete = new ListItem(
      'actual',
      -1,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null);

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

  // bool used to show load symbol while loading data, and bool to show splashScreen while not fully started
  bool currentlyLoading = false;
  bool startingUp = false;

  // String connectionId = '192.168.0.21:5000';
  // String connectionId = 'financefordummies.ml';
  // String connectionId = '192.168.178.38:8000';
  String connectionId = 'ffd-api.herokuapp.com';

  final actualTextFieldController = TextEditingController();
  final budgetTextFieldController = TextEditingController();

  final actualSearchTextFieldController = TextEditingController();
  final budgetSearchTextFieldController = TextEditingController();

  // Datetime object for selecting the date when the actual/ budget should be saved
  DateTime dateTimeHome;
  DateTime dateTimeActual;
  DateTime dateTimeBudget;
  DateTime dateTimeVisualizer;

  var parsedActualComparison = 0.00;
  var parsedBudgetComparison = 0.00;

  var visualizerData = [
    ChartObject("1-25", 10, -69, -69, -69,
        charts.ColorUtil.fromDartColor(Color(0xff0957FF))),
  ];

  var visualizerTargetData = [
    ChartObject("1-25", 10, -69, -69, -69,
        charts.ColorUtil.fromDartColor(Color(0xff003680))),
  ];

  var homescreenData = [
    homescreenPie(
        'Dummy1', 10, charts.ColorUtil.fromDartColor(Color(0xff003680))),
    homescreenPie(
        'Dummy2', 10, charts.ColorUtil.fromDartColor(Color(0xff0957FF))),
    homescreenPie('Dummy3', 10, charts.MaterialPalette.green.shadeDefault),
  ];

  // To make sure errorDialog is only shown once and not multiple times when multiple errors happen
  bool errorDialogActive = false;


  // Standard sorting logic
  String actualListSortColumn = 'created';
  String actualListSortType = 'desc';

  String budgetListSortColumn = 'created';
  String budgetListSortType = 'desc';

  int sortOrder = 0;

  // New sorting with radio button
  List<bool> sortActualOrders = <bool>[];
  bool sortByCreatedActual = true;
  bool sortByDataDateActual = false;
  bool sortByAmountActual = false;
  bool sortByCosttypeActual = false;
  bool sortByLevelActual = false;

  // Grouping by account, year, month or day
  List<bool> groupByVisualizerOptions = <bool>[];
  bool groupByAccount = true;
  bool groupByYear = false;
  bool groupByMonth = false;
  bool groupByDay = false;
  String groupByArgument = 'Accounts';

  List<bool> sortBudgetOrders = <bool>[];
  bool sortByCreatedBudget = true;
  bool sortByDataDateBudget = false;
  bool sortByAmountBudget = false;
  bool sortByCosttypeBudget = false;
  bool sortByLevelBudget = false;

  // Default value for the switch in the dialog
  bool sortActualDescending = true;
  bool sortBudgetDescending = true;


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

  // bools for scheduling of multiple entries
  bool scheduleEntries = false;
  bool scheduleYear = false;
  bool scheduleMonth = false;
  bool scheduleWeek = false;
  bool scheduleDay = false;
  final scheduleAmountTextFieldController = TextEditingController();


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

  // for snackbars in #199
  GlobalKey<ScaffoldState> _scaffoldKey;


  // Dynamic title at the top of the screen which is changed depending on which page is selected
  var appBarTitleText = new Text("FFD v2", style: GoogleFonts.lato(),);

  @override
  void initState() {
    super.initState();

    _scaffoldKey = new GlobalKey<ScaffoldState>();

    setState(() {
      startingUp = true;
    });


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

    sortActualOrders.add(sortByCreatedActual);
    sortActualOrders.add(sortByDataDateActual);
    sortActualOrders.add(sortByAmountActual);
    sortActualOrders.add(sortByCosttypeActual);
    sortActualOrders.add(sortByLevelActual);

    sortBudgetOrders.add(sortByCreatedBudget);
    sortBudgetOrders.add(sortByDataDateBudget);
    sortBudgetOrders.add(sortByAmountBudget);
    sortBudgetOrders.add(sortByCosttypeBudget);
    sortBudgetOrders.add(sortByLevelBudget);

    groupByVisualizerOptions.add(groupByAccount);
    groupByVisualizerOptions.add(groupByYear);
    groupByVisualizerOptions.add(groupByMonth);
    groupByVisualizerOptions.add(groupByDay);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    setState(() {
      currentlyLoading = true;
    });

    welcomeDialog();

    // Resolves the issue that no data is available on login
    await getToken();
    await syncUserInBackend();

    // #89 replaces global calls with single calls per type
    // checkForChanges(true, fetchAccountsAndCostTypes, 'all');
    checkForChanges(true, fetchAccountsAndCostTypes, 'actual');
    checkForChanges(true, fetchAccountsAndCostTypes, 'budget');
    checkForChanges(true, fetchAccountsAndCostTypes, 'admin');


    await loadList('actual', actualListSortColumn, actualListSortType);
    await loadList('budget', budgetListSortColumn, budgetListSortType);

    // Await is needed here because else the sendBackend for generalAdmin will always overwrite the preferences with the default values defined in the code here
    await loadPreferences();
    // initialize if no preferences are present yet
    await sendBackend('generaladmin', true);

    await loadHomescreen(false);
    await loadAmount(false);

    setState(() {
      currentlyLoading = false;
      startingUp = false;
    });
  }

  // Lists that hold the items in the adjust list
  final List<ListItem> actList = <ListItem>[];
  final List<ListItem> bdgList = <ListItem>[];

  welcomeDialog() async {
    print("HERE");
    String language = Localizations.localeOf(context).toString().split('_')[0];

    try {
      String url = 'https://uselessfacts.jsph.pl/random.json?language=${language ==
          'en' || language == 'de' ? language : 'en'}';

      print(url);
      print(Localizations.localeOf(context).toString());
      print(
          Locale(ui.window.locale.languageCode, ui.window.locale.countryCode));
      print(language);

      var randomFact =
      await http.read(url);
      var parsedFact = json.decode(randomFact);

      showDialog(
        context: context,
        builder: (context) =>
        new AlertDialog(
          content: RichText(
              text: TextSpan(
                text:
                AppLocalizations.of(context).translate('welcomeText'),
                style: GoogleFonts.lato(fontSize: 15, color: Color(
                    0xff2B2B2B),),
                children: <TextSpan>[
                  TextSpan(
                    text: parsedFact['text'],
                    style: GoogleFonts.lato(fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                  )
                ],
              ), ),
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                  AppLocalizations.of(context).translate('dismissDialog'), style: GoogleFonts.lato(),),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
    } catch (e) {
      // errorDialog(e);
    }
  }

  syncUserInBackend() async {
    String uri = 'https://$connectionId/api/ffd/user/';

    print(uri);

    var params = {
      "accesstoken": token,
    };

    print("-----------------------------------------");
    print(token);
    print("-----------------------------------------");

    try {
      var user = await http.read(uri, headers: params);
      print(user);
    } catch (e) {
      errorDialog(e);
    }
  }

  loadList(String type, String sort, String sortType) async {
    String uri =
        'https://$connectionId/api/ffd/list/?_type=$type&sort=$sort&sortType=$sortType';

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
              amount['amount'].toDouble(),
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
              amount['amount'].toDouble(),
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
      errorDialog(e);
    }

    setState(() {});
  }

  loadAmount(bool fromSwitch) async {
    int level_type = g_parent_account.accountLevel;
    int cost_type = costTypeObjectVisualizer.id;
    int parent_account = g_parent_account.id;
    int year = showAllTime ? -1 : dateTimeVisualizer.year;
    int day = -1;
    int month = showFullYear || showAllTime
        ? -1
        : dateTimeVisualizer
        .month; //if the whole year or all time should be shown, use no month filter

    // Needed to distinguish between actual and budget, so has to be set on runTime
    String _type = '';
    String uri = '';
    String todaysExpenseUri = 'https://$connectionId/api/ffd/amounts/?level_type=1&cost_type=-1&parent_account=-1&year=${DateTime.now().year}&month=${DateTime.now().month}&day=${DateTime.now().day}&_type=actual&groupBy=Day';

    ChartObject needsToBeAdded = ChartObject('DUMMY', -99, -69, -69, -69,
        charts.ColorUtil.fromDartColor(Color(0xff003680)));

    var params = {
      "accesstoken": token,
    };

    var dailyAmount = await http.read(todaysExpenseUri, headers: params);
    var parseddailyAmount = json.decode(dailyAmount);

    if(parseddailyAmount.length > 0)
    {

      DateTime now = DateTime.now();

      dailyExpense = now.year == parseddailyAmount[0]['year'] && now.month == parseddailyAmount[0]['month'] && now.day == parseddailyAmount[0]['day'] ? parseddailyAmount[0]['sum'].toDouble() : 0;

      thisMonthAverage = 0;

      for(var amount in parseddailyAmount)
      {
        thisMonthAverage += amount['sum'].toDouble();
      }

      thisMonthAverage /= now.day;
    }

    //try {
    _type = 'actual';
    uri =
    'https://$connectionId/api/ffd/amounts/?level_type=$level_type&cost_type=$cost_type&parent_account=$parent_account&year=$year&month=$month&day=$day&_type=$_type&groupBy=$groupByArgument';
    var actualAmounts = await http.read(uri, headers: params);

    _type = 'budget';
    uri =
    'https://$connectionId/api/ffd/amounts/?level_type=$level_type&cost_type=$cost_type&parent_account=$parent_account&year=$year&month=$month&day=$day&_type=$_type&groupBy=$groupByArgument';
    var budgetAmounts = await http.read(uri, headers: params);

    var parsedActualAmounts = json.decode(actualAmounts);
    var parsedBudgetAmounts = json.decode(budgetAmounts);

    visualizerData.clear();
    visualizerTargetData.clear();

    for (var amounts in parsedActualAmounts) {
      visualizerData.add(ChartObject(
          amounts['level${groupByArgument == 'Accounts'
              ? level_type.toString()
              : 1}'].toString(),
          amounts['sum'].toDouble(),
          amounts['level${level_type}_fk'],
          level_type,
          -69,
          charts.ColorUtil.fromDartColor(Color(0xff003680))));
    }

    print("parsedBudgetAmounts");
    print(parsedBudgetAmounts);
    print("parsedActualAmounts");
    print(parsedActualAmounts);

    print("groubByArgument = $groupByArgument");

    for (var amounts in parsedBudgetAmounts) {
      if (amounts['level${groupByArgument == 'Accounts'
          ? level_type.toString()
          : 1}_fk'] > 0 || groupByArgument == 'Year' || groupByArgument == 'Month') {
        // Only show budgets with an account assigned

        // Check if a corresponding actual exists
        needsToBeAdded = visualizerData.firstWhere(
                (itemToCheck) =>
            itemToCheck.accountName ==
                amounts['level$level_type'].toString(),
            orElse: () => null);

        print("needsToBeAdded $needsToBeAdded");

        // Has already been added as an expense and therefore needs only to be added to the budget column
        if (needsToBeAdded != null) {
          visualizerTargetData.add(ChartObject(
              amounts['level$level_type'].toString(),
              amounts['sum'].toDouble(),
              amounts['level${level_type.toString()}_fk'],
              level_type,
              // #116
              -69,
              charts.ColorUtil.fromDartColor(Color(0xff003680))));
        }
        // Has not been added as an expense and therefore is added as an expense with an amount of zero
        else {
          visualizerTargetData.add(ChartObject(
              amounts['level$level_type'].toString(),
              amounts['sum'].toDouble(),
              amounts['level${level_type.toString()}_fk'],
              level_type,
              // #116
              -69,
              charts.ColorUtil.fromDartColor(Color(0xff003680))));

          visualizerData.add(ChartObject(
              amounts['level$level_type'].toString(),
              0,
              amounts['level${level_type.toString()}_fk'],
              level_type,
              // #116
              visualizerTargetData
                  .firstWhere(
                      (itemToCheck) =>
                  itemToCheck.accountName ==
                      amounts['level$level_type'].toString() &&
                      itemToCheck.accountLevel == level_type,
                  orElse: () =>
                      ChartObject("1-25", 10, -69, -69, -69,
                          charts.ColorUtil.fromDartColor(Color(0xff003680))))
                  .amount,
              charts.ColorUtil.fromDartColor(Color(0xff003680))));
        }
      }
    }

    print("++++++++++++++++++++++");
    print(visualizerTargetData);

    for (ChartObject item in visualizerData) {
      if (item.budgetEntry < 0) {
        item.budgetEntry = visualizerTargetData
            .firstWhere(
                (itemToCheck) =>
            itemToCheck.accountName == item.accountName &&
                itemToCheck.accountLevel == item.accountLevel,
            orElse: () =>
                ChartObject("1-25", -69, -69, -69, -69,
                    charts.ColorUtil.fromDartColor(Color(0xff003680))))
            .amount;
      }
    }
    //}
    //catch (e) {
//  errorDialog(e);
    //}

    if (fromSwitch) {
      setState(() {
        currentlyLoading = false;
      });
    }
    else {
      setState(() {});
    }
  }

  loadPreferences() async {
    String uri = 'https://$connectionId/api/ffd/preferences';

    final prefs = await SharedPreferences.getInstance();
    final String groupBySelection = prefs.get('groupBySelection') ?? '';

    print("FOUND PREFERENCE: $groupBySelection");

    if(groupBySelection.length > 0){
      groupByArgument = groupBySelection;
    }

    print(uri);

    var params = {
      "accesstoken": token,
    };

    try {
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
    } catch (e) {
      errorDialog(e);
    }
  }

  loadHomescreen(bool fromSwitch) async {
    int level_type = -1;
    int cost_type = -1;
    int parent_account = -1;
    int day = -1;
    int year = dateTimeHome.year;
    int month = showFullYearHome ? -1 : dateTimeHome.month;

    // #98
    DateTime comparisonDate =
    new DateTime(dateTimeHome.year, dateTimeHome.month - 1, 1);
    // Get the current date
    DateTime now = DateTime.now();

    // If full year should be shown, compare also here with full last year, else use the year calculated
    int comparisonYear =
    showFullYearHome ? dateTimeHome.year - 1 : comparisonDate.year;
    int comparisonMonth = showFullYearHome ? -1 : comparisonDate.month;

    print("Shown date: $year/$month");
    print("Compared date: $comparisonYear/$comparisonMonth");
    print("Compared date: $comparisonDate");

    String _type = 'actual';

    var params = {
      "accesstoken": token,
    };

    print(token);

    try {
      var actual = await http.read(
          'https://$connectionId/api/ffd/amounts/?level_type=$level_type&cost_type=$cost_type&parent_account=$parent_account&year=$year&month=$month&day=$day&_type=$_type&groupBy=Accounts',
          headers: params);

      var actualComparison = await http.read(
          'https://$connectionId/api/ffd/amounts/?level_type=$level_type&cost_type=$cost_type&parent_account=$parent_account&year=$comparisonYear&month=$comparisonMonth&day=$day&_type=$_type&groupBy=Accounts',
          headers: params);

      _type = 'budget';

      var budget = await http.read(
          'https://$connectionId/api/ffd/amounts/?level_type=$level_type&cost_type=$cost_type&parent_account=$parent_account&year=$year&month=$month&day=$day&_type=$_type&groupBy=Accounts',
          headers: params);

      var budgetComparison = await http.read(
          'https://$connectionId/api/ffd/amounts/?level_type=$level_type&cost_type=$cost_type&parent_account=$parent_account&year=$comparisonYear&month=$comparisonMonth&day=$day&_type=$_type&groupBy=Accounts',
          headers: params);

      var parsedActual = json.decode(actual);
      var parsedActualComparisonList = json.decode(actualComparison);

      var parsedBudget = json.decode(budget);
      var parsedBudgetComparisonList = json.decode(budgetComparison);

      parsedActualComparison = calculateRelativeComparison(
          parsedActualComparisonList.length != 0
              ? parsedActualComparisonList[0]['sum'].toDouble()
              : 0,
          comparisonYear,
          comparisonMonth,
          (dateTimeHome.year == now.year && dateTimeHome.month == now.month));

      parsedBudgetComparison = parsedBudgetComparisonList.length != 0
          ? parsedBudgetComparisonList[0]['sum'].toDouble()
          : 99;

      /*parsedBudgetComparison = calculateRelativeComparison(
          parsedBudgetComparisonList.length != 0
              ? parsedBudgetComparisonList[0]['sum']
              : 99,
          comparisonYear,
          comparisonMonth,
          (dateTimeHome.year == now.year && dateTimeHome.month == now.month));*/

      String noDataFoundText = AppLocalizations.of(context).translate(
          'noDataFoundText');

      homescreenData[0].amount =
      parsedActual.length != 0 ? parsedActual[0]['sum'].toDouble() : 0;
      homescreenData[0].type = parsedActual.length != 0
          ? AppLocalizations.of(context).translate('titleExpenses')
          : "$noDataFoundText $year/${month.toString().padLeft(1, '0')}";
      homescreenData[0].color =
          charts.ColorUtil.fromDartColor(Color(0xff003680));

      homescreenData[1].amount = parsedBudget.length != 0
          ? parsedBudget[0]['sum'].toDouble() - homescreenData[0].amount
          : 99;
      homescreenData[1].type = parsedBudget.length != 0
          ? AppLocalizations.of(context).translate('titleBudget')
            : "$noDataFoundText $year/${month.toString().padLeft(1, '0')}";
      homescreenData[1].color =
          charts.ColorUtil.fromDartColor(Color(0xff0957FF));

      homescreenData[2].amount =
      parsedBudget.length != 0 ? parsedBudget[0]['sum'].toDouble() : 0.000001;
      homescreenData[2].type = parsedBudget.length != 0
          ? AppLocalizations.of(context).translate('overallBudget')
          : "$noDataFoundText $year/${month.toString().padLeft(1, '0')}";

      // #118
      if (homescreenData[1].amount < 0) // means no budget left
          {
        // homescreenData[0].amount = homescreenData[2].amount;
        // homescreenData[1].amount = 0;

        homescreenData[0].color =
            charts.ColorUtil.fromDartColor(Color(0xffb71c1c));
        homescreenData[1].color =
            charts.ColorUtil.fromDartColor(Color(0xffdd2c00));
      }

      print(
          "Comparison ACTUAL $parsedActualComparison vs ${homescreenData[0]
              .amount}");
      print(
          "Comparison BUDGET $parsedBudgetComparison vs ${homescreenData[2]
              .amount}");
    } catch (e) {
      errorDialog(e);
    }

    if (fromSwitch) {
      setState(() {
        currentlyLoading = false;
      });
    }
    else {
      setState(() {

      });
    }
  }

  double calculateRelativeComparison(amount, year, month, actualOrHistoric
      /* Are we comparing this month data or historic months data*/) {
    // Check how many percent of the year (when month = -1)/ month (when month does not equal -1) has gone by and return the relative amount
    DateTime today = DateTime.now();
    DateTime comparisonDate = DateTime(year, month, 1);

    // Calculate variance by month
    if (month > 0) {
      // Get the last day of the previous month (comparisonDate Month since we add 1 month to the comparison Date e.g. 2013,3,0 = 28 of February)
      int lastDay =
          DateTime(comparisonDate.year, comparisonDate.month + 1, 0).day;
      double percentOfMonth = today.day / lastDay;

      print("Last month amount: $amount");
      print("Comparing actual data: $actualOrHistoric");
      print("How much percent of the month has passed: $percentOfMonth");
      print("Todays day: ${today.day}");
      print("Last day of the last month: $lastDay");

      // If we are loading actual data (current month), multiply by percent else return the same value as we compare absolute values of finished months (historic months)
      return num.parse((amount * (actualOrHistoric ? percentOfMonth : 1))
          .toStringAsFixed(2));
    }
    // Calculate variance by year
    else {
      double percentOfYear = comparisonDate.month / 12;

      // If we are loading actual data, multiply by percent else return the same value as we compare absolute values of finished months
      return num.parse(
          (amount * (actualOrHistoric ? percentOfYear : 1)).toStringAsFixed(2));
    }
  }

  _showLoadWidget() {
    return Center(
        child: SpinKitFadingCube(
          //color: Color(0xff0957FF),
          color: Color(
              0xff2B2B2B),
          size: 100.0,));
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

    try {
      if (fetch || onStartup) {
        level1AccountsJson = await http.read(
            'https://$connectionId/api/ffd/accounts/1',
            headers: params);
        level2AccountsJson = await http.read(
            'https://$connectionId/api/ffd/accounts/2',
            headers: params);
        level3AccountsJson = await http.read(
            'https://$connectionId/api/ffd/accounts/3',
            headers: params);
        costTypesJson = await http.read(
            'https://$connectionId/api/ffd/costtypes/',
            headers: params);

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
          }
          /* Removed as part of #89
          else {
            existingItem = level1AccountsList.firstWhere(
                    (itemToCheck) => itemToCheck.id == accountToAdd.id,
                orElse: () => null);
          }*/

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
          }
          /* Removed as part of #89else {
            existingItem = level2AccountsList.firstWhere(
                    (itemToCheck) => itemToCheck.id == accountToAdd.id,
                orElse: () => null);
          }*/

          accountsListStating.add(accountToAdd);

          if (existingItem == null) {
            if (type == 'actual' || onStartup) {
              // If there is already an level1 account selected, only add the ones which have the correct parentAccount
              if (level1ActualObject.id > 0) {
                if (accountToAdd.parentAccount == level1ActualObject.id) {
                  level2ActualAccountsList.add(accountToAdd);
                }
              } else {
                level2ActualAccountsList.add(accountToAdd);
              }
            }
            if (type == 'budget' || onStartup) {
              // If there is already an level1 account selected, only add the ones which have the correct parentAccount
              if (level1BudgetObject.id > 0) {
                if (accountToAdd.parentAccount == level1BudgetObject.id) {
                  level2BudgetAccountsList.add(accountToAdd);
                }
              } else {
                level2BudgetAccountsList.add(accountToAdd);
              }
            }
            if (type == 'admin' || onStartup) {
              // If there is already an level1 account selected, only add the ones which have the correct parentAccount
              if (level1AdminObject.id > 0) {
                if (accountToAdd.parentAccount == level1AdminObject.id) {
                  level2AdminAccountsList.add(accountToAdd);
                }
              } else {
                level2AdminAccountsList.add(accountToAdd);
              }
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
          }
          /* Removed as part of #89 else {
            existingItem = level3AccountsList.firstWhere(
                    (itemToCheck) => itemToCheck.id == accountToAdd.id,
                orElse: () => null);
          }*/

          accountsListStating.add(accountToAdd);

          if (existingItem == null) {
            level3AccountsList.add(accountToAdd);

            if (level2ActualObject.id > 0) {
              if (level2ActualObject.id == accountToAdd.parentAccount) {
                level3ActualAccountsList.add(accountToAdd);
              }
            } else {
              level3ActualAccountsList.add(accountToAdd);
            }

            if (level2BudgetObject.id > 0) {
              if (level2BudgetObject.id == accountToAdd.parentAccount) {
                level3BudgetAccountsList.add(accountToAdd);
              }
            } else {
              level3BudgetAccountsList.add(accountToAdd);
            }

            if (level2AdminObject.id > 0) {
              if (level2AdminObject.id == accountToAdd.parentAccount) {
                level3AdminAccountsList.add(accountToAdd);
              }
            } else {
              level3AdminAccountsList.add(accountToAdd);
            }
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
    } catch (e) {
      errorDialog(e);
    }
  }

  void sendBackend(String type, bool onStartup) async {
    // #60
    setState(() {
      currentlyLoading = true;
    });

    var url = 'https://$connectionId/api/ffd/';
    String _token = token;

    // Whenever with the backend is communicated its best to reload the accounts and costtpyes
    if (type.contains('add') || type.contains('delete'))
      fetchAccountsAndCostTypes = true;

    // Are here in case needed sometimes later
    var params = {
      "accesstoken": _token,
    };

    print("OFFSET: ${DateTime
        .now()
        .timeZoneOffset
        .inMinutes}");

    var body = {
      'type': type,
      'amount': type == 'actual' || type == 'actualschedule'
          ? actualTextFieldController.text
          : budgetTextFieldController.text,
      'actualcomment': actualCommentTextFieldController.text == '' ? '-' : actualCommentTextFieldController.text,
      'budgetcomment': budgetCommentTextFieldController.text == '' ? '-' : budgetCommentTextFieldController.text,
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
      'day': type == 'actual'
          ? dateTimeActual.day.toString()
          : dateTimeBudget.day.toString(),
      'timezoneOffsetMin': DateTime
          .now()
          .timeZoneOffset
          .inMinutes
          .toString(),
      // In Minutes for timezones which are half an hour shifted, like e.g. in India
      'timeInUtc': DateTime.now().toUtc().toIso8601String(),
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
      'accountfornewlevel2parentaccount': level1AdminObject.id.toString(),
      // ID of the selected level2 object, to match the parentID
      'accountfornewlevel3parentaccount': level2AdminObject.id.toString(),
      // ID of the selected level2 object, to match the parentID - not needed for level1 as level1s have no parent
      'arecosttypesactive': areCostTypesActive.toString(),
      'areaccountsactive': areAccountsActive.toString(),
      'arelevel1accountsactive': areLevel1AccountsActive.toString(),
      'arelevel2accountsactive': areLevel2AccountsActive.toString(),
      'arelevel3accountsactive': areLevel3AccountsActive.toString(),
      'actlistitemtodelete': actObjectToDelete.id.toString(),
      'bdglistitemtodelete': bdgObjectToDelete.id.toString(),
      'scheduleYear': scheduleYear.toString(),
      'scheduleMonth': scheduleMonth.toString(),
      'scheduleWeek': scheduleWeek.toString(),
      'scheduleDay': scheduleDay.toString(),
      'scheduleInterval': scheduleAmountTextFieldController.text,
      'status': 'IP',
      'mailFrontend': email,
      'group': '-1',
      'company': '-1'
    };

    print(url);
    print(body);
    print(dateTimeActual.day.toString());

    var response = await http.post(url, body: body, headers: params);

    if (!onStartup) {
      showCustomDialog(
          _currentIndex,
          response.statusCode == 200 ? 'success' : 'error',
          response.statusCode);
      print(response.statusCode);
    }

    // When an entry was deleted or restored, or a new entry was made in the input page
    if (type == 'actlistdelete' || type == 'actual' ||
        type == 'actualschedule') {
      loadList('actual', actualListSortColumn, actualListSortType);
      loadHomescreen(false);
      loadAmount(false);

      actualTextFieldController.clear();

      if (scheduleEntries) {
        showScheduleDialog(type);
        scheduleEntries = false;
      }
    } else if (type == 'bdglistdelete' || type == 'budget' ||
        type == 'budgetschedule') {
      loadList('budget', budgetListSortColumn, budgetListSortType);
      loadHomescreen(false);
      loadAmount(false);

      if (scheduleEntries) {
        showScheduleDialog(type);
        scheduleEntries = false;
      }
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

    clearCommentTextFields();
    // #60
    setState(() {
      currentlyLoading = false;
    });
  }

  showScheduleDialog(String type) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Center(
                    child: RichText(
                      text: TextSpan(
                          text: AppLocalizations.of(context).translate(
                              'enterAgain'),
                          style: GoogleFonts.lato(fontSize: 18, color:Color(
                              0xff2B2B2B), fontWeight: FontWeight.bold ),
                          children: <TextSpan>[
                            TextSpan(
                              text: AppLocalizations.of(context).translate(
                                  ''),
                              style:
                              GoogleFonts.lato(color: Color(0xFF0957FF), fontSize: 18),
                            )
                          ]),
                    ),
                  ),
                  content: LayoutBuilder(
                      builder: (context, constraint) {
                        return SingleChildScrollView(
                            child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minHeight: constraint.minHeight),
                                child: IntrinsicHeight(
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: <Widget>[
                                          Text(
                                            AppLocalizations.of(context)
                                                .translate(
                                                'forTheNext'),
                                            maxLines: 3,
                                            textAlign: TextAlign.left,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.lato(
                                                color: Colors.grey[800],
                                                fontWeight: FontWeight.w900,
                                                fontSize: 15),
                                          ),
                                          Flexible(
                                              child: TextFormField(
                                                keyboardType:
                                                TextInputType.number,
                                                //keyboard with numbers only will appear to the screen
                                                style: TextStyle(
                                                    height: 2),
                                                controller:
                                                scheduleAmountTextFieldController,
                                                decoration: InputDecoration(
                                                  // hintText: 'Enter ur amount',
                                                  //hintStyle: TextStyle(height: 1.75),
                                                    labelText: AppLocalizations
                                                        .of(context)
                                                        .translate(
                                                        'scheduleExample'),
                                                    labelStyle: TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                    //increases the height of cursor
                                                    //prefixIcon: Icon(Icons.attach_money),
                                                    //labelStyle: TextStyle(color: Color(0xff0957FF)),
                                                    enabledBorder:
                                                    new UnderlineInputBorder()),
                                              )),
                                          SizedBox(height: 10,),
                                          Text(
                                            AppLocalizations.of(context)
                                                .translate(
                                                'interval'),
                                            maxLines: 3,
                                            textAlign: TextAlign.left,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.lato(
                                                color: Colors.grey[800],
                                                fontWeight: FontWeight.w900,
                                                fontSize: 15),
                                          ),
                                          Row(
                                            children: <Widget>[Switch(
                                              value: scheduleYear,
                                              onChanged: (value) {
                                                setState(() {
                                                  scheduleMonth = false;
                                                  scheduleWeek = false;
                                                  scheduleDay = false;
                                                  scheduleYear = value;
                                                });
                                              },
                                              activeTrackColor: Color(
                                                  0xffEEEEEE),
                                              activeColor: Color(0xff0957FF),
                                            ),
                                              Text(
                                                AppLocalizations.of(context)
                                                    .translate(
                                                    'year'),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.lato(
                                                    color: Colors.grey[800],
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 15),
                                              )
                                            ],),
                                          Row(
                                            children: <Widget>[
                                              Switch(
                                                value: scheduleMonth,
                                                onChanged: (value) {
                                                  setState(() {
                                                    scheduleYear = false;
                                                    scheduleWeek = false;
                                                    scheduleDay = false;

                                                    scheduleMonth = value;
                                                  });
                                                },
                                                activeTrackColor: Color(
                                                    0xffEEEEEE),
                                                activeColor: Color(0xff0957FF),
                                              ),
                                              Text(
                                                AppLocalizations.of(context)
                                                    .translate(
                                                    'month'),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.lato(
                                                    color: Colors.grey[800],
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 15),
                                              )
                                            ],),
                                          Row(
                                            children: <Widget>[Switch(
                                              value: scheduleWeek,
                                              onChanged: (value) {
                                                setState(() {
                                                  scheduleYear = false;
                                                  scheduleMonth = false;
                                                  scheduleDay = false;

                                                  scheduleWeek = value;
                                                });
                                              },
                                              activeTrackColor: Color(
                                                  0xffEEEEEE),
                                              activeColor: Color(0xff0957FF),
                                            ),
                                              Text(
                                                AppLocalizations.of(context)
                                                    .translate(
                                                    'week'),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.lato(
                                                    color: Colors.grey[800],
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 15),
                                              )
                                            ],)
                                          ,
                                          Row(
                                            children: <Widget>[
                                              Switch(
                                                value: scheduleDay,
                                                onChanged: (value) {
                                                  setState(() {
                                                    scheduleYear = false;
                                                    scheduleMonth = false;
                                                    scheduleWeek = false;

                                                    scheduleDay = value;
                                                  });
                                                },
                                                activeTrackColor: Color(
                                                    0xffEEEEEE),
                                                activeColor: Color(0xff0957FF),
                                              ),
                                              Text(
                                                AppLocalizations.of(context)
                                                    .translate(
                                                    'day'),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.lato(
                                                    color: Colors.grey[800],
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 15),
                                              ),

                                            ],),

                                        ])))
                        );
                      }),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text(
                          AppLocalizations.of(context).translate('cancel'), style: GoogleFonts.lato(),),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    new Container(
                      margin: EdgeInsets.only(
                          left: 2, right: 2, bottom: 10),
                      child: ConfirmationSlider(
                        text: AppLocalizations.of(context).translate(
                            'slideToConfirm'),
                        foregroundColor: Color(
                            0xff0957FF),
                        onConfirmation: () {
                          if (scheduleAmountTextFieldController.text.length >
                              0 &&
                              numberValidator(
                                  scheduleAmountTextFieldController.text) ==
                                  null &&
                              (scheduleYear || scheduleMonth || scheduleWeek ||
                                  scheduleDay) &&
                              int.parse(
                                  scheduleAmountTextFieldController.text) <
                                  100) {
                            if (type == 'actual') {
                              sendBackend('actualschedule', false);
                            } else if (type == 'budget') {
                              sendBackend('budgetschedule', false);
                            }

                            Navigator.of(context).pop();
                          } else {
                            String errorMessage = scheduleAmountTextFieldController
                                .text.length == 0
                                ? 'errorInputEnterAmount'
                                : (numberValidator(
                                scheduleAmountTextFieldController.text) != null
                                ? 'errorInputInvalidAmount'
                                : (!(scheduleYear || scheduleMonth ||
                                scheduleWeek || scheduleWeek)
                                ? 'errorInputNoScheduleSelected'
                                : 'errorInputToBigSchedule'));

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                // return object of type Dialog
                                return AlertDialog(
                                  title: new Text(
                                    AppLocalizations
                                        .of(
                                        context)
                                        .translate(
                                        'warning')
                                    ,
                                    style: GoogleFonts.lato(
                                        color: Colors
                                            .orange,
                                        fontSize: 25,
                                        fontWeight: FontWeight
                                            .bold),),
                                  content: new Text(
                                    AppLocalizations
                                        .of(
                                        context)
                                        .translate(
                                        errorMessage),
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight
                                            .bold,
                                        fontSize: 20),),
                                  actions: <
                                      Widget>[
                                    // usually buttons at the bottom of the dialog
                                    new FlatButton(
                                      child: new Text(
                                          "Close", style: GoogleFonts.lato(),),
                                      onPressed: () {
                                        Navigator
                                            .of(
                                            context)
                                            .pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                    /*new FlatButton(
                      child: new Text(
                          AppLocalizations.of(context).translate('addButton')),
                      onPressed: () {
                        if (scheduleAmountTextFieldController.text.length > 0 &&
                            numberValidator(
                                scheduleAmountTextFieldController.text) ==
                                null &&
                            (scheduleYear || scheduleMonth || scheduleWeek ||
                                scheduleWeek) &&
                            int.parse(scheduleAmountTextFieldController.text) <
                                100) {
                          if (type == 'actual') {
                            sendBackend('actualschedule', false);
                          } else if (type == 'budget') {
                            sendBackend('budgetschedule', false);
                          }

                          Navigator.of(context).pop();
                        } else {
                          String errorMessage = scheduleAmountTextFieldController
                              .text.length == 0
                              ? 'errorInputEnterAmount'
                              : (numberValidator(
                              scheduleAmountTextFieldController.text) != null
                              ? 'errorInputInvalidAmount'
                              : (!(scheduleYear || scheduleMonth ||
                              scheduleWeek || scheduleWeek)
                              ? 'errorInputNoScheduleSelected'
                              : 'errorInputToBigSchedule'));

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // return object of type Dialog
                              return AlertDialog(
                                title: new Text(
                                  AppLocalizations
                                      .of(
                                      context)
                                      .translate(
                                      'warning')
                                  ,
                                  style: TextStyle(
                                      color: Colors
                                          .orange,
                                      fontSize: 25,
                                      fontWeight: FontWeight
                                          .bold),),
                                content: new Text(
                                  AppLocalizations
                                      .of(
                                      context)
                                      .translate(
                                      errorMessage),
                                  style: TextStyle(
                                      fontWeight: FontWeight
                                          .bold,
                                      fontSize: 20),),
                                actions: <
                                    Widget>[
                                  // usually buttons at the bottom of the dialog
                                  new FlatButton(
                                    child: new Text(
                                        "Close"),
                                    onPressed: () {
                                      Navigator
                                          .of(
                                          context)
                                          .pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),*/
                  ],
                );
              });
        });
  }

  clearCommentTextFields() {
    // #117
    newAccountLevel1CommentTextFieldController.clear();
    newAccountLevel2CommentTextFieldController.clear();
    newAccountLevel3CommentTextFieldController.clear();
    newCostTypeCommentTextFieldController.clear();
    actualCommentTextFieldController.clear();
    budgetCommentTextFieldController.clear();
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
  void _showDatePicker(String type, DateTime actualOrBudgetOrVisualizer) async {
    DatePicker.showDatePicker(
      context,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
        confirm: Text(AppLocalizations.of(context).translate('saveButton'),
            style: GoogleFonts.lato(color: Color(0xff0957FF))),
        cancel: Text(AppLocalizations.of(context).translate('cancel'),
            style: GoogleFonts.lato(color: Colors.grey)),
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
            currentlyLoading = true;
            dateTimeHome = dateTime;

            loadHomescreen(true);
          } else if (type == 'actual') {
            dateTimeActual = dateTime;
          } else if (type == 'budget') {
            dateTimeBudget = dateTime;
          } else if (type == 'visualizer') {
            currentlyLoading = true;

            loadAmount(true);
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
                  CircleAvatar(
                    backgroundImage: imageUrl != null ? NetworkImage(
                      imageUrl,
                    ) : AssetImage("assets/user.png"),
                    radius: 60,
                    backgroundColor: Colors.transparent,
                  ),
                ]),
            // set your own image/icon widget
            title: name,
            description: email,
            submitButton: AppLocalizations.of(context).translate(
                'submitButton'),
            alternativeButton: AppLocalizations.of(context).translate(
                'contactUs'),
            // optional
            positiveComment: AppLocalizations.of(context).translate(
                'happyText'),
            // optional
            negativeComment: AppLocalizations.of(context).translate('sadText'),
            // optional
            accentColor: Color(0xff003680),
            // optional
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
              AppLocalizations.of(context).translate('name'),
              style: GoogleFonts.lato(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(
                      0xff2B2B2B)),
            ),
            Text(
              name,
              style: GoogleFonts.lato(
                  fontSize: 25,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).translate('email'),
              style: GoogleFonts.lato(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(
                      0xff2B2B2B)),
            ),
            Text(
              email,
              style: GoogleFonts.lato(
                  fontSize: 25,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            RaisedButton(
              onPressed: () {
                signOut();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) {
                      return LoginPage();
                    }), ModalRoute.withName('/'));
              },
              color: Colors.deepPurple,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  AppLocalizations.of(context).translate('signOut'),
                  style: GoogleFonts.lato(fontSize: 25, color: Colors.white),
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

  errorDialog(e) {
    if (!errorDialogActive) {
      errorDialogActive = true;

      showDialog(
        context: context,
        builder: (context) =>
        new AlertDialog(
          title: Text(
            "${AppLocalizations.of(context).translate('error')} - ${e
                .runtimeType}",
            style: GoogleFonts.lato(
                color: Color(
                    0xff2B2B2B), fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: RichText(
            text: TextSpan(
                text:
                AppLocalizations.of(context).translate('errorMessage'),
                style: GoogleFonts.lato(
                  color: Color(
                      0xff2B2B2B),
                  fontSize: 15,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '\n\n$e',
                    style: GoogleFonts.lato(color: Colors.red, fontSize: 10),
                  )
                ]),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                  AppLocalizations.of(context).translate('dismissDialog')),
              onPressed: () {
                Navigator.of(context).pop();
                errorDialogActive = false;
              },
            ),
            new FlatButton(
              child: new Text(
                  AppLocalizations.of(context).translate('signOut'), style: GoogleFonts.lato(),),

              onPressed: () {
                errorDialogActive = false;

                signOut();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) {
                      return LoginPage();
                    }), ModalRoute.withName('/'));
              },
            )
          ],
        ),
      );
    } else {
      print("ERRORDIALOG already active - $errorDialogActive");
    }
  }

  commentInput(BuildContext context,
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
      if (type == 'actual' || type == 'budget') {
        await showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: Center(
                        child: RichText(
                          text: TextSpan(
                              text: AppLocalizations.of(context).translate(
                                  'commentEnterDialog'),
                              style: GoogleFonts.lato(
                                  color: Color(
                                      0xff2B2B2B),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              children: <TextSpan>[
                                TextSpan(
                                  text: '$level1OrCostTypeName',
                                  style:
                                  GoogleFonts.lato(
                                      color: Color(0xFF0957FF), fontSize: 18),
                                )
                              ]),
                        ),
                      ),
                      content: SingleChildScrollView(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceAround,
                              children: <Widget>[
                                TextField(
                                  controller: dependingController,
                                  decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)
                                          .translate(
                                          'comment')),
                                  maxLength: 50,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
                                  children: <Widget>[
                                    Switch(
                                      value: scheduleEntries,
                                      onChanged: (value) {
                                        print("SETTING SWTICH TO $value");

                                        setState(() {
                                          scheduleEntries = value;
                                        });
                                      },
                                      activeTrackColor: Color(
                                          0xffEEEEEE),
                                      activeColor: Color(0xff0957FF),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * .4,
                                          child: Text(
                                            AppLocalizations.of(context)
                                                .translate(
                                                'scheduleSwitch'),
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.lato(
                                                color: Colors.grey[800],
                                                fontWeight: FontWeight.w900,
                                                fontSize: 15),
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        final snackBar = SnackBar(content: Text(
                                            AppLocalizations.of(context)
                                                .translate(
                                                'scheduleSwitchTooltip'), style: GoogleFonts.lato()));

                                        // Find the Scaffold in the widget tree and use it to show a SnackBar.
                                        _scaffoldKey.currentState.showSnackBar(snackBar);
                                      },
                                      child: Icon(Icons.info),)
                                  ],)
                              ])),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text(
                              AppLocalizations.of(context).translate('cancel'), style: GoogleFonts.lato()),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        new Container(
                          margin: EdgeInsets.only(
                              left: 2, right: 2, bottom: 0),
                          child: ConfirmationSlider(
                            text: AppLocalizations.of(context).translate(
                                'slideToConfirm'),
                            foregroundColor: Color(
                                0xff0957FF),
                            onConfirmation: () {
                              if (type == 'actual') {
                                sendBackend('actual', false);
                              } else if (type == 'budget') {
                                sendBackend('budget', false);
                              }

                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        /*new FlatButton(
                    child: new Text(
                        AppLocalizations.of(context).translate('addButton')),
                    onPressed: () {
                      if (type == 'actual') {
                        sendBackend('actual', false);
                      } else if (type == 'budget') {
                        sendBackend('budget', false);
                      }

                      Navigator.of(context).pop();
                    },
                  ),*/
                      ],
                    );
                  });
            });
      } else {
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Center(
                  child: RichText(
                    text: TextSpan(
                        text: AppLocalizations.of(context).translate(
                            'commentEnterDialog'),
                        style: GoogleFonts.lato(
                            color: Color(
                                0xff2B2B2B),
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
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).translate(
                          'comment')),
                  maxLength: 50,
                ),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text(
                        AppLocalizations.of(context).translate('cancel'), style: GoogleFonts.lato()),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  /*new FlatButton(
                    child: new Text(
                        AppLocalizations.of(context).translate('skip')),
                    onPressed: () {
                      if (type != 'account') {
                        sendBackend('new${type}add', false);
                      } else if (dependingController2.text.length <= 0) {
                        sendBackend('new${type}add', false);
                      }

                      Navigator.of(context).pop();
                    },
                  ),*/
                  new Container(
                    margin: EdgeInsets.only(
                        left: 2, right: 2, bottom: 10),
                    child: ConfirmationSlider(
                      text: AppLocalizations.of(context).translate(
                          'slideToConfirm'),
                      foregroundColor: Color(
                          0xff0957FF),
                      onConfirmation: () {
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
                  ),

                  /*new FlatButton(
                    child: new Text(
                        AppLocalizations.of(context).translate('addButton')),
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
                  ),*/
                ],
              );
            });
      }
    } else {
      print("No comment for new level1 needed");
    }

    if (dependingController2 != null && dependingController2.text.length > 0) {
      print("trying to input comment for level 2");

      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Center(
                child: RichText(
                  text: TextSpan(
                      text: AppLocalizations.of(context).translate(
                          'commentEnterDialog'),
                      style: GoogleFonts.lato(
                          color: Color(
                              0xff2B2B2B),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${dependingController2.text}',
                          style:
                          GoogleFonts.lato(color: Color(0xff73D700), fontSize: 18),
                        )
                      ]),
                ),
              ),
              content: TextField(
                controller: newAccountLevel2CommentTextFieldController,
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate(
                        'comment')),
                maxLength: 50,
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text(
                      AppLocalizations.of(context).translate('cancel'), style: GoogleFonts.lato()),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                // #158
                /*new FlatButton(
                  child: new Text(
                      AppLocalizations.of(context).translate('skip')),
                  onPressed: () {
                    // Send directly to backend if no additional level3 was entered which has to be saved in the Backend -> DB
                    if (dependingController3.text.length <= 0) {
                      sendBackend('new${type}add', false);
                    }

                    Navigator.of(context).pop();
                  },
                ),*/
                new Container(
                  margin: EdgeInsets.only(
                      left: 2, right: 2, bottom: 10),
                  child: ConfirmationSlider(
                    text: AppLocalizations.of(context).translate(
                        'slideToConfirm'),
                    foregroundColor: Color(
                        0xff0957FF),
                    onConfirmation: () {
                      // Send directly to backend if no additional level3 was entered which has to be saved in the Backend -> DB
                      if (dependingController3.text.length <= 0) {
                        sendBackend('new${type}add', false);
                      }

                      Navigator.of(context).pop();
                    },
                  ),
                ),
                /*new FlatButton(
                  child: new Text(
                      AppLocalizations.of(context).translate('addButton')),
                  onPressed: () {
                    // Send directly to backend if no additional level3 was entered which has to be saved in the Backend -> DB
                    if (dependingController3.text.length <= 0) {
                      sendBackend('new${type}add', false);
                    }

                    Navigator.of(context).pop();
                  },
                ),*/
              ],
            );
          });
    } else {
      print("skipped input of level 2");
    }

    if (dependingController3 != null && dependingController3.text.length > 0) {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Center(
                child: RichText(
                  text: TextSpan(
                      text: AppLocalizations.of(context).translate(
                          'commentEnterDialog'),
                      style: GoogleFonts.lato(
                          color: Color(
                              0xff2B2B2B),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${dependingController3.text}',
                          style:
                          GoogleFonts.lato(color: Color(0xffDB002A), fontSize: 18),
                        )
                      ]),
                ),
              ),
              content: TextField(
                controller: newAccountLevel3CommentTextFieldController,
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate(
                        'comment')),
                maxLength: 50,
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text(
                      AppLocalizations.of(context).translate('cancel'), style: GoogleFonts.lato()),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                // 158
                /*new FlatButton(
                  child: new Text(
                      AppLocalizations.of(context).translate('skip')),
                  onPressed: () {
                    sendBackend('new${type}add', false);

                    Navigator.of(context).pop();
                  },
                ),*/
                new Container(
                  margin: EdgeInsets.only(
                      left: 2, right: 2, bottom: 10),
                  child: ConfirmationSlider(
                    text: AppLocalizations.of(context).translate(
                        'slideToConfirm'),
                    foregroundColor: Color(
                        0xff0957FF),
                    onConfirmation: () {
                      sendBackend('new${type}add', false);

                      Navigator.of(context).pop();
                    },
                  ),
                ),
                /*
                new FlatButton(
                  child: new Text(
                      AppLocalizations.of(context).translate('saveButton')),
                  onPressed: () {
                    sendBackend('new${type}add', false);

                    Navigator.of(context).pop();
                  },
                ),*/
              ],
            );
          });
    }


    // #147 restricted to only accounts, because only accounts have the explanation dialog
    if (type == 'account') {
      // Test #145 - works perfect, closes the accountInputExplainDialog (showing in the background) after all comments were entered
      Navigator.of(context, rootNavigator: true).pop();
      //Navigator.of(context, rootNavigator: false).pop();
    }
  }

  getHelpTextByIndex(int index) {
    return AppLocalizations.of(context).translate('page${index}HelpMessage');
  }

  helpDialog(int index) {
    String helpText = getHelpTextByIndex(index);
    showDialog(
        context: context,
        barrierDismissible: false,
        //context: _scaffoldKey.currentContext,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Center(
                child: Text(AppLocalizations.of(context).translate('info'), style: GoogleFonts.lato())),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.50,
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.50,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                        helpText, style: GoogleFonts.lato()
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text(
                    AppLocalizations.of(context).translate('confirm'), style: GoogleFonts.lato()),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });


    /*showDialog(
        context: context,
        barrierDismissible: true, // set to false if you want to force a rating
        builder: (context) {
          return AlertDialog(
            title: Text('Very, very large title', textScaleFactor: 5),
            content: Text('Very, very large content', textScaleFactor: 5),
            actions: <Widget>[
              FlatButton(child: Text('Button 1'), onPressed: () {}),
              FlatButton(child: Text('Button 2'), onPressed: () {}),
            ],
          );
          /*RatingDialog(
            icon: Icon(Icons.help, size: 15,),
            // set your own image/icon widget
            title: helpText,
            description:
            AppLocalizations.of(context).translate('wasGoodMessage'),
            submitButton: AppLocalizations.of(context).translate('submitButton'),
            alternativeButton: AppLocalizations.of(context).translate('contactUs'),
            // optional
            positiveComment: AppLocalizations.of(context).translate('happyText'),
            // optional
            negativeComment: AppLocalizations.of(context).translate('sadText'),
            // optional
            accentColor: Color(0xff0957FF),
            // optional
            onSubmitPressed: (int rating) {
              print("onSubmitPressed: rating = $rating");
              // TODO: open the app's page on Google Play / Apple App Store
            },
            onAlternativePressed: () {
              print("onAlternativePressed: do something");
              // TODO: maybe you want the user to contact you instead of rating a bad review
            },
          );*/
        });*/
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
            icon: icon,
            // set your own image/icon widget
            title: "${AppLocalizations.of(context).translate('code')}: $code",
            description:
            AppLocalizations.of(context).translate('ratingMessage'),
            submitButton: AppLocalizations.of(context).translate(
                'submitButton'),
            alternativeButton: AppLocalizations.of(context).translate(
                'contactUs'),
            // optional
            positiveComment: AppLocalizations.of(context).translate(
                'happyText'),
            // optional
            negativeComment: AppLocalizations.of(context).translate('sadText'),
            // optional
            accentColor: color,
            // optional
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

  handleRefresh(index) async {
    if (_currentIndex == 0) {
      await loadHomescreen(false);
    } else if (_currentIndex == 1) {
      // Test for #83
      setState(() {
        print("SETTING STATE");
        print(level1ActualObject.name);
        print(level2ActualObject.name);
        print(level3ActualObject.name);
      });

      await checkForChanges(false, true, 'actual');
      await loadList('actual', actualListSortColumn, actualListSortType);
    } else if (_currentIndex == 2) {
      await checkForChanges(false, true, 'budget');
      await loadList('budget', budgetListSortColumn, budgetListSortType);
    } else if (_currentIndex == 3) {
      await loadAmount(false);
      print("FINISHED LOADING");
    } else if (_currentIndex == 4) {
      await checkForChanges(false, true, 'admin');
      await loadPreferences();
    }
  }

  onCardTapped(int position) {
    print('Card $position tapped');
  }

  _onSelectionChanged(charts.SelectionModel model) async {

    final prefs = await SharedPreferences.getInstance();

    print("data is currently grouped by: $groupByArgument");

    final selectedDatum = model.selectedDatum;
    final selectedDatum2 = model.selectedSeries;

    if (groupByArgument == 'Year' || groupByArgument == 'Month') {
      // #185 When year is selected switch to group by month, when month to by day
      int currentlySelectedGroupByValue = groupByVisualizerOptions.indexWhere((
          element) => element);
      int toSelectGroupByValue = groupByVisualizerOptions.indexWhere((
          element) => element) + 1;

      groupByVisualizerOptions[currentlySelectedGroupByValue] = false;
      groupByVisualizerOptions[toSelectGroupByValue] = true;
    }

    if (groupByArgument == 'Year') {
      print("CLICKED: ${selectedDatum[0]}");

      DateTime newDate = DateTime(int.parse(
          selectedDatum[0].datum.accountName.toString().split("-")[0]));

      dateTimeVisualizer = newDate;
      groupByArgument = 'Month';


    }
    else if (groupByArgument == 'Month') {
      print("CLICKED: ${selectedDatum[0].datum.accountName}");

      DateTime newDate = DateTime(int.parse(
          selectedDatum[0].datum.accountName.toString().split("-")[0]),
          int.parse(
              selectedDatum[0].datum.accountName.toString().split("-")[1]));

      dateTimeVisualizer = newDate;


      groupByArgument = 'Day';
    }
    else if (groupByArgument == 'Day') {
      // Set the grouping back to month
      groupByArgument = 'Accounts';

      int currentlySelectedGroupByValue = groupByVisualizerOptions.indexWhere((
          element) => element);
      groupByVisualizerOptions[currentlySelectedGroupByValue] = false;
      groupByVisualizerOptions[0] = true;
    }
    else if (groupByArgument == 'Accounts') {
      if (selectedDatum.isNotEmpty && !currentlyLoading) {
        //time = selectedDatum.first.datum.toString();
        selectedDatum.forEach((charts.SeriesDatum datumPair) {
          print(datumPair.datum.amount);
          print(datumPair.datum.accountName);
          print(datumPair.datum.accountId);
          print(datumPair.datum.accountLevel);

          if (datumPair.datum.accountId > 0 &&
              datumPair.datum.accountLevel < 3) {
            g_parent_account.id = datumPair.datum.accountId;
            g_parent_account.accountLevel =
                datumPair.datum.accountLevel + 1; // we need to next higher one

            drilldownLevel += drilldownLevel.length > 0
                ? " > " + datumPair.datum.accountName
                : datumPair.datum.accountName;
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  title: new Text(
                      AppLocalizations.of(context).translate('drilldownError'), style: GoogleFonts.lato()),
                  content: new Text(datumPair.datum.accountLevel >= 3
                      ? AppLocalizations.of(context).translate(
                      'drilldownErrorMoreLevel3')
                      : AppLocalizations.of(context).translate(
                      'drilldownErrorParent')),
                  // No drilldown possible as there is no deeper level available
                  actions: <Widget>[
                    // usually buttons at the bottom of the dialog
                    new FlatButton(
                      child: new Text(
                          AppLocalizations.of(context).translate('close'), style: GoogleFonts.lato()),
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
    }


    setState(() {
      currentlyLoading =
      true;
    });

    setState(() {
      loadAmount(true);
    });
  }

  setLoading() {
    // #189 workaround for showing load animation, does not work directly in onChanged of radioButton
    setState(() {
      currentlyLoading =
      true;
    });
  }

  handleOrderDialog(int index, String type) {
    String passedType = '';
    /*
     Mapping:
     0 -> created
     0 -> data_date
     0 -> amount
     0 -> costtype
     0 -> level1
     */

    print(index);

    switch (index) {
    // Default value when only the switch is changed, use the same column again
      case -1:
        {
          passedType =
          type == 'actual' ? actualListSortColumn : budgetListSortColumn;
        }
        break;

      case 0:
        {
          passedType = 'created';
        }
        break;

      case 1:
        {
          passedType = 'data_date';
        }
        break;
      case 2:
        {
          passedType = 'amount';
        }
        break;
      case 3:
        {
          passedType = 'costtype';
        }
        break;
      case 4:
        {
          passedType = 'level1';
        }
        break;
    }

    // When its the same again
    //   - switch the the opposite (either asc or desc whatever it was)
    // When it was fresh switched to data_date
    //   - set it to the default -> desc

    if (type == 'actual') {
      actualListSortType = sortActualDescending == true ? 'desc' : 'asc';
      actualListSortColumn = passedType;
    } else if (type == 'budget') {
      budgetListSortType = sortBudgetDescending == true ? 'desc' : 'asc';
      budgetListSortColumn = passedType;
    }


    loadList(
        type,
        type == 'actual' ? actualListSortColumn : budgetListSortColumn,
        type == 'actual' ? actualListSortType : budgetListSortType);
  }

  String numberValidator(String value) {
    if (value == null) {
      return null;
    }
    final n = num.tryParse(value);
    if (n == null) {
      return '"$value" is not a valid number';
    }
    return null;
  }


  final RefreshController _refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    final children = Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: appBarTitleText,
        actions: <Widget>[
          // action button
          IconButton(
              icon: Icon(Icons.help),
              color: Color(0xffEEEEEE),
              iconSize: 24,
              onPressed: () {
                helpDialog(_currentIndex);
                //showCustomDialog(_currentIndex, 'help', -1);
              }),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            color: Color(0xffEEEEEE),
            iconSize: 24,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) =>
                new AlertDialog(
                  title: Text(AppLocalizations.of(context).translate(
                      'areYouSureDialog'), style: GoogleFonts.lato()),
                  content: new Text("${
                      AppLocalizations.of(context).translate(
                          'confirmLogout')}?", style: GoogleFonts.lato()),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text(AppLocalizations.of(context).translate(
                          'cancel'), style: GoogleFonts.lato()),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    new FlatButton(
                      child: new Text(AppLocalizations.of(context).translate(
                          'confirmLogout'), style: GoogleFonts.lato()),
                      onPressed: () {
                        signOut();
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
        ],
        leading: IconButton(
            icon: Icon(Icons.account_circle),
            color: Color(0xffEEEEEE),
            iconSize: 24,
            onPressed: () {
              print(name);
              print(email);
              print(imageUrl);
              print(token);
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

            // test for #56, does not make a lot of sense as the last page is a tabbar page, and this callback is never called
            /*
            if (index == 5 &&
                (_pageController.page + 1) < 5) {
              _pageController.animateTo(_pageController.page + 1);
            }
            */


            setState(() => _currentIndex = index);

            switch (index) {
              case 0:
                {
                  appBarTitleText = Text(
                      'FFD - ${AppLocalizations.of(context).translate(
                          'titleHome')}', style: GoogleFonts.lato(),);
                  break;
                }
              case 1:
                {
                  appBarTitleText = Text(
                      'FFD - ${AppLocalizations.of(context).translate(
                          'titleExpenses')}', style: GoogleFonts.lato(),);
                  break;
                }
              case 2:
                {
                  appBarTitleText = Text(
                      'FFD - ${AppLocalizations.of(context).translate(
                          'titleBudget')}', style: GoogleFonts.lato(),);
                  break;
                }
              case 3:
                {
                  appBarTitleText = Text(
                      'FFD - ${AppLocalizations.of(context).translate(
                          'titleVisualizer')}', style: GoogleFonts.lato(),);
                  break;
                }
              case 4:
                {
                  appBarTitleText = Text(
                      'FFD - ${AppLocalizations.of(context).translate(
                          'titleSettings')}', style: GoogleFonts.lato(),);
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
                        _refreshController.refreshCompleted();
                      },
                      child: LayoutBuilder(
                        builder: (context, constraint) {
                          return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minHeight: constraint.maxHeight),
                                child: IntrinsicHeight(
                                    child: Stack(children: <Widget>[
                                      Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceAround,
                                          crossAxisAlignment: CrossAxisAlignment
                                              .center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: <Widget>[
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() =>
                                                    _currentIndex = 1);
                                                    _pageController
                                                        .animateToPage(1,
                                                        duration: Duration(
                                                            milliseconds: 300),
                                                        curve: Curves.linear);
                                                    ;
                                                  },
                                                  child: Container(
                                                    width: MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width *
                                                        .48,
                                                    child: Card(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                      ),
                                                      color: Color(0xff003680),
                                                      elevation: 10,
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize
                                                            .min,
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                        children: <Widget>[
                                                          ListTile(
                                                            leading: Icon(
                                                                Icons
                                                                    .monetization_on,
                                                                color: Colors
                                                                    .white,
                                                                size: 40),
                                                            title:
                                                            Text(
                                                              AppLocalizations
                                                                  .of(
                                                                  context)
                                                                  .translate(
                                                                  'titleExpenses'),
                                                              style: GoogleFonts.lato(
                                                                  fontSize: 14,
                                                                  color: Color(
                                                                      0xffF5F5F6)),
                                                              overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                            ),
                                                            subtitle: Text(
                                                                "${homescreenData[0]
                                                                    .amount
                                                                    .toStringAsFixed(
                                                                    2)}\n today: ${dailyExpense.toStringAsFixed(0)}/ Ø ${thisMonthAverage.toStringAsFixed(0)}",
                                                                style: GoogleFonts.lato(
                                                                    color:
                                                                    Colors
                                                                        .white)),
                                                            trailing: Icon(
                                                              homescreenData[0]
                                                                  .amount >
                                                                  parsedActualComparison
                                                                  ? Icons
                                                                  .trending_up
                                                                  : Icons
                                                                  .trending_down,
                                                              color: Color(
                                                                  0xffF5F5F6),
                                                              size: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() =>
                                                    _currentIndex = 2);
                                                    _pageController
                                                        .animateToPage(2,
                                                        duration: Duration(
                                                            milliseconds: 300),
                                                        curve: Curves.linear);
                                                  },
                                                  child: Container(
                                                    width: MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width *
                                                        .48,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                      new BorderRadius.only(
                                                        topLeft:
                                                        const Radius.circular(
                                                            50.0),
                                                        topRight:
                                                        const Radius.circular(
                                                            50.0),
                                                        bottomLeft:
                                                        const Radius.circular(
                                                            50.0),
                                                        bottomRight:
                                                        const Radius.circular(
                                                            50.0),
                                                      ),
                                                    ),
                                                    child: Card(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                      ),
                                                      color: Color(0xff003680),
                                                      elevation: 10,
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize
                                                            .min,
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                        children: <Widget>[
                                                          ListTile(
                                                            leading: Icon(
                                                                Icons
                                                                    .account_balance_wallet,
                                                                color: Colors
                                                                    .white,
                                                                size: 40),
                                                            title: Text(
                                                              AppLocalizations
                                                                  .of(
                                                                  context)
                                                                  .translate(
                                                                  'titleBudget'),
                                                              style: GoogleFonts.lato(
                                                                  fontSize: 14,
                                                                  color: Color(
                                                                      0xffF5F5F6)),
                                                              overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                            ),

                                                            subtitle: Text(
                                                              // #91
                                                                "${homescreenData[2]
                                                                    .amount
                                                                    .toStringAsFixed(
                                                                    2)}\n${(homescreenData[2]
                                                                    .amount
                                                                    / DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day)
                                                                    .toStringAsFixed(
                                                                    0)}",
                                                                style: GoogleFonts.lato(
                                                                    color:
                                                                    Colors
                                                                        .white)),
                                                            trailing: Icon(
                                                              homescreenData[2]
                                                                  .amount >
                                                                  parsedBudgetComparison
                                                                  ? Icons
                                                                  .trending_up
                                                                  : Icons
                                                                  .trending_down,
                                                              color: Color(
                                                                  0xffF5F5F6),
                                                              size: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // TODO make with variable, just a test for #25
                                            Text(
                                              AppLocalizations.of(context)
                                                  .translate('titlePieChart'),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.lato(
                                                  color: Color(
                                                      0xff2B2B2B),
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 30),
                                            ),
                                            Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Switch(
                                                    value: showFullYearHome,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        currentlyLoading = true;

                                                        showFullYearHome =
                                                            value;
                                                        loadHomescreen(true);
                                                        //currentlyLoading = false;
                                                      });
                                                    },
                                                    activeTrackColor: Color(
                                                        0xffEEEEEE),
                                                    activeColor: Color(
                                                        0xff0957FF),
                                                  ),
                                                  Text(
                                                    AppLocalizations.of(context)
                                                        .translate(
                                                        'FullYearSwitch'),
                                                    maxLines: 3,
                                                    overflow: TextOverflow
                                                        .ellipsis,
                                                    style: GoogleFonts.lato(
                                                        color: Color(
                                                            0xff2B2B2B),
                                                        fontWeight: FontWeight
                                                            .w900,
                                                        fontSize: 25),
                                                  ),
                                                ]),
                                            Container(
                                              width: MediaQuery
                                                  .of(context)
                                                  .size
                                                  .width,
                                              height:
                                              MediaQuery
                                                  .of(context)
                                                  .size
                                                  .height *
                                                  .4,
                                              child: charts.PieChart(
                                                [
                                                  charts.Series<
                                                      homescreenPie,
                                                      String>(
                                                      id:
                                                      'CompanySizeVsNumberOfCompanies',
                                                      domainFn:
                                                          (
                                                          homescreenPie dataPoint,
                                                          _) =>
                                                      dataPoint.type,
                                                      labelAccessorFn: (
                                                          homescreenPie row,
                                                          _) =>
                                                      '${row.amount
                                                          .toStringAsFixed(
                                                          2)}€',
                                                      measureFn:
                                                          (
                                                          homescreenPie dataPoint,
                                                          _) =>
                                                      dataPoint.amount,
                                                      colorFn:
                                                          (
                                                          homescreenPie segment,
                                                          _) =>
                                                      segment.color,
                                                      data: homescreenData
                                                          .sublist(
                                                          0,
                                                          2) /*Only first 2 elements not also the overall budget*/
                                                  )
                                                ],

                                                defaultRenderer:
                                                new charts.ArcRendererConfig(
                                                    arcRendererDecorators: [
                                                      new charts
                                                          .ArcLabelDecorator(
                                                        //labelPadding: 0,
                                                          labelPosition: charts
                                                              .ArcLabelPosition
                                                              .outside),
                                                    ],
                                                    //strokeWidthPx: ,
                                                    arcWidth: 50
                                                ),
                                                animate: (!startingUp),

                                                behaviors: [
                                                  new charts.DatumLegend(
                                                    // Positions for "start" and "end" will be left and right respectively
                                                    // for widgets with a build context that has directionality ltr.
                                                    // For rtl, "start" and "end" will be right and left respectively.
                                                    // Since this example has directionality of ltr, the legend is
                                                    // positioned on the right side of the chart.
                                                    position: charts
                                                        .BehaviorPosition
                                                        .bottom,
                                                    // For a legend that is positioned on the left or right of the chart,
                                                    // setting the justification for [endDrawArea] is aligned to the
                                                    // bottom of the chart draw area.
                                                    outsideJustification: charts
                                                        .OutsideJustification
                                                        .middleDrawArea,
                                                    // By default, if the position of the chart is on the left or right of
                                                    // the chart, [horizontalFirst] is set to false. This means that the
                                                    // legend entries will grow as new rows first instead of a new column.
                                                    horizontalFirst: false,
                                                    // By setting this value to 2, the legend entries will grow up to two
                                                    // rows before adding a new column.
                                                    desiredMaxRows: 2,
                                                    // This defines the padding around each legend entry.
                                                    cellPadding: new EdgeInsets
                                                        .only(right: 4.0,
                                                        bottom: 4.0),
                                                    // Render the legend entry text with custom styles.
                                                    entryTextStyle: charts
                                                        .TextStyleSpec(
                                                        fontSize: 11),
                                                  ),
                                                ], // When startingUp truy, dont animate, and when false show animations
                                              ),
                                            ),
                                            Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  ButtonTheme(
                                                    //minWidth: 150.0,
                                                    child: FlatButton(
                                                      onPressed: () =>
                                                          _showDatePicker(
                                                              'home',
                                                              dateTimeHome),
                                                      shape: new RoundedRectangleBorder(
                                                        borderRadius:
                                                        new BorderRadius
                                                            .circular(
                                                            40.0),
                                                      ),
                                                      color: Color(0xff003680),
                                                      padding: EdgeInsets.all(
                                                          10.0),
                                                      child: Row(
                                                        // Replace with a Row for horizontal icon + text
                                                        children: <Widget>[
                                                          Text(
                                                              " ${dateTimeHome
                                                                  .year
                                                                  .toString()}-${dateTimeHome
                                                                  .month
                                                                  .toString()
                                                                  .padLeft(
                                                                  2, '0')}",
                                                              style: GoogleFonts.lato(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 17)),
                                                          Icon(
                                                            Icons
                                                                .calendar_today,
                                                            color: Colors.white,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ]),
                                          ]),
                                      currentlyLoading
                                          ?
                                      _showLoadWidget()
                                          : Container(),
                                    ],)
                                ),
                              ));
                        },
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
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xff003680),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                Text(
                                  AppLocalizations.of(context)
                                      .translate('TitleInputTab'),
                                  style: GoogleFonts.lato(color: Colors.white),
                                )
                              ]),
                        ),

                      ),
                      Tab(
                        child: Container(
                          alignment: Alignment.center,
                          //constraints: BoxConstraints.expand(width: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xff003680),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                                Text(
                                  AppLocalizations.of(context)
                                      .translate('TitleListTab'),
                                  style: GoogleFonts.lato(color: Colors.white),
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
                                        _refreshController.refreshCompleted();
                                      },
                                      child: Stack(
                                        children: <Widget>[LayoutBuilder(
                                          builder: (context, constraint) {
                                            return SingleChildScrollView(
                                                child: ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                      minHeight: constraint
                                                          .maxHeight),
                                                  child: IntrinsicHeight(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                        children: <Widget>[
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                              children: <
                                                                  Widget>[
                                                                ButtonTheme(
                                                                  //minWidth: 150.0,
                                                                  height: 60.0,
                                                                  child: FlatButton(
                                                                    onPressed: () =>
                                                                        _showDatePicker(
                                                                            'actual',
                                                                            dateTimeActual),
                                                                    shape:
                                                                    new RoundedRectangleBorder(
                                                                      borderRadius:
                                                                      new BorderRadius
                                                                          .circular(
                                                                          40.0),
                                                                    ),
                                                                    color: Color(
                                                                        0xff003680),
                                                                    padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                        10.0),
                                                                    child: Row(
                                                                      // Replace with a Row for horizontal icon + text
                                                                      children: <
                                                                          Widget>[
                                                                        Text(
                                                                            " ${dateTimeActual
                                                                                .year
                                                                                .toString()}-${dateTimeActual
                                                                                .month
                                                                                .toString()
                                                                                .padLeft(
                                                                                2,
                                                                                '0')}",
                                                                            style: GoogleFonts.lato(
                                                                                color: Colors
                                                                                    .white,
                                                                                fontSize: 17)),
                                                                        SizedBox(
                                                                            width: 10),
                                                                        Icon(
                                                                          Icons
                                                                              .calendar_today,
                                                                          color: Colors
                                                                              .white,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ]),
                                                          Container(
                                                              padding: const EdgeInsets
                                                                  .only(
                                                                  left: 30.0,
                                                                  top: 0,
                                                                  right: 30,
                                                                  bottom: 0),
                                                              //color: Colors.blue[600],
                                                              alignment: Alignment
                                                                  .center,
                                                              //child: Text('Submit'),
                                                              child: Stack(
                                                                alignment:
                                                                const Alignment(
                                                                    1.0, 1.0),
                                                                children: <
                                                                    Widget>[
                                                                  TextFormField(
                                                                    keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                    //keyboard with numbers only will appear to the screen
                                                                    style: GoogleFonts.lato(
                                                                        height: 2),
                                                                    //increases the height of cursor
                                                                    //autofocus: true,
                                                                    controller:
                                                                    actualTextFieldController,
                                                                    validator: numberValidator,
                                                                    decoration: InputDecoration(
                                                                      // hintText: 'Enter ur amount',
                                                                      //hintStyle: TextStyle(height: 1.75),
                                                                        labelText: AppLocalizations
                                                                            .of(
                                                                            context)
                                                                            .translate(
                                                                            'TextFieldAmountInput'),
                                                                        labelStyle: GoogleFonts.lato(
                                                                            height: 0.5,
                                                                            color: Color(
                                                                                0xff0957FF)),
                                                                        //increases the height of cursor
                                                                        icon: Icon(
                                                                          Icons
                                                                              .attach_money,
                                                                          color: Color(
                                                                              0xff0957FF),
                                                                        ),
                                                                        //prefixIcon: Icon(Icons.attach_money),
                                                                        //labelStyle: TextStyle(color: Color(0xff0957FF)),
                                                                        enabledBorder:
                                                                        new UnderlineInputBorder(
                                                                            borderSide:
                                                                            new BorderSide(
                                                                                color: Color(
                                                                                    0xff0957FF)))),
                                                                  ),
                                                                  new FlatButton(
                                                                      onPressed: () {
                                                                        actualTextFieldController
                                                                            .clear();
                                                                      },
                                                                      child:
                                                                      new Icon(
                                                                          Icons
                                                                              .clear))
                                                                ],)
                                                          ),
                                                          areLevel1AccountsActive
                                                              ? Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 30.0,
                                                                top: 0,
                                                                right: 30,
                                                                bottom: 0),
                                                            alignment: Alignment
                                                                .center,
                                                            child: SearchChoices
                                                                .single(
                                                              items:
                                                              level1ActualAccountsList
                                                                  .map((Account
                                                              account) {
                                                                return new DropdownMenuItem<
                                                                    Account>(
                                                                  value: account,
                                                                  child: new Text(
                                                                    account
                                                                        .name, style: GoogleFonts.lato()
                                                                  ),
                                                                );
                                                              }).toList(),
                                                              style: GoogleFonts.lato(
                                                                  color:
                                                                  Color(
                                                                      0xff0957FF)),
                                                              value: level1ActualObject,
                                                              underline: Container(
                                                                height: 2,
                                                                width: 5000,
                                                                color: Color(
                                                                    0xff0957FF),
                                                              ),
                                                              hint: AppLocalizations
                                                                  .of(
                                                                  context)
                                                                  .translate(
                                                                  'select_one_account'),
                                                              searchHint:
                                                              AppLocalizations
                                                                  .of(
                                                                  context)
                                                                  .translate(
                                                                  'select_one_account'),
                                                              onClear: () {
                                                                setState(() {
                                                                  level1ActualObject =
                                                                  level1ActualAccountsList[
                                                                  0];

                                                                  level2ActualObject =
                                                                  level2ActualAccountsList[
                                                                  0];

                                                                  level3ActualObject =
                                                                  level3ActualAccountsList[
                                                                  0];
                                                                });
                                                              },
                                                              onChanged: (
                                                                  value) async {

                                                                print("ONCHANGED CALLED WITH VALUE CHANGED - ${!(value == level1ActualObject)}");
                                                                if (value !=
                                                                    null) {
                                                                  setState(() {
                                                                    level1ActualObject =
                                                                        value;

                                                                    currentlyLoading =
                                                                    true;
                                                                  });

                                                                  await arrangeAccounts(
                                                                      1,
                                                                      'actual');

                                                                  print(
                                                                      "${level2ActualObject
                                                                          .id} - ${level2ActualObject
                                                                          .name}");

                                                                  setState(() {
                                                                    currentlyLoading =
                                                                    false;
                                                                  });
                                                                }
                                                              },
                                                              dialogBox: true,
                                                              isExpanded: true,
                                                            ),
                                                          )
                                                              : Container(),
                                                          areLevel2AccountsActive
                                                              ? Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 30.0,
                                                                top: 0,
                                                                right: 30,
                                                                bottom: 0),
                                                            //color: Colors.blue[600],

                                                            alignment: Alignment
                                                                .center,
                                                            //child: Text('Submit'),
                                                            child: SearchChoices
                                                                .single(
                                                              items:
                                                              level2ActualAccountsList
                                                                  .map((Account
                                                              account) {
                                                                return new DropdownMenuItem<
                                                                    Account>(
                                                                  value: account,
                                                                  child: new Text(
                                                                    account
                                                                        .name, style: GoogleFonts.lato()
                                                                  ),
                                                                );
                                                              }).toList(),
                                                              style: GoogleFonts.lato(
                                                                  color: level1ActualObject
                                                                      .id <=
                                                                      0 ? Colors
                                                                      .grey :
                                                                  Color(
                                                                      0xff0957FF)),
                                                              value: level2ActualObject,
                                                              readOnly: level1ActualObject
                                                                  .id <=
                                                                  0 ||
                                                                  level2ActualAccountsList
                                                                      .length <=
                                                                      1 ||
                                                                  currentlyLoading,
                                                              underline: Container(
                                                                height: 2,
                                                                width: 5000,
                                                                color: level1ActualObject
                                                                    .id <=
                                                                    0
                                                                    ? Colors
                                                                    .grey
                                                                    : Color(
                                                                    0xff0957FF),
                                                              ),
                                                              hint: AppLocalizations
                                                                  .of(
                                                                  context)
                                                                  .translate(
                                                                  'select_one_account'),
                                                              searchHint:
                                                              AppLocalizations
                                                                  .of(
                                                                  context)
                                                                  .translate(
                                                                  'select_one_account'),
                                                              onClear: () {
                                                                setState(() {
                                                                  level2ActualObject =
                                                                  level2ActualAccountsList[
                                                                  0];

                                                                  level3ActualObject =
                                                                  level3ActualAccountsList[
                                                                  0];
                                                                });
                                                              },
                                                              onChanged: (
                                                                  value) async {
                                                                if (value !=
                                                                    null) {
                                                                  // Check if a new value was selected or the same was reselected
                                                                  dummyAccount =
                                                                      level2ActualObject;

                                                                  setState(() {
                                                                    level2ActualObject =
                                                                        value;

                                                                    currentlyLoading =
                                                                    true;
                                                                  });

                                                                  if (dummyAccount
                                                                      .id !=
                                                                      value
                                                                          .id) {
                                                                    await arrangeAccounts(
                                                                        2,
                                                                        'actual');
                                                                  } else {
                                                                    print(
                                                                        "RESELECTED");
                                                                  }

                                                                  setState(() {
                                                                    currentlyLoading =
                                                                    false;
                                                                  });
                                                                }
                                                              },
                                                              dialogBox: true,
                                                              isExpanded: true,
                                                            ),
                                                          )
                                                              : Container(),

                                                          areLevel3AccountsActive
                                                              ? Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 30.0,
                                                                top: 0,
                                                                right: 30,
                                                                bottom: 0),
                                                            //color: Colors.blue[600],
                                                            alignment: Alignment
                                                                .center,
                                                            //child: Text('Submit'),
                                                            child: SearchChoices
                                                                .single(
                                                              items:
                                                              level3ActualAccountsList
                                                                  .map((Account
                                                              account) {
                                                                return new DropdownMenuItem<
                                                                    Account>(
                                                                  value: account,
                                                                  child: new Text(
                                                                    account
                                                                        .name, style: GoogleFonts.lato()
                                                                  ),
                                                                );
                                                              }).toList(),
                                                              style: GoogleFonts.lato(
                                                                  color: level2ActualObject
                                                                      .id <=
                                                                      0 ? Colors
                                                                      .grey :
                                                                  Color(
                                                                      0xff0957FF)),
                                                              value: level3ActualObject,
                                                              readOnly: level2ActualObject
                                                                  .id <=
                                                                  0 ||
                                                                  level3ActualAccountsList
                                                                      .length <=
                                                                      1 ||
                                                                  currentlyLoading,
                                                              underline: Container(
                                                                height: 2,
                                                                width: 5000,
                                                                color: level2ActualObject
                                                                    .id <=
                                                                    0
                                                                    ? Colors
                                                                    .grey
                                                                    : Color(
                                                                    0xff0957FF),
                                                              ),
                                                              hint: AppLocalizations
                                                                  .of(
                                                                  context)
                                                                  .translate(
                                                                  'select_one_account'),
                                                              searchHint:
                                                              AppLocalizations
                                                                  .of(
                                                                  context)
                                                                  .translate(
                                                                  'select_one_account'),
                                                              onClear: () {
                                                                setState(() {
                                                                  level3ActualObject =
                                                                  level3ActualAccountsList[
                                                                  0];
                                                                });
                                                              },
                                                              // The default object is set again
                                                              onChanged: (
                                                                  value) {
                                                                if (value !=
                                                                    null) {
                                                                  setState(() {
                                                                    level3ActualObject =
                                                                        value;
                                                                  });
                                                                }
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
                                                              : SizedBox(
                                                              height: 20),
                                                          areCostTypesActive
                                                              ? Container(
                                                            constraints:
                                                            BoxConstraints
                                                                .expand(
                                                              height: 80,
                                                              //width: MediaQuery.of(context).size.width * .8
                                                            ),
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 30.0,
                                                                top: 0,
                                                                right: 30,
                                                                bottom: 0),
                                                            //color: Colors.blue[600],
                                                            alignment: Alignment
                                                                .center,
                                                            //child: Text('Submit'),
                                                            child: Align(
                                                              alignment:
                                                              Alignment
                                                                  .topRight,
                                                              child: SearchChoices
                                                                  .single(
                                                                value:
                                                                costTypeObjectActual,
                                                                hint: AppLocalizations
                                                                    .of(
                                                                    context)
                                                                    .translate(
                                                                    'select_one_costtype'),
                                                                searchHint: AppLocalizations
                                                                    .of(
                                                                    context)
                                                                    .translate(
                                                                    'select_one_costtype'),
                                                                icon: Icon(
                                                                    Icons
                                                                        .arrow_downward),
                                                                iconSize: 24,
                                                                style: GoogleFonts.lato(
                                                                    color: Color(
                                                                        0xff0957FF)),
                                                                underline: Container(
                                                                  height: 2,
                                                                  width: 2000,
                                                                  color:
                                                                  Color(
                                                                      0xff0957FF),
                                                                ),
                                                                onClear: () {
                                                                  setState(() {
                                                                    costTypeObjectActual =
                                                                    costTypesList[0];
                                                                  });
                                                                },
                                                                onChanged:
                                                                    (
                                                                    CostType newValue) {
                                                                  if (value !=
                                                                      null) {
                                                                    setState(() {
                                                                      costTypeObjectActual =
                                                                          newValue;
                                                                    });
                                                                  }
                                                                  ;
                                                                },
                                                                items: costTypesList
                                                                    .map((
                                                                    CostType type) {
                                                                  return new DropdownMenuItem<
                                                                      CostType>(
                                                                    value: type,
                                                                    child: new Text(
                                                                      type.name, style: GoogleFonts.lato()
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                              ),
                                                            ),
                                                          )
                                                              : Container(),
                                                          ButtonBar(
                                                            mainAxisSize: MainAxisSize
                                                                .min,
                                                            // this will take space as minimum as posible(to center)
                                                            children: <Widget>[
                                                              ButtonTheme(
                                                                minWidth: 75.0,
                                                                height: 40.0,
                                                                child: RaisedButton(
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: new BorderRadius
                                                                        .circular(
                                                                        50.0),
                                                                  ),
                                                                  child: Text(
                                                                    AppLocalizations
                                                                        .of(
                                                                        context)
                                                                        .translate(
                                                                        'DiscardButton'), style: GoogleFonts.lato()
                                                                  ),
                                                                  color: Color(
                                                                      0xffEEEEEE),
                                                                  // EEEEEE
                                                                  onPressed: () {
                                                                    actualTextFieldController
                                                                        .text =
                                                                    '';

                                                                    setState(() {
                                                                      level1ActualObject =
                                                                      level1ActualAccountsList[
                                                                      0];
                                                                      level2ActualObject =
                                                                      level2ActualAccountsList[
                                                                      0];
                                                                      level3ActualObject =
                                                                      level3ActualAccountsList[
                                                                      0];

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
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: new BorderRadius
                                                                        .circular(
                                                                        50.0),
                                                                  ),
                                                                  child: Text(
                                                                      AppLocalizations
                                                                          .of(
                                                                          context)
                                                                          .translate(
                                                                          'addButton'),
                                                                      style: GoogleFonts.lato(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize: 17)),
                                                                  color: Color(
                                                                      0xff0957FF),
                                                                  //df7599 - 0957FF
                                                                  onPressed: () {
                                                                    if (actualTextFieldController
                                                                        .text
                                                                        .length >
                                                                        0 &&
                                                                        numberValidator(
                                                                            actualTextFieldController
                                                                                .text
                                                                        ) ==
                                                                            null) {
                                                                      commentInput(
                                                                          context,
                                                                          'actual',
                                                                          null,
                                                                          null,
                                                                          null);
                                                                    }
                                                                    else {
                                                                      showDialog(
                                                                        context: context,
                                                                        builder: (
                                                                            BuildContext context) {
                                                                          // return object of type Dialog
                                                                          return AlertDialog(
                                                                            title: new Text(
                                                                              AppLocalizations
                                                                                  .of(
                                                                                  context)
                                                                                  .translate(
                                                                                  'warning')
                                                                              ,
                                                                              style: GoogleFonts.lato(
                                                                                  color: Colors
                                                                                      .orange,
                                                                                  fontSize: 25,
                                                                                  fontWeight: FontWeight
                                                                                      .bold),),
                                                                            content: new Text(
                                                                              // #157 differentiate message betweeen nothing entered and invalid number entered
                                                                              actualTextFieldController
                                                                                  .text
                                                                                  .length ==
                                                                                  0
                                                                                  ?
                                                                              AppLocalizations
                                                                                  .of(
                                                                                  context)
                                                                                  .translate(
                                                                                  'errorInputEnterAmount')
                                                                                  : AppLocalizations
                                                                                  .of(
                                                                                  context)
                                                                                  .translate(
                                                                                  'errorInputInvalidAmount'),
                                                                              style: GoogleFonts.lato(
                                                                                  fontWeight: FontWeight
                                                                                      .bold,
                                                                                  fontSize: 20),),
                                                                            actions: <
                                                                                Widget>[
                                                                              // usually buttons at the bottom of the dialog
                                                                              new FlatButton(
                                                                                child: new Text(
                                                                                    "Close", style: GoogleFonts.lato()),
                                                                                onPressed: () {
                                                                                  Navigator
                                                                                      .of(
                                                                                      context)
                                                                                      .pop();
                                                                                },
                                                                              ),
                                                                            ],
                                                                          );
                                                                        },
                                                                      );
                                                                    }
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      )
                                                  ),
                                                ));
                                          },
                                        ), currentlyLoading
                                            ?
                                        _showLoadWidget()
                                            : Container(),
                                        ],)
                                  )),
                            ],
                          ),
                        ),
                        SmartRefresher(
                            controller: _refreshController,
                            enablePullDown: true,
                            onRefresh: () async {
                              await handleRefresh(_currentIndex);
                              _refreshController.refreshCompleted();
                            },
                            child: ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: actList.length + 1,
                                // Length + 1 as the 0 index is the sort button, all other use index - 1
                                itemBuilder: (BuildContext context,
                                    int index) {
                                  return Stack(children: <Widget>[
                                    index == 0
                                        ? Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceEvenly,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Flexible(
                                                    child: TextFormField(
                                                        autofocus: false,
                                                        onChanged: (value) {
                                                          setState(() {});
                                                        },
                                                        controller:
                                                        actualSearchTextFieldController,
                                                        decoration:
                                                        InputDecoration(
                                                          // hintText: 'Enter ur amount',
                                                          //hintStyle: TextStyle(height: 1.75),
                                                          labelText: AppLocalizations
                                                              .of(context)
                                                              .translate(
                                                              'ListSearchTextField'),
                                                          //increases the height of cursor
                                                          icon: Icon(
                                                            Icons.search,
                                                          ),
                                                        ))
                                                ),
                                                IconButton(
                                                    icon: Icon(Icons.clear),
                                                    color:
                                                    Color(0xff003680),
                                                    alignment: Alignment
                                                        .centerRight,
                                                    iconSize: 25,
                                                    onPressed: () {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                      setState(() {
                                                        actualSearchTextFieldController
                                                            .clear();
                                                      });
                                                    }),
                                                IconButton(
                                                    icon: Icon(Icons.sort),
                                                    color:
                                                    Color(0xff003680),
                                                    alignment: Alignment
                                                        .centerRight,
                                                    iconSize: 25,
                                                    onPressed: () {
                                                      showDialog<void>(
                                                        context: context,
                                                        builder: (
                                                            BuildContext context) {
                                                          return AlertDialog(
                                                            content: StatefulBuilder(
                                                              builder: (
                                                                  BuildContext context,
                                                                  StateSetter setState) {
                                                                return Column(
                                                                    mainAxisSize: MainAxisSize
                                                                        .min,
                                                                    children: List<
                                                                        Widget>.generate(
                                                                        sortActualOrders
                                                                            .length +
                                                                            1 /* + 1 because position zero is the sort switch*/, (
                                                                        int index) {
                                                                      return
                                                                        index ==
                                                                            0
                                                                            ?
                                                                        Row(
                                                                            mainAxisAlignment: MainAxisAlignment
                                                                                .center,
                                                                            children: <
                                                                                Widget>[
                                                                              Text(
                                                                                AppLocalizations
                                                                                    .of(
                                                                                    context)
                                                                                    .translate(
                                                                                    'orderAsc'),
                                                                                overflow: TextOverflow
                                                                                    .ellipsis, style: GoogleFonts.lato()),
                                                                              Switch(
                                                                                value: sortActualDescending,
                                                                                onChanged: (
                                                                                    value) {
                                                                                  setState(() {
                                                                                    sortActualDescending =
                                                                                        value;
                                                                                    handleOrderDialog(
                                                                                        -1,
                                                                                        'actual');
                                                                                    Navigator
                                                                                        .pop(
                                                                                        context);
                                                                                  });
                                                                                },
                                                                                activeTrackColor: Color(
                                                                                    0xffEEEEEE),
                                                                                activeColor: Color(
                                                                                    0xff0957FF),
                                                                              ),
                                                                              Text(
                                                                                AppLocalizations
                                                                                    .of(
                                                                                    context)
                                                                                    .translate(
                                                                                    'orderDesc'),
                                                                                overflow: TextOverflow
                                                                                    .ellipsis, style: GoogleFonts.lato()),
                                                                            ])
                                                                            : Row(
                                                                          children: <
                                                                              Widget>[
                                                                            Radio<
                                                                                bool>(
                                                                              groupValue: true,
                                                                              value: sortActualOrders[index -
                                                                                  1],
                                                                              activeColor: Color(
                                                                                  0xFF0957FF),
                                                                              onChanged: (
                                                                                  bool newValue) {
                                                                                setState(() {
                                                                                  print(
                                                                                      newValue);

                                                                                  sortActualOrders[0] =
                                                                                  false;
                                                                                  sortActualOrders[1] =
                                                                                  false;
                                                                                  sortActualOrders[2] =
                                                                                  false;
                                                                                  sortActualOrders[3] =
                                                                                  false;
                                                                                  sortActualOrders[4] =
                                                                                  false;

                                                                                  sortActualOrders[index -
                                                                                      1] =
                                                                                  true;
                                                                                });

                                                                                handleOrderDialog(
                                                                                    (index -
                                                                                        1),
                                                                                    'actual');

                                                                                Navigator
                                                                                    .pop(
                                                                                    context);
                                                                              },
                                                                            ),
                                                                            Flexible(
                                                                                child: Text(
                                                                                  AppLocalizations
                                                                                      .of(
                                                                                      context)
                                                                                      .translate(
                                                                                      '${index -
                                                                                          1}OrderText'),
                                                                                  overflow: TextOverflow
                                                                                      .clip, style: GoogleFonts.lato()
                                                                                )),
                                                                          ],
                                                                        );
                                                                    }));
                                                              },
                                                            ),
                                                          );
                                                        },);

                                                      /*return showDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                        true,
                                                        builder:
                                                            (BuildContext
                                                        context) {
                                                          return SimpleDialog(
                                                            title: Text(
                                                              AppLocalizations
                                                                  .of(
                                                                  context)
                                                                  .translate(
                                                                  'OrderByText'),
                                                            ),
                                                            children: <
                                                                Widget>[
                                                              SimpleDialogOption(
                                                                onPressed:
                                                                    () {
                                                                  // When its the same again
                                                                  //   - switch the the opposite (either asc or desc whatever it was)
                                                                  // When it was fresh switched to created
                                                                  //   - set it to the default -> desc
                                                                  actualListSortType =
                                                                  actualListSortColumn ==
                                                                      'created'
                                                                      ? (actualListSortType ==
                                                                      'asc'
                                                                      ? 'desc'
                                                                      : 'asc')
                                                                      : 'desc';
                                                                  actualListSortColumn =
                                                                  'created';

                                                                  loadList(
                                                                      'actual',
                                                                      actualListSortColumn,
                                                                      actualListSortType);
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                Text(
                                                                  AppLocalizations
                                                                      .of(
                                                                      context)
                                                                      .translate(
                                                                      'DateOfCreationOrderText'),
                                                                ),
                                                              ),
                                                              SimpleDialogOption(
                                                                onPressed:
                                                                    () {
                                                                  // When its the same again
                                                                  //   - switch the the opposite (either asc or desc whatever it was)
                                                                  // When it was fresh switched to data_date
                                                                  //   - set it to the default -> desc
                                                                  actualListSortType =
                                                                  actualListSortColumn ==
                                                                      'data_date'
                                                                      ? (actualListSortType ==
                                                                      'asc'
                                                                      ? 'desc'
                                                                      : 'asc')
                                                                      : 'desc';

                                                                  actualListSortColumn =
                                                                  'data_date';
                                                                  loadList(
                                                                      'actual',
                                                                      actualListSortColumn,
                                                                      actualListSortType);
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                Text(
                                                                  AppLocalizations
                                                                      .of(
                                                                      context)
                                                                      .translate(
                                                                      'MonthBilledOrderText'),
                                                                  style: TextStyle(
                                                                    decoration: TextDecoration
                                                                        .underline,
                                                                  ),
                                                                ),
                                                              ),
                                                              SimpleDialogOption(
                                                                  onPressed:
                                                                      () {
                                                                    // When its the same again
                                                                    //   - switch the the opposite (either asc or desc whatever it was)
                                                                    // When it was fresh switched to amount
                                                                    //   - set it to the default -> desc
                                                                    actualListSortType =
                                                                    actualListSortColumn ==
                                                                        'amount'
                                                                        ? (actualListSortType ==
                                                                        'asc'
                                                                        ? 'desc'
                                                                        : 'asc')
                                                                        : 'desc';

                                                                    actualListSortColumn =
                                                                    'amount';
                                                                    loadList(
                                                                        'actual',
                                                                        actualListSortColumn,
                                                                        actualListSortType);
                                                                    Navigator
                                                                        .pop(
                                                                        context);
                                                                  },
                                                                  child:
                                                                  Text(
                                                                    AppLocalizations
                                                                        .of(
                                                                        context)
                                                                        .translate(
                                                                        'AmountOrderText'),
                                                                  )),
                                                              SimpleDialogOption(
                                                                  onPressed:
                                                                      () {
                                                                    // When its the same again
                                                                    //   - switch the the opposite (either asc or desc whatever it was)
                                                                    // When it was fresh switched to costtype
                                                                    //   - set it to the default -> desc
                                                                    actualListSortType =
                                                                    actualListSortColumn ==
                                                                        'costtype'
                                                                        ? (actualListSortType ==
                                                                        'asc'
                                                                        ? 'desc'
                                                                        : 'asc')
                                                                        : 'desc';

                                                                    actualListSortColumn =
                                                                    'costtype';
                                                                    loadList(
                                                                        'actual',
                                                                        actualListSortColumn,
                                                                        actualListSortType);
                                                                    Navigator
                                                                        .pop(
                                                                        context);
                                                                  },
                                                                  child:
                                                                  Text(
                                                                    AppLocalizations
                                                                        .of(
                                                                        context)
                                                                        .translate(
                                                                        'CostTypeOrderText'),
                                                                  )),
                                                              SimpleDialogOption(
                                                                  onPressed:
                                                                      () {
                                                                    // When its the same again
                                                                    //   - switch the the opposite (either asc or desc whatever it was)
                                                                    // When it was fresh switched to level1
                                                                    //   - set it to the default -> desc
                                                                    actualListSortType =
                                                                    actualListSortColumn ==
                                                                        'level1'
                                                                        ? (actualListSortType ==
                                                                        'asc'
                                                                        ? 'desc'
                                                                        : 'asc')
                                                                        : 'desc';

                                                                    actualListSortColumn =
                                                                    'level1';
                                                                    loadList(
                                                                        'actual',
                                                                        actualListSortColumn,
                                                                        actualListSortType);
                                                                    Navigator
                                                                        .pop(
                                                                        context);
                                                                  },
                                                                  child:
                                                                  Text(
                                                                    AppLocalizations
                                                                        .of(
                                                                        context)
                                                                        .translate(
                                                                        'LevelOrderText'),
                                                                  ))
                                                            ],
                                                          );
                                                        });*/
                                                    })
                                              ]),
                                        ])
                                        : ((actList[index - 1].costType
                                        .toLowerCase().contains(
                                        actualSearchTextFieldController.text) ||
                                        actList[index - 1]
                                            .level1
                                            .toLowerCase()
                                            .contains(
                                            actualSearchTextFieldController
                                                .text) ||
                                        actList[index - 1]
                                            .level2
                                            .toLowerCase()
                                            .contains(
                                            actualSearchTextFieldController
                                                .text) ||
                                        actList[index - 1]
                                            .level3
                                            .toLowerCase()
                                            .contains(
                                            actualSearchTextFieldController
                                                .text) ||
                                        actList[index - 1]
                                            .comment
                                            .toLowerCase()
                                            .contains(
                                            actualSearchTextFieldController
                                                .text) ||
                                        actList[index - 1]
                                            .amount
                                            .toString()
                                            .contains(
                                            actualSearchTextFieldController
                                                .text) ||
                                        actList[index - 1]
                                            .level1
                                            .toLowerCase()
                                            .contains(
                                            actualSearchTextFieldController
                                                .text) ||
                                        actList[index - 1].date.toLowerCase()
                                            .contains(
                                            actualSearchTextFieldController
                                                .text))
                                        ? GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                            new AlertDialog(
                                              title: Text(
                                                AppLocalizations.of(
                                                    context)
                                                    .translate(
                                                    'DetailsListTitle'),
                                                style: GoogleFonts.lato(
                                                  color: Color(
                                                      0xff2B2B2B),
                                                  fontSize: 25,
                                                ),
                                              ),
                                              content: RichText(
                                                text: TextSpan(
                                                    text: "",
                                                    style: GoogleFonts.lato(
                                                      color: Color(
                                                          0xff2B2B2B),
                                                      fontSize: 15,
                                                    ),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                        text: AppLocalizations
                                                            .of(
                                                            context)
                                                            .translate(
                                                            'DetailsListDate'),
                                                        style: GoogleFonts.lato(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                        '${actList[index - 1]
                                                            .date}\n',
                                                        style: GoogleFonts.lato(
                                                            color: Color(
                                                                0xFF0957FF),
                                                            fontSize: 18,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontStyle:
                                                            FontStyle
                                                                .italic),
                                                      ),
                                                      TextSpan(
                                                        text: AppLocalizations
                                                            .of(
                                                            context)
                                                            .translate(
                                                            'DetailsListAmount'),
                                                        style: GoogleFonts.lato(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                        '${actList[index - 1]
                                                            .amount}\n',
                                                        style: GoogleFonts.lato(
                                                            color: Color(
                                                                0xFF0957FF),
                                                            fontSize: 18,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontStyle:
                                                            FontStyle
                                                                .italic),
                                                      ),
                                                      TextSpan(
                                                        text: AppLocalizations
                                                            .of(
                                                            context)
                                                            .translate(
                                                            'DetailsListLevel'),
                                                        style: GoogleFonts.lato(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                        '${actList[index - 1]
                                                            .level1} > ${actList[index -
                                                            1]
                                                            .level2} > ${actList[index -
                                                            1].level3}\n',
                                                        style: GoogleFonts.lato(
                                                            color: Color(
                                                                0xFF0957FF),
                                                            fontSize: 18,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontStyle:
                                                            FontStyle
                                                                .italic),
                                                      ),
                                                      TextSpan(
                                                        text: AppLocalizations
                                                            .of(
                                                            context)
                                                            .translate(
                                                            'DetailsListCostType'),
                                                        style: GoogleFonts.lato(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                        '${actList[index - 1]
                                                            .costType}\n',
                                                        style: GoogleFonts.lato(
                                                            color: Color(
                                                                0xFF0957FF),
                                                            fontSize: 18,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontStyle:
                                                            FontStyle
                                                                .italic),
                                                      ),
                                                      TextSpan(
                                                        text: AppLocalizations
                                                            .of(
                                                            context)
                                                            .translate(
                                                            'DetailsListCostType'),
                                                        style: GoogleFonts.lato(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                        '${actList[index - 1]
                                                            .comment.length > 0
                                                            ? actList[index - 1]
                                                            .comment
                                                            : AppLocalizations
                                                            .of(
                                                            context).translate(
                                                            'noCommentAvailable')}\n',
                                                        style: GoogleFonts.lato(
                                                            color: Color(
                                                                0xFF0957FF),
                                                            fontSize: 18,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontStyle:
                                                            FontStyle
                                                                .italic),
                                                      ),
                                                    ]),
                                              ),
                                              actions: <Widget>[
                                                new FlatButton(
                                                  child: new Text(
                                                      AppLocalizations.of(
                                                          context)
                                                          .translate(
                                                          'dismissDialog'), style: GoogleFonts.lato()),
                                                  onPressed: () =>
                                                      Navigator.of(
                                                          context)
                                                          .pop(),
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                        child: Container(
                                          margin:
                                          const EdgeInsets.all(15.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.blueAccent),
                                            color: actList[index - 1]
                                                .active ==
                                                1
                                                ? Color(0xffEEEEEE)
                                                : Colors.redAccent,
                                            borderRadius:
                                            new BorderRadius.circular(
                                                30.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(
                                                    0xff2B2B2B),
                                                blurRadius: 5,
                                                // has the effect of softening the shadow
                                                spreadRadius: 0,
                                                // has the effect of extending the shadow
                                                offset: Offset(
                                                  7.0,
                                                  // horizontal, move right 10
                                                  7.0, // vertical, move down 10
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
                                                  CrossAxisAlignment
                                                      .center,
                                                  children: <Widget>[
                                                    SizedBox(
                                                      width: MediaQuery
                                                          .of(
                                                          context)
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
                                                            SizedBox(
                                                                height: 15),
                                                            Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                                children: [
                                                                  SizedBox(
                                                                    width: MediaQuery
                                                                        .of(
                                                                        context)
                                                                        .size
                                                                        .width *
                                                                        .1,
                                                                    child:
                                                                    Icon(
                                                                      Icons
                                                                          .attach_money,
                                                                      color: Color(
                                                                          0xff0957FF),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    "${actList[index -
                                                                        1]
                                                                        .date}",
                                                                    style: GoogleFonts.lato(
                                                                        color: Color(
                                                                            0xff0957FF),
                                                                        fontSize:
                                                                        25),
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
                                                                    width: MediaQuery
                                                                        .of(
                                                                        context)
                                                                        .size
                                                                        .width *
                                                                        .1,
                                                                    child:
                                                                    Container(),
                                                                  ),
                                                                  Flexible(
                                                                      child:
                                                                      Text(
                                                                        "${actList[index -
                                                                            1]
                                                                            .comment
                                                                            .length >
                                                                            0
                                                                            ? actList[index -
                                                                            1]
                                                                            .comment
                                                                            : AppLocalizations
                                                                            .of(
                                                                            context)
                                                                            .translate(
                                                                            'noCommentAvailable')}",
                                                                        style:
                                                                        GoogleFonts.lato(
                                                                          color: Color(
                                                                              0xff2B2B2B),
                                                                          fontStyle:
                                                                          FontStyle
                                                                              .italic,
                                                                          fontSize:
                                                                          15,
                                                                        ),
                                                                        overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                      )),
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
                                                                      width: MediaQuery
                                                                          .of(
                                                                          context)
                                                                          .size
                                                                          .width *
                                                                          .1,
                                                                      //height: 300.0,
                                                                      child:
                                                                      Container()),
                                                                  Flexible(
                                                                      child:
                                                                      Text(
                                                                        '${actList[index -
                                                                            1]
                                                                            .level1} > ${actList[index -
                                                                            1]
                                                                            .level2} > ${actList[index -
                                                                            1]
                                                                            .level3}',
                                                                        style: GoogleFonts.lato(
                                                                            color: Color(
                                                                                0xff2B2B2B),
                                                                            fontSize:
                                                                            13),
                                                                        overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                      ))
                                                                ]),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                                children: [
                                                                  SizedBox(
                                                                      width: MediaQuery
                                                                          .of(
                                                                          context)
                                                                          .size
                                                                          .width *
                                                                          .1,
                                                                      //height: 300.0,
                                                                      child:
                                                                      Container()),
                                                                  Flexible(
                                                                      child:
                                                                      Text(
                                                                        '${actList[index -
                                                                            1]
                                                                            .costType}',
                                                                        style: GoogleFonts.lato(
                                                                            color: Color(
                                                                                0xff2B2B2B),
                                                                            fontSize:
                                                                            13),
                                                                        overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                      ))
                                                                ]),
                                                            SizedBox(
                                                              height: 15,
                                                            ),
                                                          ]),
                                                    ),
                                                    Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .start,
                                                        children: [
                                                          Text(
                                                              '${actList[index -
                                                                  1].amount}', style: GoogleFonts.lato()),
                                                          SizedBox(
                                                            width: MediaQuery
                                                                .of(
                                                                context)
                                                                .size
                                                                .width *
                                                                .1,
                                                            //height: 300.0,
                                                            child: IconButton(
                                                              icon: new Icon(
                                                                actList[index -
                                                                    1]
                                                                    .active ==
                                                                    1
                                                                    ? Icons
                                                                    .delete
                                                                    : Icons
                                                                    .restore,
                                                              ),
                                                              color: Color(
                                                                  0xff0957FF),
                                                              onPressed: () {
                                                                showDialog(
                                                                  context:
                                                                  context,
                                                                  builder:
                                                                      (
                                                                      context) =>
                                                                  new AlertDialog(
                                                                    title:
                                                                    Text(
                                                                      AppLocalizations
                                                                          .of(
                                                                          context)
                                                                          .translate(
                                                                          'areYouSureDialog'),
                                                                      style:
                                                                      GoogleFonts.lato(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        fontSize:
                                                                        25,
                                                                      ),
                                                                    ),
                                                                    content:
                                                                    RichText(
                                                                      text: TextSpan(
                                                                          text:
                                                                          "${actList[index -
                                                                              1]
                                                                              .comment
                                                                              .length >
                                                                              0
                                                                              ? actList[index -
                                                                              1]
                                                                              .comment
                                                                              : AppLocalizations
                                                                              .of(
                                                                              context)
                                                                              .translate(
                                                                              'noCommentAvailable')}\n\n",
                                                                          style: GoogleFonts.lato(
                                                                              color: Color(
                                                                                  0xff2B2B2B),
                                                                              fontSize: 15,
                                                                              fontStyle: FontStyle
                                                                                  .italic),
                                                                          children: <
                                                                              TextSpan>[
                                                                            TextSpan(
                                                                              text: AppLocalizations
                                                                                  .of(
                                                                                  context)
                                                                                  .translate(
                                                                                  'EntryFrom'),
                                                                              style: GoogleFonts.lato(
                                                                                fontSize: 18,
                                                                              ),
                                                                            ),
                                                                            TextSpan(
                                                                              text: '${actList[index -
                                                                                  1]
                                                                                  .date} ',
                                                                              style: GoogleFonts.lato(
                                                                                  color: Color(
                                                                                      0xFF0957FF),
                                                                                  fontSize: 18,
                                                                                  fontWeight: FontWeight
                                                                                      .bold),
                                                                            ),
                                                                            TextSpan(
                                                                              text: AppLocalizations
                                                                                  .of(
                                                                                  context)
                                                                                  .translate(
                                                                                  'withAnAmountOf'),
                                                                              style: GoogleFonts.lato(
                                                                                fontSize: 18,
                                                                              ),
                                                                            ),
                                                                            TextSpan(
                                                                              text: '${actList[index -
                                                                                  1]
                                                                                  .amount} ',
                                                                              style: GoogleFonts.lato(
                                                                                  color: Color(
                                                                                      0xFF0957FF),
                                                                                  fontSize: 18,
                                                                                  fontWeight: FontWeight
                                                                                      .bold),
                                                                            ),
                                                                            TextSpan(
                                                                              text: AppLocalizations
                                                                                  .of(
                                                                                  context)
                                                                                  .translate(
                                                                                  'willBe'),
                                                                              style: GoogleFonts.lato(
                                                                                fontSize: 18,
                                                                              ),
                                                                            ),
                                                                            TextSpan(
                                                                              text: '${actList[index -
                                                                                  1]
                                                                                  .active ==
                                                                                  1
                                                                                  ? AppLocalizations
                                                                                  .of(
                                                                                  context)
                                                                                  .translate(
                                                                                  'deleted')
                                                                                  : AppLocalizations
                                                                                  .of(
                                                                                  context)
                                                                                  .translate(
                                                                                  'restored')}',
                                                                              style: GoogleFonts.lato(
                                                                                  color: actList[index -
                                                                                      1]
                                                                                      .active ==
                                                                                      1
                                                                                      ? Colors
                                                                                      .red
                                                                                      : Colors
                                                                                      .green,
                                                                                  fontSize: 18,
                                                                                  fontWeight: FontWeight
                                                                                      .bold),
                                                                            ),
                                                                          ]),
                                                                    ),
                                                                    actions: <
                                                                        Widget>[
                                                                      new FlatButton(
                                                                        child:
                                                                        new Text(
                                                                            AppLocalizations
                                                                                .of(
                                                                                context)
                                                                                .translate(
                                                                                'cancel'), style: GoogleFonts.lato()),
                                                                        onPressed: () =>
                                                                            Navigator
                                                                                .of(
                                                                                context)
                                                                                .pop(),
                                                                      ),
                                                                      new Container(
                                                                        margin: EdgeInsets
                                                                            .only(
                                                                            left: 2,
                                                                            right: 2,
                                                                            bottom: 10),
                                                                        child: ConfirmationSlider(
                                                                          text: AppLocalizations
                                                                              .of(
                                                                              context)
                                                                              .translate(
                                                                              'slideToConfirm'),
                                                                          foregroundColor: Color(
                                                                              0xff0957FF),
                                                                          onConfirmation: () {
                                                                            actObjectToDelete
                                                                                .id =
                                                                                actList[index -
                                                                                    1]
                                                                                    .id;

                                                                            sendBackend(
                                                                                'actlistdelete',
                                                                                false);
                                                                            Navigator
                                                                                .of(
                                                                                context)
                                                                                .pop();
                                                                          },
                                                                        ),
                                                                      ),
                                                                      /*new FlatButton(
                                                                      child:
                                                                      new Text(
                                                                          AppLocalizations
                                                                              .of(
                                                                              context)
                                                                              .translate(
                                                                              'confirm')),
                                                                      onPressed:
                                                                          () {
                                                                        actObjectToDelete
                                                                            .id =
                                                                            actList[index -
                                                                                1]
                                                                                .id;

                                                                        sendBackend(
                                                                            'actlistdelete',
                                                                            false);
                                                                        Navigator
                                                                            .of(
                                                                            context)
                                                                            .pop();
                                                                      },
                                                                    )*/
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          )
                                                        ]),
                                                  ])),
                                        ))
                                        : Container())
                                    ,
                                    currentlyLoading && index ==
                                        2 // to show a bit more in the middle and only one circle, instead of one per item in the listview
                                        ?
                                    _showLoadWidget()
                                        : Container(),
                                  ],);
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
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xff003680),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                Text(
                                  AppLocalizations.of(context)
                                      .translate('TitleInputTab'),
                                  style: GoogleFonts.lato(color: Colors.white),
                                )
                              ]),
                        ),
                      ),
                      Tab(
                        child: Container(
                          alignment: Alignment.center,
                          //constraints: BoxConstraints.expand(width: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xff003680),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                                Text(
                                  AppLocalizations.of(context)
                                      .translate('TitleListTab'),
                                  style: GoogleFonts.lato(color: Colors.white),
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
                                      _refreshController.refreshCompleted();
                                    },
                                    child: Stack(
                                      children: <Widget>[LayoutBuilder(
                                        builder: (context, constraint) {
                                          return SingleChildScrollView(
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    minHeight: constraint
                                                        .maxHeight),
                                                child: IntrinsicHeight(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                      children: <Widget>[
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                            children: <Widget>[
                                                              ButtonTheme(
                                                                //minWidth: 150.0,
                                                                height: 60.0,
                                                                child: FlatButton(
                                                                  onPressed: () =>
                                                                      _showDatePicker(
                                                                          'budget',
                                                                          dateTimeBudget),
                                                                  shape:
                                                                  new RoundedRectangleBorder(
                                                                    borderRadius:
                                                                    new BorderRadius
                                                                        .circular(
                                                                        40.0),
                                                                  ),
                                                                  color:
                                                                  Color(
                                                                      0xff003680),
                                                                  padding: EdgeInsets
                                                                      .all(
                                                                      10.0),
                                                                  child: Row(
                                                                    // Replace with a Row for horizontal icon + text
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                          " ${dateTimeBudget
                                                                              .year
                                                                              .toString()}-${dateTimeBudget
                                                                              .month
                                                                              .toString()
                                                                              .padLeft(
                                                                              2,
                                                                              '0')}",
                                                                          style: GoogleFonts.lato(
                                                                              color: Colors
                                                                                  .white,
                                                                              fontSize:
                                                                              17)),
                                                                      SizedBox(
                                                                          width: 10),
                                                                      Icon(
                                                                        Icons
                                                                            .calendar_today,
                                                                        color:
                                                                        Colors
                                                                            .white,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ]),
                                                        Container(
                                                            padding: const EdgeInsets
                                                                .only(
                                                                left: 30.0,
                                                                top: 0,
                                                                right: 30,
                                                                bottom: 0),
                                                            //color: Colors.blue[600],
                                                            alignment: Alignment
                                                                .center,
                                                            //child: Text('Submit'),
                                                            child: Stack(
                                                              alignment:
                                                              const Alignment(
                                                                  1, 1.0),
                                                              children: <
                                                                  Widget>[
                                                                TextFormField(
                                                                  keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                                  //keyboard with numbers only will appear to the screen
                                                                  style: GoogleFonts.lato(
                                                                      height: 2),
                                                                  //increases the height of cursor
                                                                  //autofocus: true,
                                                                  controller:
                                                                  budgetTextFieldController,
                                                                  validator: numberValidator,
                                                                  decoration: InputDecoration(
                                                                    // hintText: 'Enter ur amount',
                                                                    //hintStyle: GoogleFonts.lato(height: 1.75),
                                                                      labelText: AppLocalizations
                                                                          .of(
                                                                          context)
                                                                          .translate(
                                                                          'TextFieldAmountInput'),
                                                                      labelStyle: GoogleFonts.lato(
                                                                          height: 0.5,
                                                                          color: Color(
                                                                              0xff0957FF)),
                                                                      //increases the height of cursor
                                                                      icon: Icon(
                                                                        Icons
                                                                            .attach_money,
                                                                        color:
                                                                        Color(
                                                                            0xff0957FF),
                                                                      ),
                                                                      //prefixIcon: Icon(Icons.attach_money),
                                                                      //labelStyle: GoogleFonts.lato(color: Color(0xff0957FF)),
                                                                      enabledBorder:
                                                                      new UnderlineInputBorder(
                                                                          borderSide:
                                                                          new BorderSide(
                                                                              color: Color(
                                                                                  0xff0957FF)))),
                                                                ),
                                                                new FlatButton(
                                                                    onPressed: () {
                                                                      budgetTextFieldController
                                                                          .clear();
                                                                    },
                                                                    child:
                                                                    new Icon(
                                                                        Icons
                                                                            .clear))
                                                              ],)
                                                        ),
                                                        areLevel1AccountsActive
                                                            ? Container(
                                                          padding:
                                                          const EdgeInsets.only(
                                                              left: 30.0,
                                                              top: 0,
                                                              right: 30,
                                                              bottom: 0),
                                                          //color: Colors.blue[600],
                                                          alignment:
                                                          Alignment.center,
                                                          //child: Text('Submit'),
                                                          child:
                                                          SearchChoices.single(
                                                            items:
                                                            level1BudgetAccountsList
                                                                .map((Account
                                                            account) {
                                                              return new DropdownMenuItem<
                                                                  Account>(
                                                                value: account,
                                                                child: new Text(
                                                                  account.name, style: GoogleFonts.lato()
                                                                ),
                                                              );
                                                            }).toList(),
                                                            style: GoogleFonts.lato(
                                                                color: Color(
                                                                    0xff0957FF)),
                                                            value:
                                                            level1BudgetObject,
                                                            underline: Container(
                                                              height: 2,
                                                              width: 5000,
                                                              color:
                                                              Color(0xff0957FF),
                                                            ),
                                                            hint:
                                                            AppLocalizations
                                                                .of(
                                                                context)
                                                                .translate(
                                                                'select_one_account'),
                                                            searchHint:
                                                            AppLocalizations
                                                                .of(
                                                                context)
                                                                .translate(
                                                                'select_one_account'),
                                                            onClear: () {
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
                                                              });
                                                            },
                                                            onChanged: (
                                                                value) async {
                                                              if (value !=
                                                                  null) {
                                                                setState(() {
                                                                  level1BudgetObject =
                                                                      value;

                                                                  currentlyLoading =
                                                                  true;
                                                                });

                                                                await arrangeAccounts(
                                                                    1,
                                                                    'budget');

                                                                setState(() {
                                                                  currentlyLoading =
                                                                  false;
                                                                });
                                                              }
                                                            },
                                                            dialogBox: true,
                                                            isExpanded: true,
                                                          ),
                                                        )
                                                            : Container(),
                                                        areLevel2AccountsActive
                                                            ? Container(
                                                          padding:
                                                          const EdgeInsets.only(
                                                              left: 30.0,
                                                              top: 0,
                                                              right: 30,
                                                              bottom: 0),
                                                          //color: Colors.blue[600],

                                                          alignment:
                                                          Alignment.center,
                                                          //child: Text('Submit'),
                                                          child:
                                                          SearchChoices.single(
                                                            items:
                                                            level2BudgetAccountsList
                                                                .map((Account
                                                            account) {
                                                              return new DropdownMenuItem<
                                                                  Account>(
                                                                value: account,
                                                                child: new Text(
                                                                  account.name, style: GoogleFonts.lato()
                                                                ),
                                                              );
                                                            }).toList(),
                                                            style: GoogleFonts.lato(
                                                                color: level1BudgetObject
                                                                    .id <=
                                                                    0
                                                                    ? Colors
                                                                    .grey
                                                                    : Color(
                                                                    0xff0957FF)),
                                                            value:
                                                            level2BudgetObject,
                                                            readOnly: level1BudgetObject
                                                                .id <=
                                                                0 ||
                                                                level2BudgetAccountsList
                                                                    .length <=
                                                                    1 ||
                                                                currentlyLoading,
                                                            underline: Container(
                                                              height: 2,
                                                              width: 5000,
                                                              color: level1BudgetObject
                                                                  .id <=
                                                                  0
                                                                  ? Colors.grey
                                                                  :
                                                              Color(0xff0957FF),
                                                            ),
                                                            hint:
                                                            AppLocalizations
                                                                .of(
                                                                context)
                                                                .translate(
                                                                'select_one_account'),
                                                            searchHint:
                                                            AppLocalizations
                                                                .of(
                                                                context)
                                                                .translate(
                                                                'select_one_account'),
                                                            onClear: () {
                                                              setState(() {
                                                                level2BudgetObject =
                                                                level2BudgetAccountsList[
                                                                0];

                                                                level3BudgetObject =
                                                                level3BudgetAccountsList[
                                                                0];
                                                              });
                                                            },
                                                            onChanged: (
                                                                value) async {
                                                              if (value !=
                                                                  null) {
                                                                // Check if a new value was selected or the same was reselected
                                                                dummyAccount =
                                                                    level2BudgetObject;

                                                                setState(() {
                                                                  level2BudgetObject =
                                                                      value;

                                                                  currentlyLoading =
                                                                  true;
                                                                });

                                                                if (dummyAccount
                                                                    .id !=
                                                                    value.id) {
                                                                  await arrangeAccounts(
                                                                      2,
                                                                      'budget');
                                                                } else {
                                                                  print(
                                                                      "RESELECTED");
                                                                }

                                                                setState(() {
                                                                  currentlyLoading =
                                                                  false;
                                                                });
                                                              }
                                                            },
                                                            dialogBox: true,
                                                            isExpanded: true,
                                                          ),
                                                        )
                                                            : Container(),
                                                        areLevel3AccountsActive
                                                            ? Container(
                                                          padding:
                                                          const EdgeInsets.only(
                                                              left: 30.0,
                                                              top: 0,
                                                              right: 30,
                                                              bottom: 0),
                                                          //color: Colors.blue[600],
                                                          alignment:
                                                          Alignment.center,
                                                          //child: Text('Submit'),
                                                          child:
                                                          SearchChoices.single(
                                                            items:
                                                            level3BudgetAccountsList
                                                                .map((Account
                                                            account) {
                                                              return new DropdownMenuItem<
                                                                  Account>(
                                                                value: account,
                                                                child: new Text(
                                                                  account.name, style: GoogleFonts.lato()
                                                                ),
                                                              );
                                                            }).toList(),
                                                            style: GoogleFonts.lato(
                                                                color: level2BudgetObject
                                                                    .id <=
                                                                    0
                                                                    ? Colors
                                                                    .grey
                                                                    : Color(
                                                                    0xff0957FF)),
                                                            value:
                                                            level3BudgetObject,
                                                            readOnly: level2BudgetObject
                                                                .id <=
                                                                0 ||
                                                                level3BudgetAccountsList
                                                                    .length <=
                                                                    1 ||
                                                                currentlyLoading,
                                                            underline: Container(
                                                              height: 2,
                                                              width: 5000,
                                                              color: level2BudgetObject
                                                                  .id <=
                                                                  0
                                                                  ? Colors.grey
                                                                  :
                                                              Color(0xff0957FF),
                                                            ),
                                                            hint:
                                                            AppLocalizations
                                                                .of(
                                                                context)
                                                                .translate(
                                                                'select_one_account'),
                                                            searchHint:
                                                            AppLocalizations
                                                                .of(
                                                                context)
                                                                .translate(
                                                                'select_one_account'),
                                                            onClear: () {
                                                              setState(() {
                                                                level3BudgetObject =
                                                                level3BudgetAccountsList[
                                                                0];
                                                              });
                                                            },
                                                            // The default object is set again
                                                            onChanged: (value) {
                                                              if (value !=
                                                                  null) {
                                                                setState(() {
                                                                  level3BudgetObject =
                                                                      value;
                                                                });
                                                              }
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
                                                            : SizedBox(
                                                            height: 20),
                                                        areCostTypesActive
                                                            ? Container(
                                                          constraints:
                                                          BoxConstraints.expand(
                                                            height: 80,
                                                            //width: MediaQuery.of(context).size.width * .8
                                                          ),
                                                          padding:
                                                          const EdgeInsets.only(
                                                              left: 30.0,
                                                              top: 0,
                                                              right: 30,
                                                              bottom: 0),
                                                          //color: Colors.blue[600],
                                                          alignment:
                                                          Alignment.center,
                                                          //child: Text('Submit'),
                                                          child: Align(
                                                            alignment:
                                                            Alignment.topRight,
                                                            child: SearchChoices
                                                                .single(
                                                              value:
                                                              costTypeObjectBudget,
                                                              hint: AppLocalizations
                                                                  .of(
                                                                  context)
                                                                  .translate(
                                                                  'select_one_costtype'),
                                                              searchHint: AppLocalizations
                                                                  .of(
                                                                  context)
                                                                  .translate(
                                                                  'select_one_costtype'),
                                                              icon: Icon(Icons
                                                                  .arrow_downward),
                                                              iconSize: 24,
                                                              style: GoogleFonts.lato(
                                                                  color: Color(
                                                                      0xff0957FF)),
                                                              //isExpanded: true,
                                                              underline: Container(
                                                                height: 2,
                                                                width: 2000,
                                                                color: Color(
                                                                    0xff0957FF),
                                                              ),
                                                              onClear: () {
                                                                setState(() {
                                                                  costTypeObjectBudget =
                                                                  costTypesList[
                                                                  0];
                                                                });
                                                              },
                                                              onChanged: (
                                                                  CostType
                                                                  newValue) {
                                                                if (newValue !=
                                                                    null) {
                                                                  setState(() {
                                                                    costTypeObjectBudget =
                                                                        newValue;
                                                                  });
                                                                }
                                                              },
                                                              items: costTypesList
                                                                  .map((CostType
                                                              type) {
                                                                return new DropdownMenuItem<
                                                                    CostType>(
                                                                  value: type,
                                                                  child: new Text(
                                                                    type.name, style: GoogleFonts.lato()
                                                                  ),
                                                                );
                                                              }).toList(),
                                                            ),
                                                          ),
                                                        )
                                                            : Container(),
                                                        ButtonBar(
                                                          mainAxisSize: MainAxisSize
                                                              .min,
                                                          // this will take space as minimum as posible(to center)
                                                          children: <Widget>[
                                                            ButtonTheme(
                                                              minWidth: 75.0,
                                                              height: 40.0,
                                                              child: RaisedButton(
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: new BorderRadius
                                                                      .circular(
                                                                      50.0),
                                                                ),
                                                                child: Text(
                                                                  AppLocalizations
                                                                      .of(
                                                                      context)
                                                                      .translate(
                                                                      'DiscardButton'), style: GoogleFonts.lato()
                                                                ),
                                                                color: Color(
                                                                    0xffEEEEEE),
                                                                // EEEEEE
                                                                onPressed: () {
                                                                  budgetTextFieldController
                                                                      .text =
                                                                  '';
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
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: new BorderRadius
                                                                      .circular(
                                                                      50.0),
                                                                ),
                                                                child: Text(
                                                                    AppLocalizations
                                                                        .of(
                                                                        context)
                                                                        .translate(
                                                                        'addButton'),
                                                                    style: GoogleFonts.lato(
                                                                        color:
                                                                        Colors
                                                                            .white,
                                                                        fontSize: 17)),
                                                                color: Color(
                                                                    0xff0957FF),
                                                                //df7599 - 0957FF
                                                                onPressed: () {
                                                                  if (budgetTextFieldController
                                                                      .text
                                                                      .length >
                                                                      0 &&
                                                                      numberValidator(
                                                                          budgetTextFieldController
                                                                              .text
                                                                      ) ==
                                                                          null) {
                                                                    print(
                                                                        numberValidator(
                                                                            budgetTextFieldController
                                                                                .text));

                                                                    commentInput(
                                                                        context,
                                                                        'budget',
                                                                        null,
                                                                        null,
                                                                        null);
                                                                  }
                                                                  else {
                                                                    showDialog(
                                                                      context: context,
                                                                      builder: (
                                                                          BuildContext context) {
                                                                        // return object of type Dialog
                                                                        return AlertDialog(
                                                                          title: new Text(
                                                                            AppLocalizations
                                                                                .of(
                                                                                context)
                                                                                .translate(
                                                                                'warning')
                                                                            ,
                                                                            style: GoogleFonts.lato(
                                                                                color: Colors
                                                                                    .orange,
                                                                                fontSize: 25,
                                                                                fontWeight: FontWeight
                                                                                    .bold),),
                                                                          content: new Text(
                                                                            // #157 differentiate message betweeen nothing entered and invalid number entered
                                                                            budgetTextFieldController
                                                                                .text
                                                                                .length ==
                                                                                0
                                                                                ?
                                                                            AppLocalizations
                                                                                .of(
                                                                                context)
                                                                                .translate(
                                                                                'errorInputEnterAmount')
                                                                                : AppLocalizations
                                                                                .of(
                                                                                context)
                                                                                .translate(
                                                                                'errorInputInvalidAmount'),
                                                                            style: GoogleFonts.lato(
                                                                                fontWeight: FontWeight
                                                                                    .bold,
                                                                                fontSize: 20),),
                                                                          actions: <
                                                                              Widget>[
                                                                            // usually buttons at the bottom of the dialog
                                                                            new FlatButton(
                                                                              child: new Text(
                                                                                  "Close", style: GoogleFonts.lato()),
                                                                              onPressed: () {
                                                                                Navigator
                                                                                    .of(
                                                                                    context)
                                                                                    .pop();
                                                                              },
                                                                            ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    );
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    )
                                                ),
                                              ));
                                        },
                                      ), currentlyLoading
                                          ?
                                      _showLoadWidget()
                                          : Container(),
                                      ],)),
                              ),
                            ],
                          ),
                        ),
                        SmartRefresher(
                            controller: _refreshController,
                            enablePullDown: true,
                            onRefresh: () async {
                              await handleRefresh(_currentIndex);
                              _refreshController.refreshCompleted();
                            },
                            child:
                            ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: bdgList.length + 1,
                                // Length + 1 as the 0 index is the sort button, all other use index - 1
                                itemBuilder: (BuildContext context,
                                    int index) {
                                  return Stack(children: <Widget>[
                                    index == 0
                                        ? Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Flexible(
                                              child: TextFormField(
                                                  autofocus: false,
                                                  onChanged: (value) {
                                                    setState(() {});
                                                  },
                                                  controller:
                                                  budgetSearchTextFieldController,
                                                  decoration:
                                                  InputDecoration(
                                                    // hintText: 'Enter ur amount',
                                                    //hintStyle: GoogleFonts.lato(height: 1.75),
                                                    labelText: AppLocalizations
                                                        .of(context)
                                                        .translate(
                                                        'ListSearchTextField'),
                                                    //increases the height of cursor
                                                    icon: Icon(
                                                      Icons.search,
                                                    ),
                                                  ))),
                                          IconButton(
                                              icon: Icon(Icons.clear),
                                              color: Color(0xff003680),
                                              alignment:
                                              Alignment.centerRight,
                                              iconSize: 25,
                                              onPressed: () {
                                                setState(() {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  budgetSearchTextFieldController
                                                      .clear();
                                                });
                                              }),
                                          IconButton(
                                              icon: Icon(Icons.sort),
                                              color: Color(0xff003680),
                                              alignment:
                                              Alignment.centerRight,
                                              iconSize: 25,
                                              onPressed: () {
                                                showDialog<void>(
                                                  context: context,
                                                  builder: (
                                                      BuildContext context) {
                                                    return AlertDialog(
                                                      content: StatefulBuilder(
                                                        builder: (
                                                            BuildContext context,
                                                            StateSetter setState) {
                                                          return Column(
                                                              mainAxisSize: MainAxisSize
                                                                  .min,
                                                              children: List<
                                                                  Widget>.generate(
                                                                  sortBudgetOrders
                                                                      .length +
                                                                      1 /* + 1 because position zero is the sort switch*/, (
                                                                  int index) {
                                                                return
                                                                  index == 0
                                                                      ?
                                                                  Row(
                                                                      mainAxisAlignment: MainAxisAlignment
                                                                          .center,
                                                                      children: <
                                                                          Widget>[
                                                                        Text(
                                                                          AppLocalizations
                                                                              .of(
                                                                              context)
                                                                              .translate(
                                                                              'orderAsc'),
                                                                          overflow: TextOverflow
                                                                              .ellipsis, style: GoogleFonts.lato()),
                                                                        Switch(
                                                                          value: sortBudgetDescending,
                                                                          onChanged: (
                                                                              value) {
                                                                            setState(() {
                                                                              sortBudgetDescending =
                                                                                  value;
                                                                              handleOrderDialog(
                                                                                  -1,
                                                                                  'budget');
                                                                              Navigator
                                                                                  .pop(
                                                                                  context);
                                                                            });
                                                                          },
                                                                          activeTrackColor: Color(
                                                                              0xffEEEEEE),
                                                                          activeColor: Color(
                                                                              0xff0957FF),
                                                                        ),
                                                                        Text(
                                                                          AppLocalizations
                                                                              .of(
                                                                              context)
                                                                              .translate(
                                                                              'orderDesc'),
                                                                          overflow: TextOverflow
                                                                              .ellipsis, style: GoogleFonts.lato()),
                                                                      ])
                                                                      : Row(
                                                                    children: <
                                                                        Widget>[
                                                                      Radio<
                                                                          bool>(
                                                                        groupValue: true,
                                                                        value: sortBudgetOrders[index -
                                                                            1],
                                                                        activeColor: Color(
                                                                            0xFF0957FF),
                                                                        onChanged: (
                                                                            bool newValue) {
                                                                          setState(() {
                                                                            print(
                                                                                newValue);

                                                                            sortBudgetOrders[0] =
                                                                            false;
                                                                            sortBudgetOrders[1] =
                                                                            false;
                                                                            sortBudgetOrders[2] =
                                                                            false;
                                                                            sortBudgetOrders[3] =
                                                                            false;
                                                                            sortBudgetOrders[4] =
                                                                            false;

                                                                            sortBudgetOrders[index -
                                                                                1] =
                                                                            true;
                                                                          });

                                                                          handleOrderDialog(
                                                                              (index -
                                                                                  1),
                                                                              'budget');

                                                                          Navigator
                                                                              .pop(
                                                                              context);
                                                                        },
                                                                      ),
                                                                      Flexible(
                                                                          child: Text(
                                                                            AppLocalizations
                                                                                .of(
                                                                                context)
                                                                                .translate(
                                                                                '${index -
                                                                                    1}OrderText'),
                                                                            overflow: TextOverflow
                                                                                .clip, style: GoogleFonts.lato()
                                                                          )),
                                                                    ],
                                                                  );
                                                              }));
                                                        },
                                                      ),
                                                    );
                                                  },);

                                                /*return showDialog(
                                                  context: context,
                                                  barrierDismissible:
                                                  true,
                                                  builder: (BuildContext
                                                  context) {
                                                    return SimpleDialog(
                                                      title: Text(
                                                          AppLocalizations.of(
                                                              context)
                                                              .translate(
                                                              'OrderByText')),
                                                      children: <Widget>[
                                                        SimpleDialogOption(
                                                          onPressed: () {
                                                            // When its the same again
                                                            //   - switch the the opposite (either asc or desc whatever it was)
                                                            // When it was fresh switched to level1
                                                            //   - set it to the default -> desc
                                                            budgetListSortType =
                                                            budgetListSortColumn ==
                                                                'created'
                                                                ? (budgetListSortType ==
                                                                'asc'
                                                                ? 'desc'
                                                                : 'asc')
                                                                : 'desc';

                                                            budgetListSortColumn =
                                                            'created';
                                                            loadList(
                                                                'budget',
                                                                budgetListSortColumn,
                                                                budgetListSortType);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text(
                                                              AppLocalizations
                                                                  .of(
                                                                  context)
                                                                  .translate(
                                                                  'DateOfCreationOrderText')),
                                                        ),
                                                        SimpleDialogOption(
                                                          onPressed: () {
                                                            // When its the same again
                                                            //   - switch the the opposite (either asc or desc whatever it was)
                                                            // When it was fresh switched to data_date
                                                            //   - set it to the default -> desc
                                                            budgetListSortType =
                                                            budgetListSortColumn ==
                                                                'data_date'
                                                                ? (budgetListSortType ==
                                                                'asc'
                                                                ? 'desc'
                                                                : 'asc')
                                                                : 'desc';

                                                            budgetListSortColumn =
                                                            'data_date';
                                                            loadList(
                                                                'budget',
                                                                budgetListSortColumn,
                                                                budgetListSortType);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text(
                                                              AppLocalizations
                                                                  .of(
                                                                  context)
                                                                  .translate(
                                                                  'MonthBilledOrderText')),
                                                        ),
                                                        SimpleDialogOption(
                                                          onPressed: () {
                                                            // When its the same again
                                                            //   - switch the the opposite (either asc or desc whatever it was)
                                                            // When it was fresh switched to amount
                                                            //   - set it to the default -> desc
                                                            budgetListSortType =
                                                            budgetListSortColumn ==
                                                                'amount'
                                                                ? (budgetListSortType ==
                                                                'asc'
                                                                ? 'desc'
                                                                : 'asc')
                                                                : 'desc';

                                                            budgetListSortColumn =
                                                            'amount';
                                                            loadList(
                                                                'budget',
                                                                budgetListSortColumn,
                                                                budgetListSortType);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text(
                                                              AppLocalizations
                                                                  .of(
                                                                  context)
                                                                  .translate(
                                                                  'AmountOrderText')),
                                                        ),
                                                        SimpleDialogOption(
                                                          onPressed: () {
                                                            // When its the same again
                                                            //   - switch the the opposite (either asc or desc whatever it was)
                                                            // When it was fresh switched to costtype
                                                            //   - set it to the default -> desc
                                                            budgetListSortType =
                                                            budgetListSortColumn ==
                                                                'costtype'
                                                                ? (budgetListSortType ==
                                                                'asc'
                                                                ? 'desc'
                                                                : 'asc')
                                                                : 'desc';

                                                            budgetListSortColumn =
                                                            'costtype';
                                                            loadList(
                                                                'budget',
                                                                budgetListSortColumn,
                                                                budgetListSortType);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text(
                                                              AppLocalizations
                                                                  .of(
                                                                  context)
                                                                  .translate(
                                                                  'CostTypeOrderText')),
                                                        ),
                                                        SimpleDialogOption(
                                                          onPressed: () {
                                                            // When its the same again
                                                            //   - switch the the opposite (either asc or desc whatever it was)
                                                            // When it was fresh switched to level1
                                                            //   - set it to the default -> desc
                                                            budgetListSortType =
                                                            budgetListSortColumn ==
                                                                'level1'
                                                                ? (budgetListSortType ==
                                                                'asc'
                                                                ? 'desc'
                                                                : 'asc')
                                                                : 'desc';

                                                            budgetListSortColumn =
                                                            'level1';
                                                            loadList(
                                                                'budget',
                                                                budgetListSortColumn,
                                                                budgetListSortType);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text(
                                                              AppLocalizations
                                                                  .of(
                                                                  context)
                                                                  .translate(
                                                                  'LevelOrderText')),
                                                        )
                                                      ],
                                                    );
                                                  });*/
                                              })
                                        ])
                                        : ((bdgList[index - 1]
                                        .costType
                                        .toLowerCase()
                                        .contains(
                                        budgetSearchTextFieldController
                                            .text) ||
                                        bdgList[index - 1]
                                            .level1
                                            .toLowerCase()
                                            .contains(
                                            budgetSearchTextFieldController
                                                .text) ||
                                        bdgList[index - 1]
                                            .level2
                                            .toLowerCase()
                                            .contains(
                                            budgetSearchTextFieldController
                                                .text) ||
                                        bdgList[index - 1]
                                            .level3
                                            .toLowerCase()
                                            .contains(
                                            budgetSearchTextFieldController
                                                .text) ||
                                        bdgList[index - 1]
                                            .comment
                                            .toLowerCase()
                                            .contains(
                                            budgetSearchTextFieldController
                                                .text) ||
                                        bdgList[index - 1].amount.toString()
                                            .contains(
                                            budgetSearchTextFieldController
                                                .text) ||
                                        bdgList[index - 1].level1.toLowerCase()
                                            .contains(
                                            budgetSearchTextFieldController
                                                .text) ||
                                        bdgList[index - 1].date.toLowerCase()
                                            .contains(
                                            budgetSearchTextFieldController
                                                .text))
                                        ? GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                            new AlertDialog(
                                              title: Text(
                                                AppLocalizations.of(
                                                    context)
                                                    .translate(
                                                    'DetailsListTitle'),
                                                style: GoogleFonts.lato(
                                                  color: Color(
                                                      0xff2B2B2B),
                                                  fontSize: 25,
                                                ),
                                              ),
                                              content: RichText(
                                                text: TextSpan(
                                                    text: "",
                                                    style: GoogleFonts.lato(
                                                      color: Color(
                                                          0xff2B2B2B),
                                                      fontSize: 15,
                                                    ),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                        text: AppLocalizations
                                                            .of(
                                                            context)
                                                            .translate(
                                                            'DetailsListDate'),
                                                        style: GoogleFonts.lato(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                        '${bdgList[index - 1]
                                                            .date}\n',
                                                        style: GoogleFonts.lato(
                                                            color: Color(
                                                                0xFF0957FF),
                                                            fontSize: 18,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontStyle:
                                                            FontStyle
                                                                .italic),
                                                      ),
                                                      TextSpan(
                                                        text: AppLocalizations
                                                            .of(
                                                            context)
                                                            .translate(
                                                            'DetailsListAmount'),
                                                        style: GoogleFonts.lato(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                        '${bdgList[index - 1]
                                                            .amount}\n',
                                                        style: GoogleFonts.lato(
                                                            color: Color(
                                                                0xFF0957FF),
                                                            fontSize: 18,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontStyle:
                                                            FontStyle
                                                                .italic),
                                                      ),
                                                      TextSpan(
                                                        text: AppLocalizations
                                                            .of(
                                                            context)
                                                            .translate(
                                                            'DetailsListLevel'),
                                                        style: GoogleFonts.lato(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                        '${bdgList[index - 1]
                                                            .level1} > ${bdgList[index -
                                                            1]
                                                            .level2} > ${bdgList[index -
                                                            1].level3}\n',
                                                        style: GoogleFonts.lato(
                                                            color: Color(
                                                                0xFF0957FF),
                                                            fontSize: 18,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontStyle:
                                                            FontStyle
                                                                .italic),
                                                      ),
                                                      TextSpan(
                                                        text: AppLocalizations
                                                            .of(
                                                            context)
                                                            .translate(
                                                            'DetailsListCostType'),
                                                        style: GoogleFonts.lato(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                        '${bdgList[index - 1]
                                                            .costType}\n',
                                                        style: GoogleFonts.lato(
                                                            color: Color(
                                                                0xFF0957FF),
                                                            fontSize: 18,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontStyle:
                                                            FontStyle
                                                                .italic),
                                                      ),
                                                      TextSpan(
                                                        text: AppLocalizations
                                                            .of(
                                                            context)
                                                            .translate(
                                                            'DetailsListComment'),
                                                        style: GoogleFonts.lato(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                        '${bdgList[index - 1]
                                                            .comment.length > 0
                                                            ? bdgList[index - 1]
                                                            .comment
                                                            : AppLocalizations
                                                            .of(
                                                            context).translate(
                                                            'noCommentAvailable')}\n',
                                                        style: GoogleFonts.lato(
                                                            color: Color(
                                                                0xFF0957FF),
                                                            fontSize: 18,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontStyle:
                                                            FontStyle
                                                                .italic),
                                                      ),
                                                    ]),
                                              ),
                                              actions: <Widget>[
                                                new FlatButton(
                                                  child: new Text(
                                                    AppLocalizations.of(
                                                        context)
                                                        .translate(
                                                        'dismissDialog'), style: GoogleFonts.lato()
                                                  ),
                                                  onPressed: () =>
                                                      Navigator.of(
                                                          context)
                                                          .pop(),
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                        child: Container(
                                          margin:
                                          const EdgeInsets.all(15.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.blueAccent),
                                            color: bdgList[index - 1]
                                                .active ==
                                                1
                                                ? Color(0xffEEEEEE)
                                                : Colors.redAccent,
                                            borderRadius:
                                            new BorderRadius.circular(
                                                30.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(
                                                    0xff2B2B2B),
                                                blurRadius: 5,
                                                // has the effect of softening the shadow
                                                spreadRadius: 0,
                                                // has the effect of extending the shadow
                                                offset: Offset(
                                                  7.0,
                                                  // horizontal, move right 10
                                                  7.0, // vertical, move down 10
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
                                                  CrossAxisAlignment
                                                      .center,
                                                  children: <Widget>[
                                                    SizedBox(
                                                      width: MediaQuery
                                                          .of(
                                                          context)
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
                                                            SizedBox(
                                                                height: 15),
                                                            Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                                children: [
                                                                  SizedBox(
                                                                    width: MediaQuery
                                                                        .of(
                                                                        context)
                                                                        .size
                                                                        .width *
                                                                        .1,
                                                                    child:
                                                                    Icon(
                                                                      Icons
                                                                          .account_balance_wallet,
                                                                      color: Color(
                                                                          0xff0957FF),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    "${bdgList[index -
                                                                        1]
                                                                        .date}",
                                                                    style: GoogleFonts.lato(
                                                                        color: Color(
                                                                            0xff0957FF),
                                                                        fontSize:
                                                                        25),
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
                                                                    width: MediaQuery
                                                                        .of(
                                                                        context)
                                                                        .size
                                                                        .width *
                                                                        .1,
                                                                    child:
                                                                    Container(),
                                                                  ),
                                                                  Flexible(
                                                                      child:
                                                                      Text(
                                                                        "${bdgList[index -
                                                                            1]
                                                                            .comment
                                                                            .length >
                                                                            0
                                                                            ? bdgList[index -
                                                                            1]
                                                                            .comment
                                                                            : AppLocalizations
                                                                            .of(
                                                                            context)
                                                                            .translate(
                                                                            'noCommentAvailable')}",
                                                                        style: GoogleFonts.lato(
                                                                            color: Color(
                                                                                0xff2B2B2B),
                                                                            fontStyle: FontStyle
                                                                                .italic,
                                                                            fontSize:
                                                                            15),
                                                                        overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                      )),
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
                                                                      width: MediaQuery
                                                                          .of(
                                                                          context)
                                                                          .size
                                                                          .width *
                                                                          .1,
                                                                      //height: 300.0,
                                                                      child:
                                                                      Container()),
                                                                  Flexible(
                                                                      child:
                                                                      Text(
                                                                        '${bdgList[index -
                                                                            1]
                                                                            .level1} > ${bdgList[index -
                                                                            1]
                                                                            .level2} > ${bdgList[index -
                                                                            1]
                                                                            .level3}}',
                                                                        style: GoogleFonts.lato(
                                                                            color: Color(
                                                                                0xff2B2B2B),
                                                                            fontSize:
                                                                            13),
                                                                        overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                      )),
                                                                ]),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                                children: [
                                                                  SizedBox(
                                                                      width: MediaQuery
                                                                          .of(
                                                                          context)
                                                                          .size
                                                                          .width *
                                                                          .1,
                                                                      //height: 300.0,
                                                                      child:
                                                                      Container()),
                                                                  Flexible(
                                                                      child: new Container(
                                                                          padding: new EdgeInsets
                                                                              .only(
                                                                              right: 13.0),
                                                                          child: Text(
                                                                            '${bdgList[index -
                                                                                1]
                                                                                .costType}',
                                                                            style: GoogleFonts.lato(
                                                                                color: Color(
                                                                                    0xff2B2B2B),
                                                                                fontSize: 13),
                                                                            overflow: TextOverflow
                                                                                .ellipsis,
                                                                          )))
                                                                ]),
                                                            SizedBox(
                                                              height: 15,
                                                            ),
                                                          ]),
                                                    ),
                                                    Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .start,
                                                        children: [
                                                          Text(
                                                              '${bdgList[index -
                                                                  1].amount}', style: GoogleFonts.lato()),
                                                          SizedBox(
                                                            width: MediaQuery
                                                                .of(
                                                                context)
                                                                .size
                                                                .width *
                                                                .1,
                                                            //height: 300.0,
                                                            child: IconButton(
                                                              icon: new Icon(
                                                                bdgList[index -
                                                                    1]
                                                                    .active ==
                                                                    1
                                                                    ? Icons
                                                                    .delete
                                                                    : Icons
                                                                    .restore,
                                                              ),
                                                              color: Color(
                                                                  0xff0957FF),
                                                              onPressed: () {
                                                                showDialog(
                                                                  context:
                                                                  context,
                                                                  builder:
                                                                      (
                                                                      context) =>
                                                                  new AlertDialog(
                                                                    title:
                                                                    Text(
                                                                      AppLocalizations
                                                                          .of(
                                                                          context)
                                                                          .translate(
                                                                          'areYouSureDialog'),
                                                                      style:
                                                                      GoogleFonts.lato(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        fontSize:
                                                                        25,
                                                                      ),
                                                                    ),
                                                                    content:
                                                                    RichText(
                                                                      text: TextSpan(
                                                                          text:
                                                                          "${bdgList[index -
                                                                              1]
                                                                              .comment
                                                                              .length >
                                                                              0
                                                                              ? bdgList[index -
                                                                              1]
                                                                              .comment
                                                                              : AppLocalizations
                                                                              .of(
                                                                              context)
                                                                              .translate(
                                                                              'noCommentAvailable')}\n\n",
                                                                          style: GoogleFonts.lato(
                                                                              color: Color(
                                                                                  0xff2B2B2B),
                                                                              fontSize: 15,
                                                                              fontStyle: FontStyle
                                                                                  .italic),
                                                                          children: <
                                                                              TextSpan>[
                                                                            TextSpan(
                                                                              text: AppLocalizations
                                                                                  .of(
                                                                                  context)
                                                                                  .translate(
                                                                                  'EntryFrom'),
                                                                              style: GoogleFonts.lato(
                                                                                fontSize: 18,
                                                                              ),
                                                                            ),
                                                                            TextSpan(
                                                                              text: '${bdgList[index -
                                                                                  1]
                                                                                  .date} ',
                                                                              style: GoogleFonts.lato(
                                                                                  color: Color(
                                                                                      0xFF0957FF),
                                                                                  fontSize: 18,
                                                                                  fontWeight: FontWeight
                                                                                      .bold),
                                                                            ),
                                                                            TextSpan(
                                                                              text: AppLocalizations
                                                                                  .of(
                                                                                  context)
                                                                                  .translate(
                                                                                  'withAnAmountOf'),
                                                                              style: GoogleFonts.lato(
                                                                                fontSize: 18,
                                                                              ),
                                                                            ),
                                                                            TextSpan(
                                                                              text: '${bdgList[index -
                                                                                  1]
                                                                                  .amount} ',
                                                                              style: GoogleFonts.lato(
                                                                                  color: Color(
                                                                                      0xFF0957FF),
                                                                                  fontSize: 18,
                                                                                  fontWeight: FontWeight
                                                                                      .bold),
                                                                            ),
                                                                            TextSpan(
                                                                              text: AppLocalizations
                                                                                  .of(
                                                                                  context)
                                                                                  .translate(
                                                                                  'willBe'),
                                                                              style: GoogleFonts.lato(
                                                                                fontSize: 18,
                                                                              ),
                                                                            ),
                                                                            TextSpan(
                                                                              text: '${bdgList[index -
                                                                                  1]
                                                                                  .active ==
                                                                                  1
                                                                                  ? AppLocalizations
                                                                                  .of(
                                                                                  context)
                                                                                  .translate(
                                                                                  'deleted')
                                                                                  : AppLocalizations
                                                                                  .of(
                                                                                  context)
                                                                                  .translate(
                                                                                  'restored')}',
                                                                              style: GoogleFonts.lato(
                                                                                  color: bdgList[index -
                                                                                      1]
                                                                                      .active ==
                                                                                      1
                                                                                      ? Colors
                                                                                      .red
                                                                                      : Colors
                                                                                      .green,
                                                                                  fontSize: 18,
                                                                                  fontWeight: FontWeight
                                                                                      .bold),
                                                                            ),
                                                                          ]),
                                                                    ),
                                                                    actions: <
                                                                        Widget>[
                                                                      new FlatButton(
                                                                        child:
                                                                        new Text(
                                                                          AppLocalizations
                                                                              .of(
                                                                              context)
                                                                              .translate(
                                                                              'cancel'), style: GoogleFonts.lato()
                                                                        ),
                                                                        onPressed: () =>
                                                                            Navigator
                                                                                .of(
                                                                                context)
                                                                                .pop(),
                                                                      ),
                                                                      new Container(
                                                                        margin: EdgeInsets
                                                                            .only(
                                                                            left: 2,
                                                                            right: 2,
                                                                            bottom: 10),
                                                                        child: ConfirmationSlider(
                                                                          text: AppLocalizations
                                                                              .of(
                                                                              context)
                                                                              .translate(
                                                                              'slideToConfirm'),
                                                                          foregroundColor: Color(
                                                                              0xff0957FF),
                                                                          onConfirmation: () {
                                                                            bdgObjectToDelete
                                                                                .id =
                                                                                bdgList[index -
                                                                                    1]
                                                                                    .id;

                                                                            sendBackend(
                                                                                'bdglistdelete',
                                                                                false);
                                                                            Navigator
                                                                                .of(
                                                                                context)
                                                                                .pop();
                                                                          },
                                                                        ),
                                                                      ),
                                                                      /*new FlatButton(
                                                                      child:
                                                                      new Text(
                                                                        AppLocalizations
                                                                            .of(
                                                                            context)
                                                                            .translate(
                                                                            'confirm'),
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        bdgObjectToDelete
                                                                            .id =
                                                                            bdgList[index -
                                                                                1]
                                                                                .id;

                                                                        sendBackend(
                                                                            'bdglistdelete',
                                                                            false);
                                                                        Navigator
                                                                            .of(
                                                                            context)
                                                                            .pop();
                                                                      },
                                                                    )*/
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          )
                                                        ]),
                                                  ])),
                                        ))
                                        : Container()),
                                    currentlyLoading && index ==
                                        2 // to show a bit more in the middle and only one circle, instead of one per item in the listview,
                                        ?
                                    _showLoadWidget()
                                        : Container(),
                                  ],);
                                })
                        ),
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
                        _refreshController.refreshCompleted();
                      },
                      child: LayoutBuilder(
                        builder: (context, constraint) {
                          return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minHeight: constraint.maxHeight),
                                child: IntrinsicHeight(
                                    child: Stack(children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .center,
                                        children: <Widget>[
                                          Column(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceEvenly,
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .center,
                                              children: <Widget>[
                                                Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                    children: <Widget>[
                                                      ButtonTheme(
                                                        //minWidth: 150.0,
                                                        height: 60.0,
                                                        child: FlatButton(
                                                          onPressed: () =>
                                                              _showDatePicker(
                                                                  'visualizer',
                                                                  dateTimeVisualizer),
                                                          shape: new RoundedRectangleBorder(
                                                            borderRadius:
                                                            new BorderRadius
                                                                .circular(40.0),
                                                          ),
                                                          color: Color(
                                                              0xff003680),
                                                          padding: EdgeInsets
                                                              .all(
                                                              10.0),
                                                          child: Row(
                                                            // Replace with a Row for horizontal icon + text
                                                            children: <Widget>[
                                                              Text(
                                                                  " ${dateTimeVisualizer
                                                                      .year
                                                                      .toString()}-${dateTimeVisualizer
                                                                      .month
                                                                      .toString()
                                                                      .padLeft(
                                                                      2, '0')}",
                                                                  style: GoogleFonts.lato(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize: 17)),
                                                              SizedBox(
                                                                  width: 10),
                                                              Icon(
                                                                Icons
                                                                    .calendar_today,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ]),
                                                Container(
                                                  //color: Colors.blue[600],
                                                  alignment: Alignment.center,
                                                  width: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width * .95,
                                                  //child: Text('Submit'),
                                                  child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                      children: <Widget>[
                                                        Switch(
                                                          value: showFullYear,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              currentlyLoading =
                                                              true;

                                                              showAllTime =
                                                              false;
                                                              showFullYear =
                                                                  value;
                                                              loadAmount(true);
                                                            });
                                                          },
                                                          activeTrackColor: Color(
                                                              0xffEEEEEE),
                                                          activeColor: Color(
                                                              0xff0957FF),
                                                        ),
                                                        Container(
                                                          //color: Colors.blue[600],
                                                            alignment: Alignment
                                                                .center,
                                                            width: MediaQuery
                                                                .of(context)
                                                                .size
                                                                .width * .30,
                                                            //child: Text('Submit'),
                                                            child: FittedBox(
                                                                child:
                                                                Text(
                                                                  AppLocalizations
                                                                      .of(
                                                                      context)
                                                                      .translate(
                                                                      'FullYearSwitch'),
                                                                  overflow: TextOverflow
                                                                      .ellipsis,
                                                                  style: GoogleFonts.lato(
                                                                      fontSize: 25),
                                                                ))),
                                                        Switch(
                                                          value: showAllTime,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              // To show load animation from #170
                                                              currentlyLoading =
                                                              true;

                                                              showFullYear =
                                                              false;
                                                              showAllTime =
                                                                  value;
                                                              loadAmount(true);
                                                            });
                                                          },
                                                          activeTrackColor: Color(
                                                              0xffEEEEEE),
                                                          activeColor: Color(
                                                              0xff0957FF),
                                                        ),
                                                        Container(
                                                          //color: Colors.blue[600],
                                                            alignment: Alignment
                                                                .center,
                                                            width: MediaQuery
                                                                .of(context)
                                                                .size
                                                                .width * .30,
                                                            //child: Text('Submit'),
                                                            child: FittedBox(
                                                                child: Text(
                                                                  AppLocalizations
                                                                      .of(
                                                                      context)
                                                                      .translate(
                                                                      'AllTimeSwitch'),
                                                                  overflow: TextOverflow
                                                                      .ellipsis,
                                                                  style: GoogleFonts.lato(
                                                                      fontSize: 25),
                                                                ))),
                                                      ]),
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .start,
                                                  children: <Widget>[
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .only(
                                                          left: 0.0,
                                                          top: 0,
                                                          right: 0,
                                                          bottom: 0),
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          AppLocalizations.of(
                                                              context)
                                                              .translate(
                                                              'drilldown') +
                                                              drilldownLevel, style: GoogleFonts.lato()
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width,
                                                  height:
                                                  MediaQuery
                                                      .of(context)
                                                      .size
                                                      .height * .4,
                                                  child: charts.BarChart(
                                                    [
                                                      charts.Series<
                                                          ChartObject,
                                                          String>(
                                                          id: 'CompanySizeVsNumberOfCompanies',
                                                          colorFn: (_, __) =>
                                                              charts.ColorUtil
                                                                  .fromDartColor(
                                                                  Color(
                                                                      0xFF0957FF)),
                                                          domainFn: (
                                                              ChartObject sales,
                                                              _) =>
                                                          sales.accountName,
                                                          measureFn: (
                                                              ChartObject sales,
                                                              _) =>
                                                          sales.amount,
                                                          labelAccessorFn: (
                                                              ChartObject sales,
                                                              _) =>
                                                          '${sales
                                                              .accountName}: ${sales
                                                              .amount
                                                              .toString()}€ ${sales
                                                              .budgetEntry > 0
                                                              ? ' / ' + sales
                                                              .budgetEntry
                                                              .toString() + "€"
                                                              : ''}',
                                                          data: visualizerData),
                                                      charts.Series<
                                                          ChartObject,
                                                          String>(
                                                          id: 'CompanySizeVsNumberOfCompanies',
                                                          domainFn: (
                                                              ChartObject sales,
                                                              _) =>
                                                          sales.accountName,
                                                          measureFn: (
                                                              ChartObject sales,
                                                              _) =>
                                                          sales.amount,
                                                          colorFn: (
                                                              ChartObject segment,
                                                              _) =>
                                                          segment.color,
                                                          labelAccessorFn: (
                                                              ChartObject sales,
                                                              _) =>
                                                          '${sales
                                                              .accountName}: ${sales
                                                              .amount
                                                              .toString()}€',
                                                          data: visualizerTargetData)
                                                        ..setAttribute(
                                                            charts
                                                                .rendererIdKey,
                                                            'customTargetLine'),
                                                    ],
                                                    animate: (!startingUp),
                                                    domainAxis: new charts
                                                        .OrdinalAxisSpec(

                                                        renderSpec:
                                                        new charts
                                                            .NoneRenderSpec(axisLineStyle: new charts.LineStyleSpec(
                                                            color: charts.ColorUtil.fromDartColor(Color(
                                                                0xff2B2B2B))))),
                                                    barGroupingType:
                                                    charts.BarGroupingType
                                                        .grouped,
                                                    customSeriesRenderers: [
                                                      new charts
                                                          .BarTargetLineRendererConfig<
                                                          String>(
                                                        // ID used to link series to this renderer.
                                                          customRendererId: 'customTargetLine',

                                                          groupingType:
                                                          charts.BarGroupingType
                                                              .grouped)
                                                    ],
                                                    selectionModels: [
                                                      new charts
                                                          .SelectionModelConfig(
                                                          type: charts
                                                              .SelectionModelType
                                                              .info,
                                                          changedListener: _onSelectionChanged)
                                                    ],
                                                    vertical: false,
                                                    // Hide domain axis.
                                                    barRendererDecorator:
                                                    new charts
                                                        .BarLabelDecorator<
                                                        String>(),
                                                    // Hide domain axis.
                                                    behaviors: [
                                                      charts.ChartTitle(
                                                          AppLocalizations.of(
                                                              context)
                                                              .translate(
                                                              'visualizerChartTitle')),
                                                      charts.ChartTitle(
                                                          AppLocalizations.of(
                                                              context)
                                                              .translate(
                                                              'visualizerChartYTitle'),
                                                          behaviorPosition:
                                                          charts
                                                              .BehaviorPosition
                                                              .start),
                                                      charts.ChartTitle(
                                                          AppLocalizations.of(
                                                              context)
                                                              .translate(
                                                              'visualizerChartXTitle'),
                                                          behaviorPosition:
                                                          charts
                                                              .BehaviorPosition
                                                              .bottom)
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 0,
                                                            bottom: 0),
                                                        //child: Text('Submit'),
                                                        child: RaisedButton(
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: new BorderRadius
                                                                .circular(50.0),
                                                          ),
                                                          child: Text(
                                                              AppLocalizations
                                                                  .of(
                                                                  context)
                                                                  .translate(
                                                                  'resetButton'), style: GoogleFonts.lato()),
                                                          color: Color(
                                                              0xffEEEEEE),
                                                          // EEEEEE
                                                          onPressed: () {
                                                            setState(() {
                                                              // #170
                                                              currentlyLoading =
                                                              true;

                                                              showAllTime =
                                                              false;
                                                              showFullYear =
                                                              false;
                                                              costTypeObjectVisualizer =
                                                              costTypesList[0];
                                                              dateTimeVisualizer =
                                                                  DateTime
                                                                      .parse(
                                                                      INIT_DATETIME);

                                                              g_parent_account
                                                                  .accountLevel =
                                                              1;
                                                              g_parent_account
                                                                  .id =
                                                              -69;

                                                              drilldownLevel =
                                                              "";

                                                              groupByArgument =
                                                              'Accounts';
                                                              groupByAccount =
                                                              true;
                                                              groupByYear =
                                                              false;
                                                              groupByMonth =
                                                              false;
                                                              groupByDay =
                                                              false;

                                                              groupByVisualizerOptions[0] =
                                                              true;
                                                              groupByVisualizerOptions[1] =
                                                              false;
                                                              groupByVisualizerOptions[2] =
                                                              false;
                                                              groupByVisualizerOptions[3] =
                                                              false;

                                                              loadAmount(true);
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                      Container(
                                                        padding: const EdgeInsets
                                                            .only(
                                                          left: 30.0,
                                                          top: 0,
                                                        ),
                                                        //child: Text('Submit'),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: SearchChoices
                                                              .single(
                                                            value: costTypeObjectVisualizer,
                                                            hint: AppLocalizations
                                                                .of(
                                                                context)
                                                                .translate(
                                                                'select_one_costtype'),
                                                            searchHint: AppLocalizations
                                                                .of(
                                                                context)
                                                                .translate(
                                                                'select_one_costtype'),
                                                            icon: Icon(Icons
                                                                .arrow_downward),
                                                            style: GoogleFonts.lato(
                                                                color: Color(
                                                                    0xff0957FF)),
                                                            underline: Container(
                                                              height: 2,
                                                              width: 2000,
                                                              color: Color(
                                                                  0xff0957FF),
                                                            ),
                                                            onClear: () {
                                                              setState(() {
                                                                // #170
                                                                currentlyLoading =
                                                                true;

                                                                costTypeObjectVisualizer =
                                                                costTypesList[0];

                                                                // #140
                                                                loadAmount(
                                                                    true);
                                                              });
                                                            },
                                                            onChanged: (
                                                                CostType newValue) {
                                                              if (newValue !=
                                                                  null) {
                                                                setState(() {
                                                                  // #170
                                                                  currentlyLoading =
                                                                  true;

                                                                  costTypeObjectVisualizer =
                                                                      newValue;
                                                                  loadAmount(
                                                                      true);
                                                                });
                                                              }
                                                            },
                                                            items: costTypesList
                                                                .map((
                                                                CostType type) {
                                                              return new DropdownMenuItem<
                                                                  CostType>(
                                                                value: type,
                                                                child: new Text(
                                                                  type.name, style: GoogleFonts.lato()
                                                                ),
                                                              );
                                                            }).toList(),
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(icon: Icon(
                                                        Icons.group,
                                                        color: Color(
                                                            0xff0957FF),),
                                                        onPressed: () {
                                                          print("GROUP BY");
                                                          showDialog(
                                                              context: context,
                                                              builder: (
                                                                  BuildContext context) {
                                                                return AlertDialog(
                                                                  content: StatefulBuilder(
                                                                    builder: (
                                                                        BuildContext context,
                                                                        StateSetter setState) {
                                                                      return Column(
                                                                          mainAxisSize: MainAxisSize
                                                                              .min,
                                                                          children: List<
                                                                              Widget>.generate(
                                                                              groupByVisualizerOptions
                                                                                  .length /* + 1 because position zero is the sort switch*/, (
                                                                              int index) {
                                                                            return
                                                                              Row(
                                                                                children: <
                                                                                    Widget>[
                                                                                  Radio<
                                                                                      bool>(
                                                                                    groupValue: true,
                                                                                    value: groupByVisualizerOptions[index],
                                                                                    activeColor: Color(
                                                                                        0xFF0957FF),
                                                                                    onChanged: (
                                                                                        bool newValue) async {
                                                                                      setLoading();


                                                                                      setState(() {
                                                                                        groupByVisualizerOptions[0] =
                                                                                        false;
                                                                                        groupByVisualizerOptions[1] =
                                                                                        false;
                                                                                        groupByVisualizerOptions[2] =
                                                                                        false;
                                                                                        groupByVisualizerOptions[3] =
                                                                                        false;

                                                                                        groupByVisualizerOptions[index] =
                                                                                        true;

                                                                                        switch (index) {
                                                                                          case -1:
                                                                                            {
                                                                                              groupByArgument =
                                                                                              'Accounts';


                                                                                            }
                                                                                            break;

                                                                                          case 0:
                                                                                            {
                                                                                              groupByArgument =
                                                                                              'Accounts';


                                                                                            }
                                                                                            break;

                                                                                          case 1:
                                                                                            {
                                                                                              groupByArgument =
                                                                                              'Year';
                                                                                            }
                                                                                            break;
                                                                                          case 2:
                                                                                            {
                                                                                              groupByArgument =
                                                                                              'Month';
                                                                                            }
                                                                                            break;
                                                                                          case 3:
                                                                                            {
                                                                                              groupByArgument =
                                                                                              'Day';
                                                                                            }
                                                                                            break;
                                                                                        }



                                                                                        loadAmount(
                                                                                            true);
                                                                                      });

                                                                                      final prefs = await SharedPreferences.getInstance();

                                                                                      await prefs.setString('groupBySelection', groupByArgument);
                                                                                      print("SET PREFERENCE groupBySelection to $groupByArgument");


                                                                                      Navigator
                                                                                          .pop(
                                                                                          context);
                                                                                    },
                                                                                  ),
                                                                                  Flexible(
                                                                                      child: Text(
                                                                                        AppLocalizations
                                                                                            .of(
                                                                                            context)
                                                                                            .translate(
                                                                                            '${index}GroupText'),
                                                                                        overflow: TextOverflow
                                                                                            .clip, style: GoogleFonts.lato()
                                                                                      )),
                                                                                ],
                                                                              );
                                                                          }));
                                                                    },
                                                                  ),
                                                                );
                                                              });
                                                        },)
                                                    ]),
                                              ])
                                        ],
                                      ), currentlyLoading
                                          ?
                                      _showLoadWidget()
                                          : Container(),
                                    ],)),
                              ));
                        },
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
                                  Icons.settings,
                                  color: Colors.white,
                                ),
                                Text(
                                  AppLocalizations.of(context)
                                      .translate('TitleGeneralTab'),
                                  style: GoogleFonts.lato(color: Colors.white),
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
                            color: Color(0xff003680),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.library_books,
                                  color: Colors.white,
                                ),
                                Text(
                                  AppLocalizations.of(context)
                                      .translate('TitleAccountsTab'),
                                  style: GoogleFonts.lato(color: Colors.white),
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
                            color: Color(0xff003680),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                    Icons.account_balance, color: Colors.white),
                                Text(
                                  AppLocalizations.of(context)
                                      .translate('TitleCostTypesTab'),
                                  style: GoogleFonts.lato(color: Colors.white),
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
                                  _refreshController.refreshCompleted();
                                },
                                child: LayoutBuilder(
                                  builder: (context, constraint) {
                                    return SingleChildScrollView(
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                              minHeight: constraint.maxHeight),
                                          child: IntrinsicHeight(
                                              child: Stack(
                                                children: <Widget>[Container(
                                                    child: Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                        children: <Widget>[
                                                          Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                              children: <
                                                                  Widget>[
                                                                    Text(
                                                                    AppLocalizations
                                                                        .of(
                                                                        context)
                                                                        .translate(
                                                                        'useCostTypes'),
                                                                    style: GoogleFonts.lato(
                                                                        fontSize: 25)),
                                                                Switch(
                                                                  value:
                                                                  areCostTypesActive,
                                                                  onChanged: (
                                                                      value) {
                                                                    setState(() {
                                                                      areCostTypesActive =
                                                                          value;
                                                                    });
                                                                  },
                                                                  activeTrackColor:
                                                                  Color(
                                                                      0xffEEEEEE),
                                                                  activeColor:
                                                                  Color(
                                                                      0xff0957FF),
                                                                ),
                                                              ]),
                                                          Divider(color: Color(
                                                              0xff2B2B2B)),
                                                          Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                    AppLocalizations
                                                                        .of(
                                                                        context)
                                                                        .translate(
                                                                        'useAccounts'),
                                                                    style: GoogleFonts.lato(
                                                                        fontSize: 25)),
                                                                Switch(
                                                                  value:
                                                                  areAccountsActive,
                                                                  onChanged: (
                                                                      value) {
                                                                    setState(() {
                                                                      areAccountsActive =
                                                                          value;

                                                                      areLevel1AccountsActive =
                                                                          areAccountsActive;
                                                                      areLevel2AccountsActive =
                                                                          areAccountsActive;
                                                                      areLevel3AccountsActive =
                                                                          areAccountsActive;
                                                                    });
                                                                  },
                                                                  activeTrackColor:
                                                                  Color(
                                                                      0xffEEEEEE),
                                                                  activeColor:
                                                                  Color(
                                                                      0xff0957FF),
                                                                ),
                                                              ]),
                                                          Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 0,
                                                                top: 0,
                                                                right: 0,
                                                                bottom: 10),
                                                          ),
                                                          Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                    AppLocalizations
                                                                        .of(
                                                                        context)
                                                                        .translate(
                                                                        'useAccountsLevel1'),
                                                                    style: GoogleFonts.lato(
                                                                        fontSize: 25)),
                                                                Switch(
                                                                  value:
                                                                  areLevel1AccountsActive,
                                                                  onChanged: (
                                                                      value) {
                                                                    setState(() {
                                                                      areLevel1AccountsActive =
                                                                          value;
                                                                      areAccountsActive =
                                                                          value;

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
                                                                  Color(
                                                                      0xffEEEEEE),
                                                                  activeColor:
                                                                  Color(
                                                                      0xff0957FF),
                                                                ),
                                                              ]),
                                                          Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                    AppLocalizations
                                                                        .of(
                                                                        context)
                                                                        .translate(
                                                                        'useAccountsLevel2'),
                                                                    style: GoogleFonts.lato(
                                                                        fontSize: 25)),
                                                                Switch(
                                                                  value:
                                                                  areLevel2AccountsActive,
                                                                  onChanged: (
                                                                      value) {
                                                                    setState(() {
                                                                      areLevel2AccountsActive =
                                                                          value;

                                                                      // Logic that does not allow invalid state of other levels, e.g. level3 active and level1 and level2 inactive
                                                                      if (areLevel2AccountsActive) {
                                                                        areLevel1AccountsActive =
                                                                        true;
                                                                        areAccountsActive =
                                                                        true;
                                                                      } else
                                                                      if (!areLevel2AccountsActive) {
                                                                        areLevel3AccountsActive =
                                                                        false;
                                                                      }
                                                                    });
                                                                  },
                                                                  activeTrackColor:
                                                                  Color(
                                                                      0xffEEEEEE),
                                                                  activeColor:
                                                                  Color(
                                                                      0xff0957FF),
                                                                ),
                                                              ]),
                                                          Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                    AppLocalizations
                                                                        .of(
                                                                        context)
                                                                        .translate(
                                                                        'useAccountsLevel3'),
                                                                    style: GoogleFonts.lato(
                                                                        fontSize: 25)),
                                                                Switch(
                                                                  value:
                                                                  areLevel3AccountsActive,
                                                                  onChanged: (
                                                                      value) {
                                                                    setState(() {
                                                                      areLevel3AccountsActive =
                                                                          value;

                                                                      // Logic that does not allow invalid state of other levels, e.g. level3 active and level1 and level2 inactive
                                                                      if (areLevel3AccountsActive) {
                                                                        areAccountsActive =
                                                                        true;
                                                                        areLevel1AccountsActive =
                                                                        true;
                                                                        areLevel2AccountsActive =
                                                                        true;
                                                                      }
                                                                    });
                                                                  },
                                                                  activeTrackColor:
                                                                  Color(
                                                                      0xffEEEEEE),
                                                                  activeColor:
                                                                  Color(
                                                                      0xff0957FF),
                                                                ),
                                                              ]),
                                                          ButtonBar(
                                                            alignment: MainAxisAlignment
                                                                .center,
                                                            children: <Widget>[
                                                              ButtonTheme(
                                                                height: 50.0,
                                                                child: RaisedButton(
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: new BorderRadius
                                                                        .circular(
                                                                        50.0),
                                                                  ),
                                                                  child: Text(
                                                                    AppLocalizations
                                                                        .of(
                                                                        context)
                                                                        .translate(
                                                                        'DiscardButton'), style: GoogleFonts.lato()
                                                                  ),
                                                                  color:
                                                                  Color(
                                                                      0xffEEEEEE),
                                                                  // EEEEEE
                                                                  onPressed: () async {
                                                                    setState(() {
                                                                      currentlyLoading =
                                                                      true;
                                                                    });

                                                                    await loadPreferences();

                                                                    setState(() {
                                                                      currentlyLoading =
                                                                      false;
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                              ButtonTheme(
                                                                height: 70.0,
                                                                child: RaisedButton(
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: new BorderRadius
                                                                        .circular(
                                                                        50.0),
                                                                  ),
                                                                  child: Text(
                                                                      AppLocalizations
                                                                          .of(
                                                                          context)
                                                                          .translate(
                                                                          'saveButton'),
                                                                      style: GoogleFonts.lato(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize: 20)),
                                                                  color:
                                                                  Color(
                                                                      0xff0957FF),
                                                                  //df7599 - 0957FF
                                                                  onPressed: () {
                                                                    sendBackend(
                                                                        'generaladmin',
                                                                        false);
                                                                  },
                                                                ),
                                                              ),


                                                            ],
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.all(16.0),
                                                            child:  Text("Connecting to $connectionId\n", style: TextStyle(fontSize: 8),),
                                                          ),
                                                        ])), currentlyLoading
                                                    ?
                                                _showLoadWidget()
                                                    : Container(),
                                                ],)),
                                        ));
                                  },
                                )),
                          ),
                        ]),
                        CustomScrollView(slivers: [
                          SliverFillRemaining(
                            child: SmartRefresher(
                                controller: _refreshController,
                                enablePullDown: true,
                                onRefresh: () async {
                                  await handleRefresh(_currentIndex);
                                  _refreshController.refreshCompleted();
                                },
                                child: LayoutBuilder(
                                  builder: (context, constraint) {
                                    return SingleChildScrollView(
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                              minHeight: constraint.maxHeight),
                                          child: IntrinsicHeight(
                                              child: Stack(
                                                children: <Widget>[Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                    children: <Widget>[
                                                      SizedBox(height: 5,),
                                                      Text(
                                                          AppLocalizations.of(
                                                              context)
                                                              .translate(
                                                              'accountAdministrationTitle'),
                                                          style: GoogleFonts.lato(
                                                              fontSize: 25)),
                                                      areLevel1AccountsActive
                                                          ? Container(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            left: 30.0,
                                                            top: 0,
                                                            right: 30,
                                                            bottom: 0),
                                                        alignment: Alignment
                                                            .center,
                                                        child: SearchChoices
                                                            .single(
                                                          value: level1AdminObject,
                                                          hint: AppLocalizations
                                                              .of(
                                                              context)
                                                              .translate(
                                                              'select_one_account'),
                                                          searchHint:
                                                          AppLocalizations
                                                              .of(
                                                              context)
                                                              .translate(
                                                              'select_one_account'),
                                                          icon:
                                                          Icon(Icons
                                                              .arrow_downward),
                                                          iconSize: 24,
                                                          style: GoogleFonts.lato(
                                                              color: Color(
                                                                  0xff0957FF)),
                                                          isExpanded: true,
                                                          underline: Container(
                                                            height: 2,
                                                            width: 5000,
                                                            color: Color(
                                                                0xff0957FF),
                                                          ),
                                                          onClear: () {
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
                                                          onChanged: (
                                                              Account newValue) async {
                                                            if (newValue !=
                                                                null) {
                                                              setState(() {
                                                                level1AdminObject =
                                                                    newValue;
                                                                currentlyLoading =
                                                                true;
                                                              });

                                                              await arrangeAccounts(
                                                                  1, 'admin');

                                                              setState(() {
                                                                currentlyLoading =
                                                                false;
                                                              });
                                                            }
                                                          },
                                                          items: level1AdminAccountsList
                                                              .map((
                                                              Account account) {
                                                            return new DropdownMenuItem<
                                                                Account>(
                                                              value: account,
                                                              child: new Text(
                                                                account.name, style: GoogleFonts.lato()
                                                              ),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      )
                                                          : Container(),
                                                      areLevel1AccountsActive
                                                          ? Container(
                                                          padding: const EdgeInsets
                                                              .only(
                                                              left: 30.0,
                                                              top: 0,
                                                              right: 30,
                                                              bottom: 0),
                                                          //color: Colors.blue[600],
                                                          alignment: Alignment
                                                              .center,
                                                          //child: Text('Submit'),
                                                          child: Stack(
                                                            alignment:
                                                            const Alignment(
                                                                1, 1.0),
                                                            children: <Widget>[
                                                              TextFormField(
                                                                // keyboardType: TextInputType.number, //keyboard with numbers only will appear to the screen
                                                                style: GoogleFonts.lato(
                                                                    height: 2),
                                                                //increases the height of cursor
                                                                // autofocus: true,
                                                                controller:
                                                                newLevel1TextFieldController,
                                                                decoration: InputDecoration(
                                                                    hintText: AppLocalizations
                                                                        .of(
                                                                        context)
                                                                        .translate(
                                                                        'enterNewLevel1AccountNameTextField'),
                                                                    hintStyle: GoogleFonts.lato(
                                                                        height: 1.75,
                                                                        fontSize: 12,
                                                                        color:
                                                                        Color(
                                                                            0xff0957FF)),
                                                                    enabledBorder:
                                                                    new UnderlineInputBorder(
                                                                        borderSide:
                                                                        new BorderSide(
                                                                            width: 2,
                                                                            color: Color(
                                                                                0xff0957FF)))),
                                                              ),
                                                              new FlatButton(
                                                                  onPressed: () {
                                                                    newLevel1TextFieldController
                                                                        .clear();
                                                                  },
                                                                  child:
                                                                  new Icon(Icons
                                                                      .clear))
                                                            ],)
                                                      )
                                                          : Container(),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                      areLevel2AccountsActive
                                                          ? Container(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            left: 30.0,
                                                            top: 0,
                                                            right: 30,
                                                            bottom: 0),
                                                        //color: Colors.blue[600],
                                                        alignment: Alignment
                                                            .center,
                                                        //child: Text('Submit'),
                                                        child: SearchChoices
                                                            .single(
                                                          value: level2AdminObject,
                                                          hint: AppLocalizations
                                                              .of(
                                                              context)
                                                              .translate(
                                                              'select_one_account'),
                                                          searchHint:
                                                          AppLocalizations
                                                              .of(
                                                              context)
                                                              .translate(
                                                              'select_one_account'),
                                                          readOnly:
                                                          level1AdminObject
                                                              .id <=
                                                              0 ||
                                                              level2AdminAccountsList
                                                                  .length <=
                                                                  1 ||
                                                              currentlyLoading,
                                                          icon:
                                                          Icon(Icons
                                                              .arrow_downward),
                                                          iconSize: 24,
                                                          style: GoogleFonts.lato(
                                                              color: level1AdminObject
                                                                  .id <=
                                                                  0
                                                                  ? Colors.grey
                                                                  : Color(
                                                                  0xff0957FF)),
                                                          isExpanded: true,
                                                          underline: Container(
                                                            height: 2,
                                                            width: 5000,
                                                            color: level1AdminObject
                                                                .id <=
                                                                0
                                                                ? Colors.grey
                                                                : Color(
                                                                0xff0957FF),
                                                          ),
                                                          onClear: () {
                                                            setState(() {
                                                              level2AdminObject =
                                                              level2AdminAccountsList[
                                                              0];

                                                              level3AdminObject =
                                                              level3AdminAccountsList[
                                                              0];
                                                            });
                                                          },
                                                          onChanged: (
                                                              Account newValue) async {
                                                            if (newValue !=
                                                                null) {
                                                              setState(() {
                                                                level2AdminObject =
                                                                    newValue;

                                                                currentlyLoading =
                                                                true;
                                                              });

                                                              await arrangeAccounts(
                                                                  2, 'admin');

                                                              setState(() {
                                                                currentlyLoading =
                                                                false;
                                                              });
                                                            }
                                                          },
                                                          items: level2AdminAccountsList
                                                              .map((
                                                              Account account) {
                                                            return new DropdownMenuItem<
                                                                Account>(
                                                              value: account,
                                                              child: new Text(
                                                                account.name, style: GoogleFonts.lato()
                                                              ),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      )
                                                          : Container(),
                                                      areLevel2AccountsActive
                                                          ? Container(
                                                          padding: const EdgeInsets
                                                              .only(
                                                              left: 30.0,
                                                              top: 0,
                                                              right: 30,
                                                              bottom: 0),
                                                          //color: Colors.blue[600],
                                                          alignment: Alignment
                                                              .center,

                                                          //child: Text('Submit'),
                                                          child: Stack(
                                                            alignment:
                                                            const Alignment(
                                                                1, 1.0),
                                                            children: <Widget>[
                                                              TextFormField(
                                                                // keyboardType: TextInputType.number, //keyboard with numbers only will appear to the screen
                                                                enabled: !(level1AdminObject
                                                                    .id < 0 &&
                                                                    newLevel1TextFieldController
                                                                        .text
                                                                        .length <=
                                                                        0),
                                                                readOnly: (level1AdminObject
                                                                    .id < 0 &&
                                                                    newLevel1TextFieldController
                                                                        .text
                                                                        .length <=
                                                                        0),
                                                                style: GoogleFonts.lato(
                                                                    height: 2),
                                                                //increases the height of cursor
                                                                // autofocus: true,
                                                                controller:
                                                                newLevel2TextFieldController,
                                                                decoration: InputDecoration(
                                                                    enabled: !(level1AdminObject
                                                                        .id <
                                                                        0 &&
                                                                        newLevel1TextFieldController
                                                                            .text
                                                                            .length <=
                                                                            0),
                                                                    disabledBorder: UnderlineInputBorder(
                                                                        borderSide:
                                                                        new BorderSide(
                                                                            width: 1,
                                                                            color: Colors
                                                                                .grey)),
                                                                    hintText: AppLocalizations
                                                                        .of(
                                                                        context)
                                                                        .translate(
                                                                        'enterNewLevel2AccountNameTextField'),
                                                                    hintStyle: GoogleFonts.lato(
                                                                        height: 1.75,
                                                                        fontSize: 12,
                                                                        color: (level1AdminObject
                                                                            .id <
                                                                            0 &&
                                                                            newLevel1TextFieldController
                                                                                .text
                                                                                .length <=
                                                                                0)
                                                                            ? Colors
                                                                            .grey
                                                                            : Color(
                                                                            0xff0957FF)
                                                                    ),
                                                                    enabledBorder:
                                                                    new UnderlineInputBorder(
                                                                        borderSide:
                                                                        new BorderSide(
                                                                            width: 2,
                                                                            color: Color(
                                                                                0xff0957FF)))),
                                                              ),
                                                              new FlatButton(
                                                                  onPressed: () {
                                                                    newLevel2TextFieldController
                                                                        .clear();
                                                                  },
                                                                  child:
                                                                  new Icon(Icons
                                                                      .clear))
                                                            ],)
                                                      )
                                                          : Container(),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      areLevel3AccountsActive
                                                          ? Container(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            left: 30.0,
                                                            top: 0,
                                                            right: 30,
                                                            bottom: 0),
                                                        //color: Colors.blue[600],
                                                        alignment: Alignment
                                                            .center,
                                                        //child: Text('Submit'),
                                                        child: SearchChoices
                                                            .single(
                                                          value: level3AdminObject,
                                                          hint: AppLocalizations
                                                              .of(
                                                              context)
                                                              .translate(
                                                              'select_one_account'),
                                                          searchHint:
                                                          AppLocalizations
                                                              .of(
                                                              context)
                                                              .translate(
                                                              'select_one_account'),
                                                          readOnly:
                                                          level2AdminObject
                                                              .id <=
                                                              0 ||
                                                              currentlyLoading,
                                                          icon:
                                                          Icon(Icons
                                                              .arrow_downward),
                                                          iconSize: 24,
                                                          style: GoogleFonts.lato(
                                                              color: level2AdminObject
                                                                  .id <=
                                                                  0
                                                                  ? Colors.grey
                                                                  : Color(
                                                                  0xff0957FF)),
                                                          isExpanded: true,
                                                          underline: Container(
                                                            height: 2,
                                                            width: 5000,
                                                            color: level2AdminObject
                                                                .id <=
                                                                0
                                                                ? Colors.grey
                                                                : Color(
                                                                0xff0957FF),
                                                          ),
                                                          onClear: () {
                                                            setState(() {
                                                              level3AdminObject =
                                                              level3AdminAccountsList[
                                                              0];
                                                            });
                                                          },
                                                          onChanged: (
                                                              Account newValue) {
                                                            if (newValue !=
                                                                null) {
                                                              setState(() {
                                                                level3AdminObject =
                                                                    newValue;
                                                              });
                                                            }
                                                          },
                                                          items: level3AdminAccountsList
                                                              .map((
                                                              Account account) {
                                                            return new DropdownMenuItem<
                                                                Account>(
                                                              value: account,
                                                              child: new Text(
                                                                account.name, style: GoogleFonts.lato()
                                                              ),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      )
                                                          : Container(),
                                                      areLevel3AccountsActive
                                                          ? Container(
                                                          padding: const EdgeInsets
                                                              .only(
                                                              left: 30.0,
                                                              top: 0,
                                                              right: 30,
                                                              bottom: 0),
                                                          //color: Colors.blue[600],
                                                          alignment: Alignment
                                                              .center,
                                                          //child: Text('Submit'),
                                                          child: Stack(
                                                            alignment:
                                                            const Alignment(
                                                                1, 1.0),
                                                            children: <Widget>[
                                                              TextFormField(
                                                                // keyboardType: TextInputType.number, //keyboard with numbers only will appear to the screen
                                                                enabled: !(level2AdminObject
                                                                    .id < 0 &&
                                                                    newLevel2TextFieldController
                                                                        .text
                                                                        .length <=
                                                                        0),
                                                                readOnly: (level2AdminObject
                                                                    .id < 0 &&
                                                                    newLevel2TextFieldController
                                                                        .text
                                                                        .length <=
                                                                        0),
                                                                style: GoogleFonts.lato(
                                                                    height: 2),
                                                                //increases the height of cursor
                                                                // autofocus: true,
                                                                controller:
                                                                newLevel3TextFieldController,
                                                                decoration: InputDecoration(
                                                                    hintText: AppLocalizations
                                                                        .of(
                                                                        context)
                                                                        .translate(
                                                                        'enterNewLevel3AccountNameTextField'),
                                                                    hintStyle: GoogleFonts.lato(
                                                                        height: 1.75,
                                                                        fontSize: 12,
                                                                        color: (level2AdminObject
                                                                            .id <
                                                                            0 &&
                                                                            newLevel2TextFieldController
                                                                                .text
                                                                                .length <=
                                                                                0)
                                                                            ? Colors
                                                                            .grey
                                                                            : Color(
                                                                            0xff0957FF)
                                                                    ),
                                                                    disabledBorder: UnderlineInputBorder(
                                                                        borderSide:
                                                                        new BorderSide(
                                                                            width: 1,
                                                                            color: Colors
                                                                                .grey)),
                                                                    enabledBorder:
                                                                    new UnderlineInputBorder(
                                                                        borderSide:
                                                                        new BorderSide(
                                                                            width: 2,
                                                                            color: Color(
                                                                                0xff0957FF)))),
                                                              ),
                                                              new FlatButton(
                                                                  onPressed: () {
                                                                    actualSearchTextFieldController
                                                                        .clear();
                                                                  },
                                                                  child:
                                                                  new Icon(Icons
                                                                      .clear))
                                                            ],)
                                                      )
                                                          : Container(),
                                                      Container(child:
                                                      ButtonBar(
                                                        alignment: MainAxisAlignment
                                                            .center,
                                                        children: <Widget>[
                                                          ButtonTheme(
                                                            height: 50.0,
                                                            child: RaisedButton(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: new BorderRadius
                                                                    .circular(
                                                                    50.0),
                                                              ),
                                                              child: FittedBox(
                                                                  child: Text(
                                                                    AppLocalizations
                                                                        .of(
                                                                        context)
                                                                        .translate(
                                                                        'DiscardButton'),
                                                                    overflow: TextOverflow
                                                                        .visible, style: GoogleFonts.lato()
                                                                  )),
                                                              color:
                                                              Color(0xffEEEEEE),
                                                              // EEEEEE
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
                                                            height: 50.0,
                                                            child: RaisedButton(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: new BorderRadius
                                                                    .circular(
                                                                    50.0),
                                                              ),
                                                              child: FittedBox(
                                                                  child: Text(
                                                                      AppLocalizations
                                                                          .of(
                                                                          context)
                                                                          .translate(
                                                                          'deleteSelectedButton'),
                                                                      textAlign: TextAlign
                                                                          .center,
                                                                      overflow: TextOverflow
                                                                          .visible,
                                                                      style: GoogleFonts.lato(
                                                                        color: Colors
                                                                            .white,
                                                                      ))),
                                                              color:
                                                              Colors.red,
                                                              //df7599 - 0957FF
                                                              onPressed: () {
                                                                // #139
                                                                if (level1AdminObject
                                                                    .id > 0) {
                                                                  showDialog(
                                                                    context: context,
                                                                    builder: (
                                                                        BuildContext context) {
                                                                      // return object of type Dialog
                                                                      return AlertDialog(
                                                                        title: new Text(
                                                                          AppLocalizations
                                                                              .of(
                                                                              context)
                                                                              .translate(
                                                                              'warning')
                                                                          ,
                                                                          style: GoogleFonts.lato(
                                                                              color: Colors
                                                                                  .orange,
                                                                              fontSize: 25,
                                                                              fontWeight: FontWeight
                                                                                  .bold),),
                                                                        content: new Text(
                                                                          // Show the highest non undefined value, if 3 is undefined 2 if both 1 if 3 is not undefined then 3
                                                                          (level3AdminObject
                                                                              .id >
                                                                              0
                                                                              ? level3AdminObject
                                                                              .name
                                                                              : (level2AdminObject
                                                                              .id >
                                                                              0
                                                                              ? level2AdminObject
                                                                              .name
                                                                              : level1AdminObject
                                                                              .name)) +
                                                                              " " +
                                                                              AppLocalizations
                                                                                  .of(
                                                                                  context)
                                                                                  .translate(
                                                                                  'willBe') +
                                                                              AppLocalizations
                                                                                  .of(
                                                                                  context)
                                                                                  .translate(
                                                                                  'deleted'),
                                                                          style: GoogleFonts.lato(
                                                                              fontWeight: FontWeight
                                                                                  .bold,
                                                                              fontSize: 20),),
                                                                        actions: <
                                                                            Widget>[
                                                                          // usually buttons at the bottom of the dialog
                                                                          new FlatButton(
                                                                            child: new Text(
                                                                                "Close", style: GoogleFonts.lato()),
                                                                            onPressed: () {
                                                                              Navigator
                                                                                  .of(
                                                                                  context)
                                                                                  .pop();
                                                                            },
                                                                          ),
                                                                          new Container(
                                                                            margin: EdgeInsets
                                                                                .only(
                                                                                left: 2,
                                                                                right: 2,
                                                                                bottom: 10),
                                                                            child: ConfirmationSlider(
                                                                              text: AppLocalizations
                                                                                  .of(
                                                                                  context)
                                                                                  .translate(
                                                                                  'slideToConfirm'),
                                                                              foregroundColor: Color(
                                                                                  0xff0957FF),
                                                                              onConfirmation: () {
                                                                                sendBackend(
                                                                                    'newaccountdelete',
                                                                                    false);

                                                                                if
                                                                                (level3AdminObject
                                                                                    .id >
                                                                                    0) {
                                                                                  // If the acount which has just been deleted was selected, unselect it
                                                                                  if (level3ActualObject
                                                                                      .id ==
                                                                                      level3AdminObject
                                                                                          .id) {
                                                                                    level3ActualObject =
                                                                                    level3ActualAccountsList[
                                                                                    0];
                                                                                  }

                                                                                  if (level3BudgetObject
                                                                                      .id ==
                                                                                      level3AdminObject
                                                                                          .id) {
                                                                                    level3BudgetObject =
                                                                                    level3BudgetAccountsList[
                                                                                    0];
                                                                                  }

                                                                                  level3AdminObject =
                                                                                  level3AdminAccountsList[
                                                                                  0];
                                                                                } else
                                                                                if (level2AdminObject
                                                                                    .id >
                                                                                    0) {
                                                                                  // If the acount which has just been deleted was selected, unselect it
                                                                                  if (level2ActualObject
                                                                                      .id ==
                                                                                      level2AdminObject
                                                                                          .id) {
                                                                                    level2ActualObject =
                                                                                    level2ActualAccountsList[
                                                                                    0];
                                                                                  }

                                                                                  if (level2BudgetObject
                                                                                      .id ==
                                                                                      level2AdminObject
                                                                                          .id) {
                                                                                    level2BudgetObject =
                                                                                    level2BudgetAccountsList[
                                                                                    0];
                                                                                  }

                                                                                  level2AdminObject =
                                                                                  level2AdminAccountsList[
                                                                                  0];
                                                                                } else
                                                                                if (level1AdminObject
                                                                                    .id >
                                                                                    0) {
                                                                                  // If the acount which has just been deleted was selected, unselect it
                                                                                  if (level1ActualObject
                                                                                      .id ==
                                                                                      level1AdminObject
                                                                                          .id) {
                                                                                    level1ActualObject =
                                                                                    level1ActualAccountsList[
                                                                                    0];
                                                                                  }

                                                                                  if (level1BudgetObject
                                                                                      .id ==
                                                                                      level1AdminObject
                                                                                          .id) {
                                                                                    level1BudgetObject =
                                                                                    level1BudgetAccountsList[
                                                                                    0];
                                                                                  }

                                                                                  level1AdminObject =
                                                                                  level1AdminAccountsList[
                                                                                  0];
                                                                                };

                                                                                Navigator
                                                                                    .of(
                                                                                    context)
                                                                                    .pop();
                                                                              },
                                                                            ),
                                                                          ),
                                                                          /*new FlatButton(
                                                                          child: new Text(
                                                                              "confirm"),
                                                                          onPressed: () {
                                                                            sendBackend(
                                                                                'newaccountdelete',
                                                                                false);

                                                                            if
                                                                            (level3AdminObject
                                                                                .id >
                                                                                0) {
                                                                              // If the acount which has just been deleted was selected, unselect it
                                                                              if (level3ActualObject
                                                                                  .id ==
                                                                                  level3AdminObject
                                                                                      .id) {
                                                                                level3ActualObject =
                                                                                level3ActualAccountsList[
                                                                                0];
                                                                              }

                                                                              if (level3BudgetObject
                                                                                  .id ==
                                                                                  level3AdminObject
                                                                                      .id) {
                                                                                level3BudgetObject =
                                                                                level3BudgetAccountsList[
                                                                                0];
                                                                              }

                                                                              level3AdminObject =
                                                                              level3AdminAccountsList[
                                                                              0];
                                                                            } else
                                                                            if (level2AdminObject
                                                                                .id >
                                                                                0) {
                                                                              // If the acount which has just been deleted was selected, unselect it
                                                                              if (level2ActualObject
                                                                                  .id ==
                                                                                  level2AdminObject
                                                                                      .id) {
                                                                                level2ActualObject =
                                                                                level2ActualAccountsList[
                                                                                0];
                                                                              }

                                                                              if (level2BudgetObject
                                                                                  .id ==
                                                                                  level2AdminObject
                                                                                      .id) {
                                                                                level2BudgetObject =
                                                                                level2BudgetAccountsList[
                                                                                0];
                                                                              }

                                                                              level2AdminObject =
                                                                              level2AdminAccountsList[
                                                                              0];
                                                                            } else
                                                                            if (level1AdminObject
                                                                                .id >
                                                                                0) {
                                                                              // If the acount which has just been deleted was selected, unselect it
                                                                              if (level1ActualObject
                                                                                  .id ==
                                                                                  level1AdminObject
                                                                                      .id) {
                                                                                level1ActualObject =
                                                                                level1ActualAccountsList[
                                                                                0];
                                                                              }

                                                                              if (level1BudgetObject
                                                                                  .id ==
                                                                                  level1AdminObject
                                                                                      .id) {
                                                                                level1BudgetObject =
                                                                                level1BudgetAccountsList[
                                                                                0];
                                                                              }

                                                                              level1AdminObject =
                                                                              level1AdminAccountsList[
                                                                              0];
                                                                            };
                                                                            Navigator
                                                                                .of(
                                                                                context)
                                                                                .pop();
                                                                          },
                                                                        ),*/
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                }
                                                                else {
                                                                  showDialog(
                                                                    context: context,
                                                                    builder: (
                                                                        BuildContext context) {
                                                                      // return object of type Dialog
                                                                      return AlertDialog(
                                                                        title: new Text(
                                                                          AppLocalizations
                                                                              .of(
                                                                              context)
                                                                              .translate(
                                                                              'warning')
                                                                          ,
                                                                          style: GoogleFonts.lato(
                                                                              color: Colors
                                                                                  .orange,
                                                                              fontSize: 25,
                                                                              fontWeight: FontWeight
                                                                                  .bold),),
                                                                        content: new Text(
                                                                          AppLocalizations
                                                                              .of(
                                                                              context)
                                                                              .translate(
                                                                              'errorDeleteNoAccountSelected'),
                                                                          style: GoogleFonts.lato(
                                                                              fontWeight: FontWeight
                                                                                  .bold,
                                                                              fontSize: 20),),
                                                                        actions: <
                                                                            Widget>[
                                                                          // usually buttons at the bottom of the dialog
                                                                          new FlatButton(
                                                                            child: new Text(
                                                                                "Close", style: GoogleFonts.lato()),
                                                                            onPressed: () {
                                                                              Navigator
                                                                                  .of(
                                                                                  context)
                                                                                  .pop();
                                                                            },
                                                                          ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                          ButtonTheme(
                                                            height: 70.0,
                                                            child: RaisedButton(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: new BorderRadius
                                                                    .circular(
                                                                    50.0),
                                                              ),
                                                              child: FittedBox(
                                                                  child: Text(
                                                                      AppLocalizations
                                                                          .of(
                                                                          context)
                                                                          .translate(
                                                                          'addButton'),
                                                                      overflow: TextOverflow
                                                                          .visible,
                                                                      style: GoogleFonts.lato(
                                                                        color: Colors
                                                                            .white,
                                                                      ))),
                                                              color: Color(
                                                                  0xff0957FF),
                                                              //df7599 - 0957FF
                                                              onPressed: () {
                                                                if (newLevel1TextFieldController
                                                                    .text
                                                                    .length >
                                                                    0 ||
                                                                    newLevel2TextFieldController
                                                                        .text
                                                                        .length >
                                                                        0 ||
                                                                    newLevel3TextFieldController
                                                                        .text
                                                                        .length >
                                                                        0) {
                                                                  showDialog(
                                                                      context: context,
                                                                      builder: (
                                                                          context) {
                                                                        return AlertDialog(
                                                                          title: Center(
                                                                            child: RichText(
                                                                              text: TextSpan(
                                                                                  text: '${newLevel1TextFieldController
                                                                                      .text
                                                                                      .length >
                                                                                      0
                                                                                      ? (newLevel1TextFieldController
                                                                                      .text)
                                                                                      : ""}'
                                                                                      '${newLevel2TextFieldController
                                                                                      .text
                                                                                      .length >
                                                                                      0
                                                                                      ? (
                                                                                      (newLevel1TextFieldController
                                                                                          .text
                                                                                          .length >
                                                                                          0
                                                                                          ? " > "
                                                                                          : "") +
                                                                                          newLevel2TextFieldController
                                                                                              .text)
                                                                                      : ""}'
                                                                                      '${newLevel3TextFieldController
                                                                                      .text
                                                                                      .length >
                                                                                      0
                                                                                      ? (
                                                                                      (newLevel2TextFieldController
                                                                                          .text
                                                                                          .length >
                                                                                          0
                                                                                          ? " > "
                                                                                          : "") +
                                                                                          newLevel3TextFieldController
                                                                                              .text)
                                                                                      : ""}',
                                                                                  style: GoogleFonts.lato(
                                                                                      color: Color(
                                                                                          0xff73D700),
                                                                                      fontSize: 18,
                                                                                      fontWeight: FontWeight
                                                                                          .bold),
                                                                                  children: <
                                                                                      TextSpan>[
                                                                                    TextSpan(
                                                                                        text: ' ${AppLocalizations
                                                                                            .of(
                                                                                            context)
                                                                                            .translate(
                                                                                            'willBeAddedAsAChildOf')} ',
                                                                                        style:
                                                                                        GoogleFonts.lato(
                                                                                            color: Color(
                                                                                                0xff2B2B2B),
                                                                                            fontSize: 18),
                                                                                        children: <
                                                                                            TextSpan>[
                                                                                          TextSpan(
                                                                                            text: ([
                                                                                              0,
                                                                                              level1AdminObject
                                                                                                  .id,
                                                                                            ]
                                                                                                .reduce(
                                                                                                max)
                                                                                                +
                                                                                                [
                                                                                                  0,
                                                                                                  level2AdminObject
                                                                                                      .id,
                                                                                                ]
                                                                                                    .reduce(
                                                                                                    max)
                                                                                                +
                                                                                                [
                                                                                                  0,
                                                                                                  level3AdminObject
                                                                                                      .id,
                                                                                                ]
                                                                                                    .reduce(
                                                                                                    max)
                                                                                            ) >
                                                                                                0
                                                                                                ? ('${newLevel1TextFieldController
                                                                                                .text
                                                                                                .length >
                                                                                                0
                                                                                                ? ''
                                                                                                : (level1AdminObject
                                                                                                .id >
                                                                                                0
                                                                                                ? level1AdminObject
                                                                                                .name
                                                                                                : '')} ${newLevel2TextFieldController
                                                                                                .text
                                                                                                .length >
                                                                                                0
                                                                                                ? ''
                                                                                                : (level2AdminObject
                                                                                                .id >
                                                                                                0
                                                                                                ? " > " +
                                                                                                level2AdminObject
                                                                                                    .name
                                                                                                : '')}')
                                                                                                : "${AppLocalizations
                                                                                                .of(
                                                                                                context)
                                                                                                .translate(
                                                                                                'noAccount')} - ${[
                                                                                              0,
                                                                                              level1AdminObject
                                                                                                  .id,
                                                                                            ]
                                                                                                .reduce(
                                                                                                max)
                                                                                                +
                                                                                                [
                                                                                                  0,
                                                                                                  level2AdminObject
                                                                                                      .id,
                                                                                                ]
                                                                                                    .reduce(
                                                                                                    max)
                                                                                                +
                                                                                                [
                                                                                                  0,
                                                                                                  level3AdminObject
                                                                                                      .id,
                                                                                                ]
                                                                                                    .reduce(
                                                                                                    max)}",
                                                                                            style: GoogleFonts.lato(
                                                                                                color: Color(
                                                                                                    0xff0957FF),
                                                                                                fontSize: 18,
                                                                                                fontWeight: FontWeight
                                                                                                    .bold),),
                                                                                        ])
                                                                                  ]),
                                                                            ),
                                                                          ),
                                                                          actions: <
                                                                              Widget>[
                                                                            new FlatButton(
                                                                              child: new Text(
                                                                                  AppLocalizations
                                                                                      .of(
                                                                                      context)
                                                                                      .translate(
                                                                                      'cancel'), style: GoogleFonts.lato()),
                                                                              onPressed: () {
                                                                                Navigator
                                                                                    .of(
                                                                                    context)
                                                                                    .pop();
                                                                              },
                                                                            ),
                                                                            new Container(
                                                                              margin: EdgeInsets
                                                                                  .only(
                                                                                  left: 2,
                                                                                  right: 2,
                                                                                  bottom: 10),
                                                                              child: ConfirmationSlider(
                                                                                text: AppLocalizations
                                                                                    .of(
                                                                                    context)
                                                                                    .translate(
                                                                                    'slideToConfirm'),
                                                                                foregroundColor: Color(
                                                                                    0xff0957FF),
                                                                                onConfirmation: () {
                                                                                  commentInput(
                                                                                      context,
                                                                                      'account',
                                                                                      newLevel1TextFieldController,
                                                                                      newLevel2TextFieldController,
                                                                                      newLevel3TextFieldController);

                                                                                  //Navigator.pop(context);
                                                                                },
                                                                              ),
                                                                            ),
                                                                            /*new FlatButton(
                                                                            child: new Text(
                                                                                AppLocalizations
                                                                                    .of(
                                                                                    context)
                                                                                    .translate(
                                                                                    'addButton')),
                                                                            onPressed: () {
                                                                              commentInput(
                                                                                  context,
                                                                                  'account',
                                                                                  newLevel1TextFieldController,
                                                                                  newLevel2TextFieldController,
                                                                                  newLevel3TextFieldController);

                                                                              //Navigator.pop(context);


                                                                            },
                                                                          ),*/
                                                                          ],
                                                                        );
                                                                      });
                                                                }
                                                                else {
                                                                  showDialog(
                                                                    context: context,
                                                                    builder: (
                                                                        BuildContext context) {
                                                                      // return object of type Dialog
                                                                      return AlertDialog(
                                                                        title: new Text(
                                                                          AppLocalizations
                                                                              .of(
                                                                              context)
                                                                              .translate(
                                                                              'warning')
                                                                          ,
                                                                          style: GoogleFonts.lato(
                                                                              color: Colors
                                                                                  .orange,
                                                                              fontSize: 25,
                                                                              fontWeight: FontWeight
                                                                                  .bold),),
                                                                        content: new Text(
                                                                          AppLocalizations
                                                                              .of(
                                                                              context)
                                                                              .translate(
                                                                              'errorAddNoAccountEntered'),
                                                                          style: GoogleFonts.lato(
                                                                              fontWeight: FontWeight
                                                                                  .bold,
                                                                              fontSize: 20),),
                                                                        actions: <
                                                                            Widget>[
                                                                          // usually buttons at the bottom of the dialog
                                                                          new FlatButton(
                                                                            child: new Text(
                                                                                "Close", style: GoogleFonts.lato()),
                                                                            onPressed: () {
                                                                              Navigator
                                                                                  .of(
                                                                                  context)
                                                                                  .pop();
                                                                            },
                                                                          ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                                    ]), currentlyLoading
                                                    ?
                                                _showLoadWidget()
                                                    : Container(),
                                                ],)),
                                        ));
                                  },
                                )),
                          )
                        ]),
                        CustomScrollView(slivers: [
                          SliverFillRemaining(
                            child: SmartRefresher(
                                controller: _refreshController,
                                enablePullDown: true,
                                onRefresh: () async {
                                  await handleRefresh(_currentIndex);
                                  _refreshController.refreshCompleted();
                                },
                                child: LayoutBuilder(
                                  builder: (context, constraint) {
                                    return SingleChildScrollView(
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                              minHeight: constraint.maxHeight),
                                          child: IntrinsicHeight(
                                              child: Stack(children: <Widget>[
                                                Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                    children: <Widget>[
                                                      Text(
                                                          AppLocalizations.of(
                                                              context)
                                                              .translate(
                                                              'costTypesAdministrationTitle'),
                                                          style: GoogleFonts.lato(
                                                              fontSize: 25)),
                                                      Container(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            left: 30.0,
                                                            top: 0,
                                                            right: 30,
                                                            bottom: 0),
                                                        //color: Colors.blue[600],
                                                        alignment: Alignment
                                                            .center,
                                                        //child: Text('Submit'),
                                                        child: SearchChoices
                                                            .single(
                                                          value: costTypeObjectAdmin,
                                                          hint: AppLocalizations
                                                              .of(
                                                              context)
                                                              .translate(
                                                              'select_one_costtype'),
                                                          searchHint: AppLocalizations
                                                              .of(
                                                              context)
                                                              .translate(
                                                              'select_one_costtype'),
                                                          icon: Icon(Icons
                                                              .arrow_downward),
                                                          iconSize: 24,
                                                          style: GoogleFonts.lato(
                                                              color: Color(
                                                                  0xff0957FF)),
                                                          isExpanded: true,
                                                          underline: Container(
                                                            height: 2,
                                                            width: 5000,
                                                            color: Color(
                                                                0xff0957FF),
                                                          ),
                                                          onClear: () {
                                                            setState(() {
                                                              costTypeObjectAdmin =
                                                              costTypesList[0];
                                                            });
                                                          },
                                                          onChanged: (
                                                              CostType newValue) {
                                                            if (newValue !=
                                                                null) {
                                                              setState(() {
                                                                costTypeObjectAdmin =
                                                                    newValue;
                                                              });
                                                            }
                                                          },
                                                          items: costTypesList
                                                              .map((
                                                              CostType costType) {
                                                            return new DropdownMenuItem<
                                                                CostType>(
                                                              value: costType,
                                                              child: new Text(
                                                                costType.name, style: GoogleFonts.lato()
                                                              ),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            left: 30.0,
                                                            top: 0,
                                                            right: 30,
                                                            bottom: 40),
                                                        //color: Colors.blue[600],
                                                        alignment: Alignment
                                                            .center,
                                                        //child: Text('Submit'),
                                                        child: Stack(alignment:
                                                        const Alignment(1, 1.0),
                                                          children: <Widget>[
                                                            TextFormField(
                                                              // keyboardType: TextInputType.number, //keyboard with numbers only will appear to the screen
                                                              style: GoogleFonts.lato(
                                                                  height: 2),
                                                              controller:
                                                              newCostTypeTextFieldController,
                                                              decoration: InputDecoration(
                                                                  hintText: AppLocalizations
                                                                      .of(
                                                                      context)
                                                                      .translate(
                                                                      'enterNewCostTypeNameTextField'),
                                                                  hintStyle: GoogleFonts.lato(
                                                                      height: 1.75,
                                                                      fontSize: 12,
                                                                      color: Color(
                                                                          0xff0957FF)),

                                                                  enabledBorder:
                                                                  new UnderlineInputBorder(
                                                                      borderSide: new BorderSide(
                                                                          color: Color(
                                                                              0xff0957FF)))),
                                                            ),
                                                            new FlatButton(
                                                                onPressed: () {
                                                                  actualSearchTextFieldController
                                                                      .clear();
                                                                },
                                                                child:
                                                                new Icon(Icons
                                                                    .clear))
                                                          ],),
                                                      ),
                                                      ButtonBar(
                                                        alignment: MainAxisAlignment
                                                            .center,
                                                        children: <Widget>[
                                                          ButtonTheme(
                                                            height: 50.0,
                                                            child: RaisedButton(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: new BorderRadius
                                                                    .circular(
                                                                    50.0),
                                                              ),
                                                              child: Text(
                                                                AppLocalizations
                                                                    .of(context)
                                                                    .translate(
                                                                    'DiscardButton'),
                                                                overflow: TextOverflow
                                                                    .visible, style: GoogleFonts.lato()
                                                              ),
                                                              color:
                                                              Color(0xffEEEEEE),
                                                              // EEEEEE
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
                                                            height: 50.0,
                                                            child: RaisedButton(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: new BorderRadius
                                                                    .circular(
                                                                    50.0),
                                                              ),
                                                              child: Text(
                                                                  AppLocalizations
                                                                      .of(
                                                                      context)
                                                                      .translate(
                                                                      'deleteSelectedButton'),
                                                                  textAlign: TextAlign
                                                                      .center,
                                                                  overflow: TextOverflow
                                                                      .visible,
                                                                  style: GoogleFonts.lato(
                                                                    color: Colors
                                                                        .white,
                                                                  )),
                                                              color:
                                                              Colors.red,
                                                              //df7599 - 0957FF
                                                              onPressed: () {
                                                                if (costTypeObjectAdmin
                                                                    .id > 0) {
                                                                  showDialog(
                                                                    context: context,
                                                                    builder: (
                                                                        BuildContext context) {
                                                                      // return object of type Dialog
                                                                      return AlertDialog(
                                                                        title: new Text(
                                                                          AppLocalizations
                                                                              .of(
                                                                              context)
                                                                              .translate(
                                                                              'warning')
                                                                          ,
                                                                          style: GoogleFonts.lato(
                                                                              color: Colors
                                                                                  .orange,
                                                                              fontSize: 25,
                                                                              fontWeight: FontWeight
                                                                                  .bold),),
                                                                        content: new Text(
                                                                          // Show the highest non undefined value, if 3 is undefined 2 if both 1 if 3 is not undefined then 3
                                                                          (costTypeObjectAdmin
                                                                              .name) +
                                                                              " " +
                                                                              AppLocalizations
                                                                                  .of(
                                                                                  context)
                                                                                  .translate(
                                                                                  'willBe') +
                                                                              AppLocalizations
                                                                                  .of(
                                                                                  context)
                                                                                  .translate(
                                                                                  'deleted'),
                                                                          style: GoogleFonts.lato(
                                                                              fontWeight: FontWeight
                                                                                  .bold,
                                                                              fontSize: 20),),
                                                                        actions: <
                                                                            Widget>[
                                                                          // usually buttons at the bottom of the dialog
                                                                          new FlatButton(
                                                                            child: new Text(
                                                                                "Close", style: GoogleFonts.lato()),
                                                                            onPressed: () {
                                                                              Navigator
                                                                                  .of(
                                                                                  context)
                                                                                  .pop();
                                                                            },
                                                                          ),
                                                                          new Container(
                                                                            margin: EdgeInsets
                                                                                .only(
                                                                                left: 2,
                                                                                right: 2,
                                                                                bottom: 10),
                                                                            child: ConfirmationSlider(
                                                                              text: AppLocalizations
                                                                                  .of(
                                                                                  context)
                                                                                  .translate(
                                                                                  'slideToConfirm'),
                                                                              foregroundColor: Color(
                                                                                  0xff0957FF),
                                                                              onConfirmation: () {
                                                                                sendBackend(
                                                                                    'newcosttypedelete',
                                                                                    false);

                                                                                // the here selected value was deleted and therefore is no more available, so set it to the first default value to not receive an error
                                                                                costTypeObjectAdmin
                                                                                =
                                                                                costTypesList[0];

                                                                                Navigator
                                                                                    .of(
                                                                                    context)
                                                                                    .pop();
                                                                              },
                                                                            ),
                                                                          ),
                                                                          /*new FlatButton(
                                                                          child: new Text(
                                                                              "confirm"),
                                                                          onPressed: () {
                                                                            sendBackend(
                                                                                'newcosttypedelete',
                                                                                false);

                                                                            // the here selected value was deleted and therefore is no more available, so set it to the first default value to not receive an error
                                                                            costTypeObjectAdmin
                                                                            =
                                                                            costTypesList[0];

                                                                            Navigator
                                                                                .of(
                                                                                context)
                                                                                .pop();
                                                                          },
                                                                        ),*/
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                }
                                                                else {
                                                                  showDialog(
                                                                    context: context,
                                                                    builder: (
                                                                        BuildContext context) {
                                                                      // return object of type Dialog
                                                                      return AlertDialog(
                                                                        title: new Text(
                                                                          AppLocalizations
                                                                              .of(
                                                                              context)
                                                                              .translate(
                                                                              'warning')
                                                                          ,
                                                                          style: GoogleFonts.lato(
                                                                              color: Colors
                                                                                  .orange,
                                                                              fontSize: 25,
                                                                              fontWeight: FontWeight
                                                                                  .bold),),
                                                                        content: new Text(
                                                                          AppLocalizations
                                                                              .of(
                                                                              context)
                                                                              .translate(
                                                                              'errorDeleteNoCostTypeSelected'),
                                                                          style: GoogleFonts.lato(
                                                                              fontWeight: FontWeight
                                                                                  .bold,
                                                                              fontSize: 20),),
                                                                        actions: <
                                                                            Widget>[
                                                                          // usually buttons at the bottom of the dialog
                                                                          new FlatButton(
                                                                            child: new Text(
                                                                                "Close", style: GoogleFonts.lato()),
                                                                            onPressed: () {
                                                                              Navigator
                                                                                  .of(
                                                                                  context)
                                                                                  .pop();
                                                                            },
                                                                          ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                          ButtonTheme(

                                                            height: 70.0,
                                                            child: RaisedButton(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: new BorderRadius
                                                                    .circular(
                                                                    50.0),
                                                              ),
                                                              child: Text(
                                                                  AppLocalizations
                                                                      .of(
                                                                      context)
                                                                      .translate(
                                                                      'addButton'),
                                                                  overflow: TextOverflow
                                                                      .visible,
                                                                  style: GoogleFonts.lato(
                                                                    color: Colors
                                                                        .white,
                                                                  )),
                                                              color: Color(
                                                                  0xff0957FF),
                                                              //df7599 - 0957FF
                                                              onPressed: () {
                                                                if (newCostTypeTextFieldController
                                                                    .text
                                                                    .length >
                                                                    0) {
                                                                  commentInput(
                                                                      context,
                                                                      'costtype',
                                                                      newCostTypeTextFieldController,
                                                                      null,
                                                                      null);
                                                                }
                                                                else {
                                                                  showDialog(
                                                                    context: context,
                                                                    builder: (
                                                                        BuildContext context) {
                                                                      // return object of type Dialog
                                                                      return AlertDialog(
                                                                        title: new Text(
                                                                          AppLocalizations
                                                                              .of(
                                                                              context)
                                                                              .translate(
                                                                              'warning')
                                                                          ,
                                                                          style: GoogleFonts.lato(
                                                                              color: Colors
                                                                                  .orange,
                                                                              fontSize: 25,
                                                                              fontWeight: FontWeight
                                                                                  .bold),),
                                                                        content: new Text(
                                                                          AppLocalizations
                                                                              .of(
                                                                              context)
                                                                              .translate(
                                                                              'errorAddNoNewCostTypeEntered'),
                                                                          style: GoogleFonts.lato(
                                                                              fontWeight: FontWeight
                                                                                  .bold,
                                                                              fontSize: 20),),
                                                                        actions: <
                                                                            Widget>[
                                                                          // usually buttons at the bottom of the dialog
                                                                          new FlatButton(
                                                                            child: new Text(
                                                                                "Close", style: GoogleFonts.lato()),
                                                                            onPressed: () {
                                                                              Navigator
                                                                                  .of(
                                                                                  context)
                                                                                  .pop();
                                                                            },
                                                                          ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ]), currentlyLoading
                                                    ?
                                                _showLoadWidget()
                                                    : Container(),
                                              ],)),
                                        ));
                                  },
                                )),
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
          _pageController.animateToPage(
              index, duration: Duration(milliseconds: 300),
              curve: Curves.linear);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
              title: Text(
                AppLocalizations.of(context)
                    .translate('homePageTitle')
        , style: GoogleFonts.lato(),
              ),
              icon: Icon(Icons.home),
              activeColor: Color(0xff0957FF)),
          BottomNavyBarItem(
              title: Text(
                AppLocalizations.of(context)
                    .translate('expensesPageTitle'),
    style: GoogleFonts.lato(),
              ),
              icon: Icon(Icons.attach_money),
              activeColor: Colors.orange),
          BottomNavyBarItem(
            title: Text(
              AppLocalizations.of(context)
                  .translate('budgetPageTitle'),style: GoogleFonts.lato(),
            ),
            icon: Icon(Icons.account_balance_wallet),
            activeColor: Colors.deepPurple,
          ),
          BottomNavyBarItem(
            title: Text(
              AppLocalizations.of(context)
                  .translate('visualizerPageTitle'),style: GoogleFonts.lato(),
            ),
            icon: Icon(Icons.bubble_chart),
            activeColor: Colors.red,
          ),
          BottomNavyBarItem(
            title: Text(
              AppLocalizations.of(context)
                  .translate('settingsPageTitle'),style: GoogleFonts.lato(),
            ),
            icon: Icon(Icons.settings),
            activeColor: Colors.green,
          ),
        ],
      ),
    );

    return children;
  }
}
