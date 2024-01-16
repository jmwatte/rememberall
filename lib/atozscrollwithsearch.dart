// ignore_for_file: unnecessary_this

import 'package:diacritic/diacritic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:rememberall/databasehelper.dart';

import 'lyricschanger_base.dart';
//import 'lyricschanger_base.dart';

class AtoZSlider extends StatefulWidget {
  final List<LyricsTransformer> items;
  final Function callbackitemclick;
  final Function callbacksearchchange;
  final Function callbackstarclicked;
  final Function callbackmoreclicked;
  final Function callbackDeleteItem;
  final Function callbacklevelchanged;
  final Function callbackcategorychanged;
  AtoZSlider(
      this.items,
      this.callbackitemclick,
      this.callbacksearchchange,
      this.callbackstarclicked,
      this.callbackmoreclicked,
      this.callbacklevelchanged,
      this.callbackDeleteItem,
      this.callbackcategorychanged,
      {super.key}) {
    sortOriginalItems();
  }

  void sortOriginalItems() {
    this.items.sort((a, b) => removeDiacritics(a.title().toUpperCase())
        .compareTo(removeDiacritics(b.title().toUpperCase())));
  } // prend une liste en param

/*
  void setItems(aca) // to easy set new item
  {
    this.items = aca;
    forceSort();
  }

  void forceSort() {
    this.items.sort((a, b) => removeDiacritics(a.toString().toUpperCase())
        .compareTo(removeDiacritics(b.toString().toUpperCase())));
  }
*/ //NOTE: not used
  @override
  _AtoZSlider createState() => _AtoZSlider();
}

class _AtoZSlider extends State<AtoZSlider> {
  late double _offsetContainer;
  late double _heightscroller;
  late List<LyricsTransformer> _itemscache;
  late String _text;
  late String _searchtext;
  late String _oldtext;
  late List<String> _alphabet;
  late bool _customscrollisscrolling;
  late double _itemsizeheight;
  late double _itemfontsize;
  late int _animationcounter; //wait end of all animations
  late double _sizeheightcontainer;
  late double _sizefirstitem;
  //var _lastoffset; //NOTE: [TO UNCOMMENT TO ADD THE GOING DOWNWARD CHANGING LETTER]
  late ScrollController _scrollController;
  late FocusNode _focusNode;
  late DatabaseHelper databaseHelper = DatabaseHelper();

  void onscrolllistview() {
    if (!_customscrollisscrolling && _animationcounter == 0) {
      var indexFirst =
          ((_scrollController.offset / _itemsizeheight) % _itemscache.length)
              .floor();
      /*if (_scrollController.offset > _lastoffset) //Go downward //NOTE: [TO UNCOMMENT TO ADD THE GOING DOWNWARD CHANGING LETTER] (all block)
      {
        var indexLast =
            ((((_heightscroller * _alphabet.length) / _itemsizeheight).floor() +
                        indexFirst) -
                    1) %
                _itemscache.length;
        var fletter = _itemscache[indexLast].toString().toUpperCase()[0];
        var i = _alphabet.indexOf(fletter);
        if (i != -1) {
          setState(() {
            _text = _alphabet[i];
            _offsetContainer = i * _heightscroller;
          });
        }
      } else //Go upward
      {*/
      var fletter = _itemscache[indexFirst].favourite
          ? '*'
          : _itemscache[indexFirst].title().toString().toUpperCase()[0];
      var i = _alphabet.indexOf(fletter);
      if (i != -1) {
        setState(() {
          _text = _alphabet[i];
          _offsetContainer = i * _heightscroller;
        });
      }
      //}
      // _lastoffset = _scrollController.offset; //NOTE: [TO UNCOMMENT TO ADD THE GOING DOWNWARD CHANGING LETTER]
    }
  }

  void onsearchtextchange(text) {
    if (text.length > 0) {
      try {
        var esstring = RegExp.escape(text.toLowerCase());
        RegExp regs = RegExp(esstring);
        _itemscache.clear();
        List<LyricsTransformer> searchres = [];
        for (var element in widget.items) {
          if (regs.hasMatch(element.title().toString().toLowerCase())) {
            searchres.add(element);
          }
        }
        _itemscache = searchres
            .where((element) => element.favourite)
            .followedBy(searchres.where((element) => !element.favourite))
            .toList();

        setState(() {
          _searchtext = text;
          _scrollController.jumpTo(0.0);
        });
        widget.callbacksearchchange(text);
      } catch (e) {
        debugPrint("coucou");
      } //regex error
    } else if (text.length != _searchtext.length) {
      setState(() {
        _searchtext = text;
        //_itemscache = List.from(widget.items);
        setItemscache();
      });
    }
  }

  void onfocustextfield() {
    setState(() {});
  }

  void onItemClick(index) {
    setState(() {
      FocusScope.of(context).requestFocus(FocusNode());
    }); //NOTE: unfocus search when you click on listview
    for (var i = 0; i < widget.items.length; i++) {
      if (widget.items[i].id == _itemscache[index].id) {
        index = i;
        break;
      }
    }
    widget.callbackitemclick(index);
  }

  void onStarItemClicked(index) {
    // widget.items.where((element) => element.key == index).forEach((element) {
    //  element.favourite = !element.favourite;
    // });
    /* for (var item in widget.items) {
     if (item.key == _itemscache[index].key) {
       item.favourite=!item.favourite;

     }
    }
 */
    widget.callbackstarclicked(index);
  }

  void onMoreSlideClicked(index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                widget.callbackDeleteItem(index);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Category'),
              onTap: () {
                Navigator.pop(context);
                showCategoryDialog(widget.items[index]).then((updatedItem) {
                  if (updatedItem != null) {
                    setState(() {
                      //databaseHelper.updatelyric(updatedItem);
                      // updateCategory(updatedItem.id!, updatedItem.category);
                      widget.callbackmoreclicked(index);
                      widget.items[index] = updatedItem;
                    });
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  void deleteItem(index) {
    // Implement your delete logic here
  }

  Future<LyricsTransformer?> showCategoryDialog(LyricsTransformer item) async {
    final categoryController = TextEditingController(text: item.category);
    return showModalBottomSheet<LyricsTransformer>(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: categoryController,
                onChanged: (value) {
                  item.category = value.isNotEmpty ? value : '';
                },
                decoration: InputDecoration(
                  labelText: item.category == null || item.category.isEmpty
                      ? "Enter category"
                      : "Change ${item.category}",
                ),
              ),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                // setState(() {
                //   updateCategory(item.id, item.category);
                //   // Update the category of the item in the database
                //   //databaseHelper.updatelyric(item);
                //   widget.callbackcategorychanged(item);
                // });

                Navigator.pop(context, item);
              },
            ),
          ],
        );
      },
    );
  }

  void updateCategory(int id, String newCategory) {
    // Find the item with the same id
    setState(() {
      var itemToUpdate = widget.items.firstWhere((element) => element.id == id);

      // Update the category of the item
      itemToUpdate.category = newCategory;

      // Update the state to reflect the change in the UI
    });
  }

  @override
  void initState() {
    super.initState();
    setItemscache(); //NOTE: copy of original items for search
    _customscrollisscrolling = false;
    _offsetContainer = 0.0;
    _animationcounter = 0;
    _searchtext = "";
    _itemsizeheight = 48.0; //NOTE: size items
    _itemfontsize = 14.0; //NOTE: fontsize items
    _sizefirstitem = 60.0; //NOTE: size of the container above
    //_lastoffset = 0.0; //NOTE: [TO UNCOMMENT TO ADD THE GOING DOWNWARD CHANGING LETTER]
    _sizeheightcontainer = 0.0;
    _focusNode = FocusNode();
    _focusNode.addListener(onfocustextfield);
    _scrollController = ScrollController();
    _scrollController.addListener(onscrolllistview);
    _alphabet = []; //List<String>();

    setUpAlphabet();
  }

  ///try to move the favourites to the top
  var numOfFav = 0;
  void setItemscache() {
    var fav = widget.items.where((i) => i.favourite);
    numOfFav = fav.length;
    var notfav = widget.items.where((i) => !i.favourite).toList()
      ..sort(
          (a, b) => a.title().toUpperCase().compareTo(b.title().toUpperCase()));
    //fav.followedBy(notfav);
    _itemscache = fav.followedBy(notfav).toList();
  }

  bool hasfavourites = false;
  void setUpAlphabet() {
    _alphabet.clear();
    for (var i = 0; i < _itemscache.length; i++) {
      if (_itemscache[i].title().toString().trim().isNotEmpty) {
        var fletter = removeDiacritics(
            _itemscache[i].title().toString().trim()[0].toUpperCase());
        if (!_alphabet.contains(fletter)) {
          _alphabet.add(fletter);
        }
      }
    }
    widget.items.any((element) => element.favourite)
        ? hasfavourites = true
        : hasfavourites = false;
    if (kDebugMode) {
      print(hasfavourites);
    }
    _text = "*";
    _oldtext = _text;
    if (_alphabet.isNotEmpty) {
      _alphabet.sort();
      _text = _alphabet[0];
      _oldtext = _text;
      if (hasfavourites) _alphabet.insert(0, '*');
    } else {
      throw Exception('-> Zero items in list. <-');
    }
  }

  final mappedColors = Constants.levelkleur
      .map((e) => SimpleDialogOption(
            child: CircleAvatar(
              backgroundColor: e,
            ),
          ))
      .toList();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, contrainsts) {
      _heightscroller = (contrainsts.biggest.height - _sizefirstitem) /
          _alphabet
              .length; //NOTE: Here the contrainsts.biggest.height is the height of the list (height of body)
      _sizeheightcontainer = contrainsts.biggest.height -
          _sizefirstitem; //NOTE: Here i'm substracting the size of the container above of the listView
      return Column(children: [
        Container(
            padding: const EdgeInsets.all(10),
            height: _sizefirstitem,
            child: TextField(
              focusNode: _focusNode,
              onChanged: onsearchtextchange,
              decoration: const InputDecoration(
                  labelText: "Search",
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6.0)))),
            )),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => {
            setState(() {
              FocusScope.of(context).requestFocus(FocusNode());
            }) //NOTE: unfocus search when you click on scroller
          },
          child: SizedBox(
              height:
                  _sizeheightcontainer, //NOTE: Here is were is set the size of the listview
              child: Stack(alignment: Alignment.topRight, children: [
                //NOTE: Here to add some other components (but you need to remove they height from calcs (line above))
                ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 28),
                  itemExtent: _itemsizeheight,
                  itemCount: _itemscache.length,
                  itemBuilder: (BuildContext context, int index) {
                    //NOTE: How you want to generate your items
                    return GestureDetector(
                      onTap: () => onItemClick(index),
                      child: Slidable(
                        startActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          extentRatio: 0.25,
                          children: [
                            SlidableAction(
                              icon: Icons.star,
                              //make the color red if the iteem is a favourite,
                              foregroundColor: _itemscache[index].favourite
                                  ? Colors.green
                                  : Colors.black,
                              onPressed: (context) {
                                setState(() {
                                  _itemscache[index].favourite =
                                      !_itemscache[index].favourite;
                                  onStarItemClicked(_itemscache[index].id);
                                  // setUpAlphabet();
                                  // setItemscache();
                                });
                              },
                            ),
                            SlidableAction(
                              icon: Icons.more_horiz,
                              onPressed: (context) => onMoreSlideClicked(index),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          leading: InkWell(
                            onLongPress: () async {
                              var a = await showDialog<Color>(
                                  context: context,
                                  builder: (context) {
                                    return SimpleDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0)),
                                        title: const Text(
                                          'level', // Remove the 'const' keyword here
                                          textAlign: TextAlign.center,
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
                                            .toList());
                                  });
                              if (a != null) {
                                _itemscache[index].levelnr =
                                    Constants.levelkleur.indexOf(a);
                                onSetLevelColor(_itemscache[index]);
                              }
                            },
                            child: CircleAvatar(
                              backgroundColor: _itemscache[index].level(),
                              child: _itemscache[index].favourite
                                  ? const Icon(Icons.star)
                                  : null,
                            ),
                          ),
                          title: Text(_itemscache[index].title().toString(),
                              style: TextStyle(fontSize: _itemfontsize)),
                          subtitle: Text(
                            _itemscache[index].lyrics(),
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ),

//
//
                      ///
                      ///
                      ///
                      ///
                      ///
                    );
                  },
                ),
                Visibility(
                  visible: _focusNode.hasFocus ||
                          _searchtext.isNotEmpty ||
                          _itemscache.length < 10
                      ? false
                      : true,
                  child: GestureDetector(
                    child: Container(
                        height: _heightscroller,
                        margin: EdgeInsets.only(top: _offsetContainer),
                        child: Container(
                          //NOTE: this container is the scroll bar it need at least to have height => _heightscroller
                          width: _heightscroller,
                          decoration: const BoxDecoration(
                            color:
                                Colors.indigo, //NOTE: change color of scroller
                            shape: BoxShape
                                .circle, //NOTE: change this to rectangle
                          ),
                          child: Text(
                            _text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: (_heightscroller - 4),
                                fontWeight: FontWeight.bold,
                                color: Colors
                                    .white), //NOTE: white -> color of text of scroller
                          ),
                        )),
                    onVerticalDragStart: (DragStartDetails details) {
                      _customscrollisscrolling = true;
                    },
                    onVerticalDragEnd: (DragEndDetails details) {
                      _customscrollisscrolling = false;
                    },
                    onVerticalDragUpdate: (DragUpdateDetails details) {
                      setState(() {
                        if ((_offsetContainer + details.delta.dy) >= 0 &&
                            (_offsetContainer + details.delta.dy) <=
                                (_sizeheightcontainer - _heightscroller)) {
                          _offsetContainer += details.delta.dy;
                          _text = _alphabet[
                              ((_offsetContainer / _heightscroller) %
                                      _alphabet.length)
                                  .round()];
                          if (kDebugMode) {
                            print(_text + _oldtext);
                          }
                          if (_text != _oldtext) {
                            if (_text == '*') {
                              var i = 0;
                              _animationcounter++;
                              _scrollController
                                  .animateTo(
                                      (i * _itemsizeheight)
                                          .toDouble(), //NOTE: To configure the animation
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.ease)
                                  .then((x) => {_animationcounter--});
                            } else {
                              for (var i = numOfFav;
                                  i < _itemscache.length;
                                  i++) {
                                if (_itemscache[i]
                                        .title()
                                        .toString()
                                        .trim()
                                        .isNotEmpty &&
                                    _itemscache[i]
                                            .title()
                                            .toString()
                                            .trim()
                                            .toUpperCase()[0] ==
                                        _text.toString().toUpperCase()[0]) {
                                  _animationcounter++;
                                  _scrollController
                                      .animateTo(
                                          (i * _itemsizeheight)
                                              .toDouble(), //NOTE: To configure the animation
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.ease)
                                      .then((x) => {_animationcounter--});
                                  break;
                                }
                              }
                              _oldtext = _text;
                            }
                          }
                        }
                      });
                    },
                  ),
                )
              ])),
        ),
      ]);
    });
  }

  void onSetLevelColor(itemscache) {
    widget.callbacklevelchanged(itemscache);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('_itemscache', _itemscache));
  }
}
