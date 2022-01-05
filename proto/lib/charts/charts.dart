import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:proto/charts/chart_data.dart';
import 'package:collection/collection.dart';
import 'package:proto/models/child.dart';

class Charts extends StatefulWidget {
  final Child child;

  const Charts({Key? key, required this.child}) : super(key: key);

  @override
  _ChartsState createState() => _ChartsState();
}

class _ChartsState extends State<Charts> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              'Length for age (${widget.child.sex == 'M' ? 'male' : 'female'})',
              style: Theme.of(context).primaryTextTheme.headline4,
            ),
          ]),
          const SizedBox(height: 16), // Add gap between heading and chart
          Expanded(
            child: OrientationBuilder(builder: (context, orientation) {
              return LineChart(_getData(context, orientation));
            }),
          ),
        ],
      ),
    );
  }

  _getData(BuildContext context, Orientation orientation) {
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
        leftTitles: _getHeightTitles(),
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
      ),
      lineBarsData: _getLineData(context),
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
      minY: 40,
      maxY: 100,
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

  SideTitles _getHeightTitles() {
    return SideTitles(
      showTitles: true,
      margin: 8,
      interval: 5,
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
              measurement.height,
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
              ? maleLengthForAgeSD0[index]
              : femaleLengthForAgeSD0[index]);
    }).toList();

    List<FlSpot> SD2 = age.mapIndexed((index, month) {
      return FlSpot(
          month,
          widget.child.sex == 'M'
              ? maleLengthForAgeSD2[index]
              : femaleLengthForAgeSD2[index]);
    }).toList();

    List<FlSpot> SD2_neg = age.mapIndexed((index, month) {
      return FlSpot(
          month,
          widget.child.sex == 'M'
              ? maleLengthForAgeSD2Neg[index]
              : femaleLengthForAgeSD2Neg[index]);
    }).toList();

    List<FlSpot> SD3 = age.mapIndexed((index, month) {
      return FlSpot(
          month,
          widget.child.sex == 'M'
              ? maleLengthForAgeSD3[index]
              : femaleLengthForAgeSD3[index]);
    }).toList();

    List<FlSpot> SD3_neg = age.mapIndexed((index, month) {
      return FlSpot(
          month,
          widget.child.sex == 'M'
              ? maleLengthForAgeSD3Neg[index]
              : femaleLengthForAgeSD3Neg[index]);
    }).toList();

    return [
      LineChartBarData(
          isCurved: true,
          colors: [Theme.of(context).colorScheme.primary],
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
