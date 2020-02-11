/// Bar chart example
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class StackedBarTargetLineChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  StackedBarTargetLineChart(this.seriesList, {this.animate});

  /// Creates a stacked [BarChart] with sample data and no transition.
  factory StackedBarTargetLineChart.withSampleData() {
    return new StackedBarTargetLineChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(seriesList,
        animate: animate,
        barGroupingType: charts.BarGroupingType.stacked,
        customSeriesRenderers: [
          new charts.BarTargetLineRendererConfig<String>(
            // ID used to link series to this renderer.
              customRendererId: 'customTargetLine',
              groupingType: charts.BarGroupingType.stacked)
        ]);
  }

  static Future<List<charts.Series<OrdinalSales, String>>> loadAmount() async {
    int level_type = 1;
    int cost_type = -1;
    int parent_account = -1;
    int year = 2020;
    int month = 2;
    String _type = 'actual';
    var rng = new Random();

    //var amounts = await http.read('http://192.168.0.21:5000/api/ffd/amounts/?level_type=1&cost_type=-1&parent_account=-1&year=2020&month=1&_type=actual');
    var amounts = await http.read(
        'http://192.168.0.21:5000/api/ffd/amounts/?level_type=$level_type&cost_type=$cost_type&parent_account=$parent_account&year=$year&month=$month&_type=$_type');

    var parsedAmounts = json.decode(amounts);

    final desktopSalesData = [new OrdinalSales('2069', 5)];

    for (var amounts in parsedAmounts) {
      desktopSalesData
          .add(new OrdinalSales(amounts['level$level_type'].toString(), amounts['sum']));
    }

    for (var name in desktopSalesData) {
      //print(name.year);
    }

    final tableSalesData = [new OrdinalSales('20420', 5)];

    for (var amounts in parsedAmounts) {
      tableSalesData
          .add(new OrdinalSales(amounts['level${level_type + 1}'].toString(), amounts['sum']));
    }

    final desktopTargetLineData = [
      new OrdinalSales('2014', 25),
      new OrdinalSales('2015', 60),
      new OrdinalSales('2016', 100),
      new OrdinalSales('2017', 110),
    ];

    print("REALLY DONE in correct place");

    return [
      new charts.Series<OrdinalSales, String>(
        id: 'Desktop',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: desktopSalesData,
      ),
      new charts.Series<OrdinalSales, String>(
        id: 'Tablet',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: tableSalesData,
      ),
      new charts.Series<OrdinalSales, String>(
        id: 'Desktop Target Line',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: desktopTargetLineData,
      )
        // Configure our custom bar target renderer for this series.
        ..setAttribute(charts.rendererIdKey, 'customTargetLine'),
    ];
  }

  /// Create series list with multiple series
  static List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final desktopSalesData = [
      new OrdinalSales('2014', 5),
      new OrdinalSales('2015', 25),
      new OrdinalSales('2016', 100),
      new OrdinalSales('2017', 75),
    ];

    final tableSalesData = [
      new OrdinalSales('2014', 25),
      new OrdinalSales('2015', 50),
      new OrdinalSales('2016', 10),
      new OrdinalSales('2017', 20),
    ];

    final mobileSalesData = [
      new OrdinalSales('2014', 10),
      new OrdinalSales('2015', 15),
      new OrdinalSales('2016', 50),
      new OrdinalSales('2017', 45),
    ];

    final desktopTargetLineData = [
      new OrdinalSales('2014', 4),
      new OrdinalSales('2015', 20),
      new OrdinalSales('2016', 80),
      new OrdinalSales('2017', 65),
    ];

    final tableTargetLineData = [
      new OrdinalSales('2014', 30),
      new OrdinalSales('2015', 55),
      new OrdinalSales('2016', 15),
      new OrdinalSales('2017', 25),
    ];

    final mobileTargetLineData = [
      new OrdinalSales('2014', 10),
      new OrdinalSales('2015', 5),
      new OrdinalSales('2016', 45),
      new OrdinalSales('2017', 35),
    ];

    return [
      new charts.Series<OrdinalSales, String>(
        id: 'Desktop',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: desktopSalesData,
      ),
      new charts.Series<OrdinalSales, String>(
        id: 'Tablet',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: tableSalesData,
      ),
      new charts.Series<OrdinalSales, String>(
        id: 'Mobile',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: mobileSalesData,
      ),
      new charts.Series<OrdinalSales, String>(
        id: 'Desktop Target Line',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: desktopTargetLineData,
      )
      // Configure our custom bar target renderer for this series.
        ..setAttribute(charts.rendererIdKey, 'customTargetLine'),
      new charts.Series<OrdinalSales, String>(
        id: 'Tablet Target Line',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: tableTargetLineData,
      )
      // Configure our custom bar target renderer for this series.
        ..setAttribute(charts.rendererIdKey, 'customTargetLine'),
      new charts.Series<OrdinalSales, String>(
        id: 'Mobile Target Line',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: mobileTargetLineData,
      )
      // Configure our custom bar target renderer for this series.
        ..setAttribute(charts.rendererIdKey, 'customTargetLine'),
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
