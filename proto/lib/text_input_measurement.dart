import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:proto/charts/length_for_age.dart';
import 'package:proto/models/child.dart';
import 'package:proto/models/measurement.dart';

class TextInputMeasurement extends StatefulWidget {
  final double height;
  final Child child;

  const TextInputMeasurement({
    Key? key,
    required this.height,
    required this.child,
  }) : super(key: key);

  @override
  _TextInputMeasurementState createState() => _TextInputMeasurementState();
}

class _TextInputMeasurementState extends State<TextInputMeasurement> {
  final _formKey = GlobalKey<FormState>();
  double? _weight;
  double? _height; // May be modified via form

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Height and Weight Data"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: widget.height.toStringAsFixed(2),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _height = double.parse(value!),
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Height',
                    suffixText: 'cm',
                  ),
                ),
                TextFormField(
                  onSaved: (value) => _weight = double.tryParse(value!),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Weight',
                    suffixText: 'kg',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _formKey.currentState!.save();
          Measurement measurement = Measurement(
            childId: widget.child.id!,
            height: _height!,
            weight: _weight,
          );
          insertMeasurement(measurement);

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LengthForAgeChart(child: widget.child),
            ),
          );
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
