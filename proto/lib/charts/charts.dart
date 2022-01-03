import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:proto/charts/chart_data.dart';
import 'package:collection/collection.dart';

class Charts extends StatelessWidget {
  const Charts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(_getMaleData(orientation)),
      );
    });
  }

  _getMaleData(Orientation orientation) {
    bool rotated = Orientation.landscape == orientation;

    return LineChartData(
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: _getMonthTitles(rotated),
        leftTitles: _getHeightTitles(),
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
      ),
      lineBarsData: _getMaleLineData(),
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
        color: Color(0xff75729e),
        fontWeight: FontWeight.bold,
        fontSize: 14,
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
        color: Color(0xff75729e),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  List<LineChartBarData> _getMaleLineData() {
    List<FlSpot> SD0 = age.mapIndexed((index, month) {
      return FlSpot(month, maleLengthForAgeSD0[index]);
    }).toList();

    List<FlSpot> SD2 = age.mapIndexed((index, month) {
      return FlSpot(month, maleLengthForAgeSD2[index]);
    }).toList();

    List<FlSpot> SD2_neg = age.mapIndexed((index, month) {
      return FlSpot(month, maleLengthForAgeSD2Neg[index]);
    }).toList();

    List<FlSpot> SD3 = age.mapIndexed((index, month) {
      return FlSpot(month, maleLengthForAgeSD3[index]);
    }).toList();

    List<FlSpot> SD3_neg = age.mapIndexed((index, month) {
      return FlSpot(month, maleLengthForAgeSD3Neg[index]);
    }).toList();

    return [
      LineChartBarData(
          isCurved: true,
          colors: [Colors.green],
          dotData: FlDotData(show: false),
          barWidth: 2,
          spots: SD0),
      LineChartBarData(
          isCurved: true,
          colors: [Colors.red.shade300],
          dotData: FlDotData(show: false),
          barWidth: 2,
          spots: SD2),
      LineChartBarData(
          isCurved: true,
          colors: [Colors.red.shade300],
          dotData: FlDotData(show: false),
          barWidth: 2,
          spots: SD2_neg),
      LineChartBarData(
          isCurved: true,
          colors: [Colors.red.shade900],
          dotData: FlDotData(show: false),
          barWidth: 2,
          spots: SD3),
      LineChartBarData(
          isCurved: true,
          colors: [Colors.red.shade900],
          dotData: FlDotData(show: false),
          barWidth: 2,
          spots: SD3_neg),
    ];
  }
}
