import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:proto/date_picker.dart';
import 'package:proto/imaging/image_picker.dart';
import 'package:proto/models/child.dart';
import 'package:proto/models/parent.dart';

class AddPatientForm extends StatefulWidget {
  final Parent? parent;
  final Child? child;

  const AddPatientForm({Key? key, this.parent, this.child}) : super(key: key);

  @override
  _AddPatientFormState createState() => _AddPatientFormState();
}

class _AddPatientFormState extends State<AddPatientForm> {
  final _formKey = GlobalKey<FormState>();
  late Parent _parent;
  late Child _child;

  // TODO: make other sections collapse when current section is active
  // bool _parentCollapsed = false;
  // bool _childCollapsed = true;

  @override
  initState() {
    super.initState();
    _parent = widget.parent ?? Parent(idCardNo: 'dummy');
    _child = widget.child ?? Child(parentId: -1, name: 'dummy');
  }

  List<Widget> _buildParentDetailsForm() {
    return [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          onSaved: (idNo) => {if (idNo != null) _parent.idCardNo = idNo},
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
          onSaved: (name) => _parent.name = name,
          initialValue: widget.parent?.name,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Parent Name',
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          onSaved: (number) => _parent.number = number,
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
          onSaved: (email) => _parent.email = email,
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
          initialValue: widget.child?.name,
          onSaved: (name) => {if (name != null) _child.name = name},
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
                  value: _child.sex,
                  isExpanded: true,
                  items: <String>['M', 'F'].map((String sex) {
                    return DropdownMenuItem<String>(
                      value: sex,
                      child: Text(sex),
                    );
                  }).toList(),
                  onChanged: (sex) {
                    setState(() {
                      _child.sex = sex!;
                    });
                  }),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: DatePicker(
            initialDate: widget.child?.dateOfBirth,
            onDateChanged: (newDate) {
              setState(() {
                _child.dateOfBirth = newDate;
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
            int parentId = await insertParent(_parent);
            _child.parentId = parentId;
            await insertChild(_child);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImagePickerScreen(child: _child),
              ),
            );
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
