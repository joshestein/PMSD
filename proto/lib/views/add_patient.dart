import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:proto/image_picker.dart';
import 'package:proto/models/child.dart';
import 'package:proto/models/parent.dart';

class AddPatientForm extends StatefulWidget {
  const AddPatientForm({Key? key}) : super(key: key);

  @override
  _AddPatientFormState createState() => _AddPatientFormState();
}

class _AddPatientFormState extends State<AddPatientForm> {
  final _formKey = GlobalKey<FormState>();
  String? _idNo;
  String? _name;
  String? _number;
  String? _email;
  String? _childName;
  String? _childAge;

  List<Widget> _buildParentDetailsForm() {
    return [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          onSaved: (newValue) => _idNo = newValue,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'ID Number *',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an ID number';
            }
            return null;
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          onSaved: (newValue) => _name = newValue,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Parent Name',
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          onSaved: (newValue) => _number = newValue,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Number',
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          onSaved: (newValue) => _email = newValue,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Email',
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildChildDetails() {
    return [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          onSaved: (newValue) => _childName = newValue,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Child Name',
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          onSaved: (newValue) => _childAge = newValue,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Age (in months)',
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Patient Details'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            ExpansionTile(
              title: const Text('Parent Details'),
              controlAffinity: ListTileControlAffinity.leading,
              initiallyExpanded: true,
              children: _buildParentDetailsForm(),
            ),
            ExpansionTile(
              title: const Text('Child Details'),
              controlAffinity: ListTileControlAffinity.leading,
              initiallyExpanded: false,
              children: _buildChildDetails(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            _insertIntoDatabase();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ImagePickerScreen(),
              ),
            );
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }

  Future<void> _insertIntoDatabase() async {
    // TODO: add blocker if existing parent with same ID number
    Parent parent = Parent(
      idCardNo: _idNo!,
      name: _name,
      number: _number,
      email: _email,
    );
    int parentId = await insertParent(parent);

    Child child = Child(
      parentId: parentId,
      name: _childName,
      ageInMonths: int.tryParse(_childAge ?? ''),
    );
    insertChild(child);
  }
}
