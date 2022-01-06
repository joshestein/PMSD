import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:proto/date_picker.dart';
import 'package:proto/measurement/image_picker.dart';
import 'package:proto/models/child.dart';
import 'package:proto/models/parent.dart';

class AddPatientForm extends StatefulWidget {
  final Parent? parent;

  const AddPatientForm({Key? key, this.parent}) : super(key: key);

  @override
  _AddPatientFormState createState() => _AddPatientFormState();
}

class _AddPatientFormState extends State<AddPatientForm> {
  final _formKey = GlobalKey<FormState>();
  // TODO: make other sections collapse when current section is active
  // bool _parentCollapsed = false;
  // bool _childCollapsed = true;
  String? _idNo;
  String? _name;
  String? _number;
  String? _email;
  String? _childName;
  String _childSex = 'M';
  DateTime _childDOB = DateTime.now();

  List<Widget> _buildParentDetailsForm() {
    return [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          onSaved: (newValue) => _idNo = newValue,
          enabled: widget.parent == null,
          initialValue: widget.parent?.idCardNo,
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
          enabled: widget.parent == null,
          initialValue: widget.parent?.name,
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
          enabled: widget.parent == null,
          initialValue: widget.parent?.number,
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
          enabled: widget.parent == null,
          initialValue: widget.parent?.email,
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please give the child a name!';
            }
            return null;
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Text(
              'Sex',
              style: TextStyle(color: Colors.white70, fontSize: 16.0),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: DropdownButton<String>(
                  value: _childSex,
                  isExpanded: true,
                  items: <String>['M', 'F'].map((String sex) {
                    return DropdownMenuItem<String>(
                      value: sex,
                      child: Text(sex),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _childSex = value!;
                    });
                  }),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: DatePicker(
            initialDate: _childDOB,
            onDateChanged: (newDate) {
              setState(() {
                _childDOB = newDate;
              });
            }),
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
              title: Text(
                'Parent Details',
                style: Theme.of(context).textTheme.headline6,
              ),
              controlAffinity: ListTileControlAffinity.leading,
              initiallyExpanded: widget.parent == null,
              children: _buildParentDetailsForm(),
            ),
            ExpansionTile(
              title: Text(
                'Child Details',
                style: Theme.of(context).textTheme.headline6,
              ),
              controlAffinity: ListTileControlAffinity.leading,
              initiallyExpanded: widget.parent != null,
              children: _buildChildDetails(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            int parentId = widget.parent?.id ??
                await insertParent(
                  Parent(
                      idCardNo: _idNo!,
                      name: _name,
                      number: _number,
                      email: _email),
                );
            Child child = await _insertAndReturnChild(parentId);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImagePickerScreen(child: child),
              ),
            );
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }

  Future<Child> _insertAndReturnChild(int parentId) async {
    Child child = Child(
        parentId: parentId,
        name: _childName!,
        sex: _childSex,
        inputDOB: _childDOB);
    await insertChild(child);
    return child;
  }
}
