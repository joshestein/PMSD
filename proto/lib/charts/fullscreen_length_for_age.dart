import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:proto/charts/length_for_age.dart';
import 'package:proto/models/child.dart';

class FullScreenLengthForAge extends StatelessWidget {
  final Child child;

  const FullScreenLengthForAge({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Length for Age'),
      ),
      body: LengthForAgeChart(
        child: child,
        fullScreen: true,
      ),
    );
  }
}
