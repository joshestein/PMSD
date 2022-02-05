import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:proto/charts/chart_utils.dart';
import 'package:proto/measurement/measurement_data.dart';
import 'package:proto/models/child.dart';
import 'package:proto/models/measurement.dart';

class Chart extends StatefulWidget {
  final Child child;
  final bool fullScreen;
  final ChartType type;

  const Chart(
      {Key? key,
      required this.child,
      this.fullScreen = false,
      required this.type})
      : super(key: key);

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  late List<Measurement> _existingMeasurements;
  final ChartUtils _utils = ChartUtils();

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
    String _titleLead =
        widget.type == ChartType.lengthForAge ? 'Length' : 'Weight';
    return [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          '$_titleLead for age (${widget.child.sex == 'M' ? 'male' : 'female'})',
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
      lineTouchData: LineTouchData(
        handleBuiltInTouches: false,
        touchCallback: (FlTouchEvent event, touchResponse) {
          if (event is FlTapUpEvent) {
            int length = touchResponse!.lineBarSpots!.length;
            // There are 7 curves with a fitted line. A fitted line will be drawn
            // when there are more than 3 existing measurements.
            // Otherwise there are 6 curves - median, two standard deviations in
            // either direction and the existing measurements.
            if (_existingMeasurements.length > 3 && length != 7 ||
                _existingMeasurements.length < 3 && length != 6) {
              return;
            } else {
              // The last line is composed of the actual measurements.
              int index = touchResponse.lineBarSpots![length - 1].spotIndex;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MeasurementData(
                    child: widget.child,
                    measurement: _existingMeasurements[index],
                  ),
                ),
              );
            }
          }
        },
      ),
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
        bottomTitles: _utils.getMonthTitles(rotated),
        leftTitles: widget.type == ChartType.lengthForAge
            ? _utils.heightTitles
            : _utils.weightTitles,
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
      minY: widget.type == ChartType.lengthForAge ? 40 : 0,
      maxY: widget.type == ChartType.lengthForAge ? 100 : 18,
    );
  }

  Future<List<LineChartBarData>> _getLineData(context) async {
    List<Measurement> measurements = await widget.child.measurements;
    _existingMeasurements = measurements;

    List<FlSpot> spotMeasurements = _utils.getSpots(
      type: widget.type,
      measurements: measurements,
      child: widget.child,
    );

    return [
      ..._utils.getSDCurves(
          type: widget.type, child: widget.child, context: context),
      if (measurements.length > 3)
        _utils.getBestFit(
            type: widget.type,
            measurements: measurements,
            child: widget.child,
            context: context),
      LineChartBarData(
          isCurved: true,
          colors: [Theme.of(context).colorScheme.primary],
          dotData: FlDotData(show: true),
          barWidth: 2,
          spots: spotMeasurements),
    ];
  }
}
