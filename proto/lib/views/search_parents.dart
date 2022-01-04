import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:proto/models/parent.dart';

class SearchParents extends StatefulWidget {
  const SearchParents({Key? key}) : super(key: key);

  @override
  _SearchParentsState createState() => _SearchParentsState();
}

class _SearchParentsState extends State<SearchParents> {
  late List<String> _parentIds;
  List<String> _filteredIds = [];
  bool _isSearching = false;
  Widget _appBarTitle = const Text('Search Parents');

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    getAllParentsIds().then((result) => setState(() {
          _parentIds = result;
          _filteredIds = result;
        }));
    // TODO: change this to get all children, _grouped by_ parentId
    super.initState();
  }

  // List<Widget> _buildListOfParents() {}

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
          return ExpansionTile(
            title: Text(_filteredIds[index]),
            children: [
              // TODO: add existing children
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add),
                        label: const Text('Add new child')),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      // // TODO: use FutureBuilder
      // body: _parentIds == null
      //     ? Center(child: CircularProgressIndicator())
      //     : ListView.builder(
      //         itemCount: _parentIds.length,
      //         itemBuilder: (context, index) {
      //           final parentId = _parentIds[index];
      //           return FutureBuilder<Parent>(
      //             future: getParent(parentId),
      //             builder: (context, snapshot) {
      //               if (snapshot.hasData) {
      //                 final parent = snapshot.data;
      //                 return ListTile(
      //                   title: Text(parent.name),
      //                   subtitle: Text(parent.email),
      //                 );
      //               } else if (snapshot.hasError) {
      //                 return Text('${snapshot.error}');
      //               }
      //               return CircularProgressIndicator();
      //             },
      //           );
      //         },
      //       ),
    );
  }
}
