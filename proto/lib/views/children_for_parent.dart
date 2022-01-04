import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:proto/models/child.dart';
import 'package:proto/models/parent.dart';

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
        children: [
          // TODO: Add a FutureBuilder
          ListView.builder(
            itemCount: _children.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_children[index].name),
                subtitle: Text(_children[index].ageInMonths ?? ''),
              );
            },
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
          ),
        ]);
  }
}
