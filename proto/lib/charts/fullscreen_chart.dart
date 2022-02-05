import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:proto/charts/chart.dart';
import 'package:proto/charts/chart_utils.dart';
import 'package:proto/models/child.dart';

class FullScreenChart extends StatelessWidget {
  final Child child;
  final ChartType type;

  const FullScreenChart({Key? key, required this.child, required this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _typeTitle = type == ChartType.lengthForAge ? 'Length' : 'Weight';
    return Scaffold(
      appBar: AppBar(
        title: Text('${child.name} - $_typeTitle for Age'),
      ),
      body: Chart(
        child: child,
        type: type,
        fullScreen: true,
      ),
    );
  }
}
