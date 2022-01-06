import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// A custom widget to wrap a datepicker in a Row element, with a text label.
/// Use the [onDateChanged] callback to get the selected date.
class DatePicker extends StatefulWidget {
  final Function? onDateChanged;
  final DateTime? initialDate;
  final String? label;

  const DatePicker({Key? key, this.onDateChanged, this.initialDate, this.label})
      : super(key: key);

  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  late DateTime _initialDate;

  @override
  void initState() {
    super.initState();
    _initialDate = widget.initialDate ?? DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _initialDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));

    if (picked != null && picked != _initialDate) {
      setState(() {
        _initialDate = picked;
        widget.onDateChanged?.call(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          widget.label ?? 'Date of birth',
          style: const TextStyle(color: Colors.white70, fontSize: 16.0),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: ElevatedButton.icon(
              onPressed: () => _selectDate(context),
              icon: const Icon(Icons.calendar_today),
              label: Text(DateFormat('dd/MM/yyyy').format(_initialDate))),
        ),
      ],
    );
  }
}
