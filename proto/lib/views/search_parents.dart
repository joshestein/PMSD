import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:proto/models/parent.dart';
import 'package:proto/views/add_patient.dart';
import 'package:proto/views/children_for_parent.dart';

class SearchParents extends StatefulWidget {
  const SearchParents({Key? key}) : super(key: key);

  @override
  _SearchParentsState createState() => _SearchParentsState();
}

class _SearchParentsState extends State<SearchParents> {
  late List<Parent> _parents;
  late List<String> _parentIds;
  List<String> _filteredIds = [];
  bool _isSearching = false;
  Widget _appBarTitle = const Text('Parents');

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    getAllParents().then((result) => {
          setState(() {
            _parents = result;
            _parentIds = _parents.map((parent) => parent.idCardNo).toList();
            _filteredIds = _parents.map((parent) => parent.idCardNo).toList();
          })
        });
    super.initState();
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
                            _filteredIds = _parentIds
                                .where((id) => id.contains(text))
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
                      _appBarTitle = const Text('Search Parents');
                      _controller.clear();
                      _filteredIds = _parentIds;
                    });
                  },
                ),
        ],
      ),
      body: ListView.builder(
        itemCount: _filteredIds.length,
        itemBuilder: (BuildContext context, int index) {
          return ChildrenForParent(parent: _parents[index]);
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
