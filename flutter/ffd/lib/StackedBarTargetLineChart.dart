/// Bar chart example
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';

class StackedBarTargetLineChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  StackedBarTargetLineChart(this.seriesList, {this.animate});

  /// Creates a stacked [BarChart] with sample data and no transition.
  factory StackedBarTargetLineChart.withSampleData() {
    return new StackedBarTargetLineChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: true,
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
      new OrdinalSales('2014', 60),
      new OrdinalSales('2015', 100),
      new OrdinalSales('2016', 150),
      new OrdinalSales('2017', 140),
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

    ];
  }


}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}

