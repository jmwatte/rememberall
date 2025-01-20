import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'poem_model.dart';
import 'package:watch_it/watch_it.dart';
import 'package:rememberall2/poems_screen_logic.dart';

class EditorScreen extends StatefulWidget {
  static const routeName = '/editorscreen';

  const EditorScreen({super.key});

  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final contr = TextEditingController();
  final logic = di.get<PoemsScreenLogic>();
  late Poem poem;

  Future<Poem?> showCategoryDialog(Poem poem, BuildContext context) async {
    final categoryController = TextEditingController(text: poem.category);
    return showModalBottomSheet<Poem>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Autocomplete<String>(
                  initialValue: TextEditingValue(text: poem.category),
                  optionsBuilder: (TextEditingValue value) {
                    debugPrint('value= ${value.text}');
                    if (value.text.isEmpty) {
                      return const Iterable<String>.empty();
                    } else {
                      var categories = logic.categories.value;
                      categoryController.text = value.text;
                      return categories.where((option) => option
                          .toLowerCase()
                          .contains(value.text.toLowerCase()));
                    }
                  },
                  onSelected: (String selection) {
                    categoryController.text = selection;
                  },
                ),
              ),
              ElevatedButton(
                child: const Text('Save'),
                onPressed: () {
                  if (categoryController.text.toLowerCase() == "all") {
                    categoryController.text = "";
                  }
                  poem.category = categoryController.text;
                  Navigator.pop(context, poem);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    poem = ModalRoute.of(context)!.settings.arguments as Poem;
    contr.text = poem.theText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('edit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, poem),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check_circle),
            onPressed: () {
              contr.text = contr.text.trimLeft();
              contr.text = contr.text.replaceFirstMapped(
                RegExp(r'^.*$', multiLine: true),
                (Match match) {
                  if (kDebugMode) {
                    print("match0= ${match[0]!}");
                  }
                  return match[0]!.toUpperCase();
                },
              );
              setState(() {
                poem.theText = contr.text;
              });

              if (kDebugMode) {
                print("in editor+ ${poem.theText}");
              }
            },
          ),
        ],
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  TextField(
                    decoration: const InputDecoration(
                      helperText:
                          'title in ALLCAPS. Not in poem at the firstline',
                    ),
                    controller: contr,
                    keyboardType: TextInputType.multiline,
                    minLines: 3,
                    maxLines: null,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(poem.favourite
                        ? Icons.favorite
                        : Icons.favorite_border),
                    onPressed: () {
                      setState(() {
                        poem.favourite = !poem.favourite;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.color_lens),
                    color: poem.level(),
                    onPressed: () async {
                      var showlevel = false;
                      var a = await showDialog<Color>(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return SimpleDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      child: Text(showlevel ? 'Hide' : 'Show'),
                                      onPressed: () {
                                        setState(() {
                                          showlevel = !showlevel;
                                        });
                                      },
                                    ),
                                    const Text(
                                      'Level',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                children: Constants.levelkleur
                                    .map((e) => SimpleDialogOption(
                                          child: CircleAvatar(
                                            backgroundColor: e,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context, e);
                                          },
                                        ))
                                    .toList(),
                              );
                            },
                          );
                        },
                      );
                      if (a != null) {
                        setState(() {
                          poem.levelnr = Constants.levelkleur.indexOf(a);
                        });
                      }
                    },
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.category),
                          onPressed: () {
                            showCategoryDialog(poem, context)
                                .then((updatedItem) {
                              if (updatedItem != null) {
                                setState(() {
                                  poem.category = updatedItem.category;
                                });
                              }
                            });
                          },
                        ),
                        Flexible(
                          child: Text(
                            poem.category,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
