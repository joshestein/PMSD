import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:proto/date_picker.dart';
import 'package:proto/imaging/image_picker.dart';
import 'package:proto/models/child.dart';
import 'package:proto/models/measurement.dart';

/// Allows for manually entering measurements for a child.
/// [height] allows for optional initial height.
class MeasurementData extends StatefulWidget {
  final double? height;
  final Child child;

  const MeasurementData({
    Key? key,
    this.height,
    required this.child,
  }) : super(key: key);

  @override
  _MeasurementDataState createState() => _MeasurementDataState();
}

class _MeasurementDataState extends State<MeasurementData> {
  final _formKey = GlobalKey<FormState>();
  double? _weight;
  double? _height; // May be modified via form
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Measurement Data'),
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
                  initialValue: widget.height?.toStringAsFixed(2),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _height = double.parse(value!),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a height';
                    }
                    return null;
                  },
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
                const SizedBox(height: 16),
                DatePicker(
                  label: 'Date of measurement',
                  onDateChanged: (newDate) {
                    setState(() {
                      _date = newDate;
                    });
                  },
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            Measurement measurement = Measurement(
              childId: widget.child.id!,
              height: _height!,
              weight: _weight,
              inputDate: _date,
            );
            insertMeasurement(measurement);

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ImagePickerScreen(child: widget.child),
              ),
            );
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
