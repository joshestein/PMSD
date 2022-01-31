import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:proto/models/parent.dart';
import 'package:proto/views/add_patient.dart';
import 'package:proto/views/children_for_parent.dart';

class Parents extends StatefulWidget {
  const Parents({Key? key}) : super(key: key);

  @override
  _ParentsState createState() => _ParentsState();
}

class _ParentsState extends State<Parents> {
  late List<Parent> _parents;
  List<Parent> _filteredParents = [];
  bool _isSearching = false;
  Widget _appBarTitle = const Text('Parents');

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    getAllParents().then((result) => {
          setState(() {
            _parents = result;
            _filteredParents = result;
          })
        });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _appBarTitle,
        centerTitle: _isSearching,
        actions: [
          !_isSearching
              ? IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                      _appBarTitle = TextField(
                        controller: _controller,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          border: InputBorder.none,
                        ),
                        onChanged: (text) {
                          setState(() {
                            _filteredParents = _parents
                                .where(
                                    (parent) => parent.idCardNo.contains(text))
                                .toList();
                          });
                        },
                      );
                    });
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _appBarTitle = const Text('Parents');
                      _controller.clear();
                      _filteredParents = _parents;
                    });
                  },
                ),
        ],
      ),
      body: ListView.builder(
        itemCount: _filteredParents.length,
        itemBuilder: (BuildContext context, int index) {
          return ChildrenForParent(parent: _filteredParents[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPatientForm(),
            ),
          );
        },
      ),
    );
  }
}
