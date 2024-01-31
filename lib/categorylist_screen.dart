import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:rememberall2/poems_screen_logic.dart';
import 'package:watch_it/watch_it.dart';

class CategoryListScreen extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  final List<String>
      categories; // Assume this list is populated with categories from the database
  final Function(String, String) onRenameCategory;
  final Function(String) onDeleteCategory;
  // final ValueNotifier<List<String>> categoriesNotifier;

  const CategoryListScreen(
      {super.key,
      required this.categories,
      required this.onRenameCategory,
      required this.onDeleteCategory});
  //   : categoriesNotifier = ValueNotifier<List<String>>(categories),
  //   super(key: key)

  @override
  CategoryListScreenState createState() => CategoryListScreenState();
}

class CategoryListScreenState extends State<CategoryListScreen> {
  //late final ValueNotifier<List<String>> categoriesNotifier;

  @override
  void initState() {
    super.initState();
    //categoriesNotifier = ValueNotifier<List<String>>(widget.categories);
  }

  void deletingCategory(String name) {
    setState(() {
      widget.categories.remove(name);
      widget.onDeleteCategory(name);
      // categoriesNotifier.value = widget.categories;
    });
  }

  void renamingCategory(String oldName, String newName) {
    setState(() {
      widget.categories.remove(oldName);
      widget.categories.add(newName);
      widget.onRenameCategory(oldName, newName);
      // categoriesNotifier.value = widget.categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> categories =
        watchValue((PoemsScreenLogic logic) => logic.categories);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Slidable(
              startActionPane: ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.25,
                children: <Widget>[
                  SlidableAction(
                    icon: Icons.edit,
                    label: 'rename',
                    backgroundColor: Colors.blue,
                    onPressed: (context) async {
                      // Show a dialog to get the new name
                      await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                          final TextEditingController controller =
                              TextEditingController();
                          return AlertDialog(
                            title: const Text('Rename Category'),
                            content: TextField(
                              controller: controller,
                              autofocus: true,
                              decoration: const InputDecoration(
                                labelText: 'New name',
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  String newName = controller.text;
                                  if (newName.isNotEmpty) {
                                    // Call the callback function with the old and new names
                                    di.get<PoemsScreenLogic>().onRenameCategory(
                                        categories[index], newName);
                                  }
                                  // Use newName here...
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Rename'),
                              ),
                            ],
                          );
                        },
                      );

                      // ignore: unnecessary_null_comparison
                    },
                  ),
                  SlidableAction(
                    label: 'delete',
                    backgroundColor: Colors.indigo,
                    icon: Icons.delete,
                    onPressed: (context) async {
                      bool confirmDelete = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm"),
                            content: const Text(
                                "Are you sure you wish to delete this item?"),
                            actions: <Widget>[
                              TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text("DELETE")),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text("CANCEL"),
                              ),
                            ],
                          );
                        },
                      );
                      if (confirmDelete) {
                        // Call the callback function with the category to be deleted
                        di
                            .get<PoemsScreenLogic>()
                            .onDeleteCategory(categories[index]);
                      }
                    },
                  ),
                ],
              ),
              child: ListTile(
                title: Text(categories[index]),
                onTap: () {
                  Navigator.pop(context, categories[index]);
                },
              ));
        },
      ),
    );
  }
}

/* class ItemsScreen extends StatelessWidget { 
  final String category;

  ItemsScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    // Assume getItemsByCategory is a function that returns a Future<List<Item>>
    // where Item is a class that represents an item in the database
    return FutureBuilder<List<Item>>(
      future: getItemsByCategory(category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data![index].title),
                // Add more properties of the item here
              );
            },
          );
        }
      },
    );
  }
}
*/