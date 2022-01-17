import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:proto/charts/weight_for_age_data.dart';
import 'package:proto/charts/length_for_age_data.dart';
import 'package:collection/collection.dart';
import 'package:proto/models/child.dart';

class WeightForAgeChart extends StatefulWidget {
  final Child child;
  final bool fullScreen;

  const WeightForAgeChart(
      {Key? key, required this.child, this.fullScreen = false})
      : super(key: key);

  @override
  _WeightForAgeChartState createState() => _WeightForAgeChartState();
}

class _WeightForAgeChartState extends State<WeightForAgeChart> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LineChartBarData>>(
        future: _getLineData(context),
        builder: (context, snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            children = _buildChart(snapshot.data!);
          } else {
            children = [
              const Center(
                child: CircularProgressIndicator(),
              ),
              const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('Drawing...'))),
            ];
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
              ),
            ),
          );
        });
  }

  List<Widget> _buildChart(List<LineChartBarData> data) {
    return [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          'Weight for age (${widget.child.sex == 'M' ? 'male' : 'female'})',
          style: Theme.of(context).primaryTextTheme.headline5,
        ),
      ]),
      const SizedBox(height: 16), // Add gap between heading and chart
      // When the widget is nested, it is nested within a Column/ListView.
      // We want the chart to be fullscreen, thus we wrap with an expanded.
      // But this leads to a conflicting layout, where the ancestor Column/ListView
      // is trying to fill the screen, and at the same time the Expand is trying
      // to maximally fill the current Column. To avoid this, we constrain the
      // non-fullscreen widget to a fixed size.
      widget.fullScreen
          ? Expanded(
              child: OrientationBuilder(builder: (context, orientation) {
                return LineChart(_setupChart(context, orientation, data));
              }),
            )
          : SizedBox(
              height: 200,
              child: OrientationBuilder(builder: (context, orientation) {
                return LineChart(_setupChart(context, orientation, data));
              }),
            ),
    ];
  }

  _setupChart(BuildContext context, Orientation orientation,
      List<LineChartBarData> data) {
    bool rotated = Orientation.landscape == orientation;

    return LineChartData(
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        checkToShowHorizontalLine: (value) => true,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: Colors.white.withOpacity(0.1)),
        drawVerticalLine: true,
        checkToShowVerticalLine: (value) => true,
        getDrawingVerticalLine: (value) =>
            FlLine(color: Colors.white.withOpacity(0.1)),
      ),
      titlesData: FlTitlesData(
        bottomTitles: _getMonthTitles(rotated),
        leftTitles: _getWeightTitles(),
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
      ),
      lineBarsData: data,
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Color(0xFF4e4965), width: 4),
          left: BorderSide(color: Color(0xFF4e4965), width: 4),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      ),
      minX: 0,
      maxX: 24,
      minY: 0,
      maxY: 18,
    );
  }

  SideTitles _getMonthTitles(bool rotated) {
    return SideTitles(
      showTitles: true,
      rotateAngle: rotated ? 0 : 90,
      margin: 10,
      interval: 2,
      reservedSize: 22,
      getTitles: (double value) {
        return value.toString();
      },
      getTextStyles: (context, value) => const TextStyle(
        color: Colors.white70,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  SideTitles _getWeightTitles() {
    return SideTitles(
      showTitles: true,
      margin: 8,
      interval: 2,
      reservedSize: 40,
      getTitles: (double value) {
        return value.toString();
      },
      getTextStyles: (context, value) => const TextStyle(
        color: Colors.white70,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  Future<List<LineChartBarData>> _getLineData(context) async {
    List<FlSpot> existingMeasurements = (await widget.child.measurements)
        .map((measurement) => FlSpot(
              (measurement.date.difference(widget.child.dateOfBirth).inDays ~/
                      30)
                  .toDouble(),
              measurement.weight ?? 0.0,
            ))
        .toList();

    return [
      ..._getSDCurves(),
      LineChartBarData(
          isCurved: true,
          colors: [Theme.of(context).colorScheme.primary],
          dotData: FlDotData(show: true),
          barWidth: 2,
          spots: existingMeasurements),
    ];
  }

  List<LineChartBarData> _getSDCurves() {
    List<FlSpot> SD0 = age.mapIndexed((index, month) {
      return FlSpot(
          month,
          widget.child.sex == 'M'
              ? maleWeightForAgeSD0[index]
              : femaleWeightForAgeSD0[index]);
    }).toList();

    List<FlSpot> SD2 = age.mapIndexed((index, month) {
      return FlSpot(
          month,
          widget.child.sex == 'M'
              ? maleWeightForAgeSD2[index]
              : femaleWeightForAgeSD2[index]);
    }).toList();

    List<FlSpot> SD2_neg = age.mapIndexed((index, month) {
      return FlSpot(
          month,
          widget.child.sex == 'M'
              ? maleWeightForAgeSD2Neg[index]
              : femaleWeightForAgeSD2Neg[index]);
    }).toList();

    List<FlSpot> SD3 = age.mapIndexed((index, month) {
      return FlSpot(
          month,
          widget.child.sex == 'M'
              ? maleWeightForAgeSD3[index]
              : femaleWeightForAgeSD3[index]);
    }).toList();

    List<FlSpot> SD3_neg = age.mapIndexed((index, month) {
      return FlSpot(
          month,
          widget.child.sex == 'M'
              ? maleWeightForAgeSD3Neg[index]
              : femaleWeightForAgeSD3Neg[index]);
    }).toList();

    return [
      LineChartBarData(
          isCurved: true,
          colors: [Theme.of(context).colorScheme.primary.withOpacity(0.5)],
          dotData: FlDotData(show: false),
          barWidth: 2,
          spots: SD0),
      LineChartBarData(
          isCurved: true,
          colors: [Theme.of(context).colorScheme.secondary],
          dotData: FlDotData(show: false),
          barWidth: 2,
          spots: SD2),
      LineChartBarData(
          isCurved: true,
          colors: [Theme.of(context).colorScheme.secondary],
          dotData: FlDotData(show: false),
          barWidth: 2,
          spots: SD2_neg),
      LineChartBarData(
          isCurved: true,
          colors: [Theme.of(context).colorScheme.error],
          dotData: FlDotData(show: false),
          barWidth: 2,
          spots: SD3),
      LineChartBarData(
          isCurved: true,
          colors: [Theme.of(context).colorScheme.error],
          dotData: FlDotData(show: false),
          barWidth: 2,
          spots: SD3_neg),
    ];
  }
}