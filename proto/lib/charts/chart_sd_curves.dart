import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:proto/charts/chart_utils.dart';
import 'package:proto/charts/length_for_age_data.dart';
import 'package:proto/charts/weight_for_age_data.dart';
import 'package:proto/models/child.dart';

class SDCurves {
  List<LineChartBarData> getSDCurves(
      ChartType type, Child child, BuildContext context) {
    return type == ChartType.lengthForAge
        ? _getLengthSDCurves(child, context)
        : _getWeightSDCurves(child, context);
  }

  _getLengthSDCurves(Child child, BuildContext context) {
    List<FlSpot> SD0 = age.mapIndexed((index, month) {
      return FlSpot(
          month,
          child.sex == 'M'
              ? maleLengthForAgeSD0[index]
              : femaleLengthForAgeSD0[index]);
    }).toList();

    List<FlSpot> SD2 = age.mapIndexed((index, month) {
      return FlSpot(
          month,
          child.sex == 'M'
              ? maleLengthForAgeSD2[index]
              : femaleLengthForAgeSD2[index]);
    }).toList();

    List<FlSpot> SD2_neg = age.mapIndexed((index, month) {
      return FlSpot(
          month,
          child.sex == 'M'
              ? maleLengthForAgeSD2Neg[index]
              : femaleLengthForAgeSD2Neg[index]);
    }).toList();

    List<FlSpot> SD3 = age.mapIndexed((index, month) {
      return FlSpot(
          month,
          child.sex == 'M'
              ? maleLengthForAgeSD3[index]
              : femaleLengthForAgeSD3[index]);
    }).toList();

    List<FlSpot> SD3_neg = age.mapIndexed((index, month) {
      return FlSpot(
          month,
          child.sex == 'M'
              ? maleLengthForAgeSD3Neg[index]
              : femaleLengthForAgeSD3Neg[index]);
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

  _getWeightSDCurves(Child child, BuildContext context) {
    List<FlSpot> SD0 = age.mapIndexed((index, month) {
      return FlSpot(
          month,
          child.sex == 'M'
              ? maleWeightForAgeSD0[index]
              : femaleWeightForAgeSD0[index]);
    }).toList();

    List<FlSpot> SD2 = age.mapIndexed((index, month) {
      return FlSpot(
          month,
          child.sex == 'M'
              ? maleWeightForAgeSD2[index]
              : femaleWeightForAgeSD2[index]);
    }).toList();

    List<FlSpot> SD2_neg = age.mapIndexed((index, month) {
      return FlSpot(
          month,
          child.sex == 'M'
              ? maleWeightForAgeSD2Neg[index]
              : femaleWeightForAgeSD2Neg[index]);
    }).toList();

    List<FlSpot> SD3 = age.mapIndexed((index, month) {
      return FlSpot(
          month,
          child.sex == 'M'
              ? maleWeightForAgeSD3[index]
              : femaleWeightForAgeSD3[index]);
    }).toList();

    List<FlSpot> SD3_neg = age.mapIndexed((index, month) {
      return FlSpot(
          month,
          child.sex == 'M'
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
