import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:proto/charts/chart_sd_curves.dart';
import 'package:proto/charts/length_for_age_data.dart';
import 'package:proto/line_fitting.dart';
import 'package:proto/models/child.dart';
import 'package:proto/models/measurement.dart';

enum ChartType {
  lengthForAge,
  weightForAge,
}

class ChartUtils {
  List<FlSpot> getSpots(
      {required ChartType type,
      required List<Measurement> measurements,
      required Child child}) {
    return type == ChartType.lengthForAge
        ? _getLengthForAgeSpots(measurements, child)
        : _getWeightForAgeSpots(measurements, child);
  }

  LineChartBarData getBestFit(
      {required ChartType type,
      required List<Measurement> measurements,
      required Child child,
      required BuildContext context}) {
    List<FlSpot> bestFit = type == ChartType.lengthForAge
        ? _getBestFitLength(measurements, child)
        : _getBestFitWeight(measurements, child);

    return LineChartBarData(
      isCurved: false,
      dashArray: [4, 4],
      colors: [Theme.of(context).colorScheme.onBackground.withOpacity(0.6)],
      dotData: FlDotData(show: false),
      barWidth: 2,
      spots: bestFit,
    );
  }

  SideTitles getMonthTitles(bool rotated) {
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

  List<LineChartBarData> getSDCurves(
      {required ChartType type,
      required Child child,
      required BuildContext context}) {
    SDCurves curves = SDCurves();
    return curves.getSDCurves(type, child, context);
  }

  SideTitles get heightTitles {
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

  SideTitles get weightTitles {
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

  //////////////////////////////////////////////////////////////////////////////
  // Private methods
  //////////////////////////////////////////////////////////////////////////////

  List<FlSpot> _getBestFitLength(List<Measurement> measurements, Child child) {
    List<double> dates = measurements
        .map((m) =>
            (m.date.difference(child.dateOfBirth).inDays ~/ 30).toDouble())
        .toList();
    List<double> heights = measurements.map((m) => m.height).toList();
    LineFitter lineFitter = LineFitter(dates, heights);
    List<double> coefficients = lineFitter.coefficients;

    return age
        .map((month) {
          return FlSpot(
            month,
            coefficients[0] + coefficients[1] * month,
          );
        })
        .where((spot) => spot.y <= 100)
        .toList();
  }

  List<FlSpot> _getBestFitWeight(List<Measurement> measurements, Child child) {
    List<double> dates = measurements
        .where((m) => m.weight != null)
        .map((m) =>
            (m.date.difference(child.dateOfBirth).inDays ~/ 30).toDouble())
        .toList();
    List<double> weights = measurements
        .where((m) => m.weight != null)
        .map((m) => m.weight!)
        .toList();
    LineFitter lineFitter = LineFitter(dates, weights);
    List<double> coefficients = lineFitter.coefficients;

    return age
        .map((month) {
          return FlSpot(
            month,
            coefficients[0] + coefficients[1] * month,
          );
        })
        .where((spot) => spot.y <= 100)
        .toList();
  }

  List<FlSpot> _getLengthForAgeSpots(
      List<Measurement> measurements, Child child) {
    return measurements
        .map((measurement) => FlSpot(
              (measurement.date.difference(child.dateOfBirth).inDays ~/ 30)
                  .toDouble(),
              measurement.height,
            ))
        .toList();
  }

  List<FlSpot> _getWeightForAgeSpots(
      List<Measurement> measurements, Child child) {
    return measurements
        .where((measurement) => measurement.weight != null)
        .map((measurement) => FlSpot(
              (measurement.date.difference(child.dateOfBirth).inDays ~/ 30)
                  .toDouble(),
              measurement.weight!,
            ))
        .toList();
  }
}
