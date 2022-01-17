import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:proto/imaging/image_picker.dart';
import 'package:proto/models/child.dart';
import 'package:proto/models/parent.dart';
import 'package:proto/views/add_patient.dart';

class ChildrenForParent extends StatefulWidget {
  final Parent parent;

  const ChildrenForParent({Key? key, required this.parent}) : super(key: key);

  @override
  _ChildrenForParentState createState() => _ChildrenForParentState();
}

class _ChildrenForParentState extends State<ChildrenForParent> {
  List<Child> _children = [];
  bool _fetched = false;

  // Prefer asynchronously pulling children for a particular parent to avoid
  // fetching all parents and children at initilization
  void _fetchChildren() async {
    int parentId =
        widget.parent.id ?? await getParentId(widget.parent.idCardNo);
    List<Child> children = await getChildrenForParent(parentId);

    setState(() {
      _children = children;
      _fetched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        title: Text(widget.parent.idCardNo,
            style: Theme.of(context).textTheme.headline6),
        onExpansionChanged: (value) {
          if (!_fetched) {
            _fetchChildren();
          }
        },
        controlAffinity: ListTileControlAffinity.leading,
        trailing: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddPatientForm(parent: widget.parent),
                ),
              );
            },
            icon: const Icon(Icons.add)),
        children: [
          // TODO: Add a FutureBuilder
          ListView.separated(
            itemCount: _children.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_children[index].name),
                // Approximate the days in months by dividing the days by 30
                subtitle: Text(
                    'Age: ${DateTime.now().difference(_children[index].dateOfBirth).inDays ~/ 30} months'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ImagePickerScreen(child: _children[index]),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (context, index) {
              return const Divider();
            },
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
          ),
        ]);
  }
}
