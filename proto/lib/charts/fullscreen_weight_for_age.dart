import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:proto/charts/weight_for_age.dart';
import 'package:proto/models/child.dart';

class FullScreenWeightForAge extends StatelessWidget {
  final Child child;

  const FullScreenWeightForAge({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${child.name} - Weight for Age'),
      ),
      body: WeightForAgeChart(
        child: child,
        fullScreen: true,
      ),
    );
  }
}
