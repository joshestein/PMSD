import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:proto/date_picker.dart';
import 'package:proto/imaging/image_picker.dart';
import 'package:proto/models/child.dart';
import 'package:proto/models/measurement.dart';

/// Allows for manually entering measurements for a child.
/// [height] allows for optional initial height.
class MeasurementData extends StatefulWidget {
  final Measurement? measurement;
  final Child child;

  const MeasurementData({
    Key? key,
    this.measurement,
    required this.child,
  }) : super(key: key);

  @override
  _MeasurementDataState createState() => _MeasurementDataState();
}

class _MeasurementDataState extends State<MeasurementData> {
  final _formKey = GlobalKey<FormState>();
  late Measurement _measurement;

  @override
  void initState() {
    super.initState();
    _measurement =
        widget.measurement ?? Measurement(childId: widget.child.id!, height: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Measurement Data'),
        actions: [
          if (widget.measurement != null) ...[
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Delete Measurement'),
                    content: const Text(
                        'Are you sure you want to delete this measurement?'),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      ElevatedButton(
                        child: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red[800],
                        ),
                        onPressed: () {
                          deleteMeasurement(_measurement);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ImagePickerScreen(
                                child: widget.child,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ]
        ],
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
                  initialValue: widget.measurement?.height.toStringAsFixed(2),
                  keyboardType: TextInputType.number,
                  onSaved: (value) =>
                      _measurement.height = double.parse(value!),
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
                  initialValue: widget.measurement?.weight?.toStringAsFixed(2),
                  onSaved: (value) =>
                      _measurement.weight = double.tryParse(value!),
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
                  initialDate: widget.measurement?.date,
                  onDateChanged: (newDate) {
                    setState(() {
                      _measurement.date = newDate;
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
            insertMeasurement(_measurement);

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
