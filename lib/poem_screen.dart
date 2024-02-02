import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rememberall2/poem_screen_logic.dart';
import 'package:rememberall2/poems_screen_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rememberall2/databasehelper.dart';
import 'package:rememberall2/blokkerscreen.dart';
import 'package:rememberall2/editorscreen.dart';
import 'package:rememberall2/poem_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_font_picker/flutter_font_picker.dart';
import 'package:rememberall2/fonts.dart';
import 'package:watch_it/watch_it.dart';
import 'package:connectivity/connectivity.dart';

class OnePoemSreen extends StatefulWidget with WatchItStatefulWidgetMixin {
  final Poem poem;
  final String title;
  const OnePoemSreen({super.key, required this.title, required this.poem});

  @override
  OnePoemSreenState createState() => OnePoemSreenState();
}

class OnePoemSreenState extends State<OnePoemSreen> {
  DatabaseHelper helper = DatabaseHelper();
  bool isvisible = false;
  String _selectedFont = "Roboto Mono"; // Use 'Roboto' as a default font
  //TextStyle? _selectedFonttextStyle;
  late FontStyle _selectedFontStyle;
  late FontWeight _selectedFontWeight;

  int _counterStart = 0;
  int _counterEnd = 0;
  @override
  void initState() {
    super.initState();
    // _loadBlokker();
    _loadFont();
    var selectedPrefs = di.get<PoemScreenLogic>().useSharedPrefs;
    if (selectedPrefs) {
      di.get<PoemScreenLogic>().initSharedPrefs();
    } else {
      di
          .get<PoemScreenLogic>()
          .usePoemsPrefs(di.get<PoemsScreenLogic>().selectedPoem.value);
    }
  }

  void _loadFont() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _selectedFont = prefs.getString('selectedFont') ?? 'Roboto Mono';

    setState(() {});
  }

  void _incrementCounterStart() {
    setState(() {
      _counterStart++;
      di.get<PoemScreenLogic>().counterStart.value = _counterStart;
      widget.poem.extraVisibleWordsStart = _counterStart;
    });
  }

  void _decrementCounterStart() {
    setState(() {
      _counterStart--;
      if (_counterStart < 0) {
        _counterStart = 0;
      }
      di.get<PoemScreenLogic>().counterStart.value = _counterStart;
      widget.poem.extraVisibleWordsStart = _counterStart;
    });
  }

  void _incrementCounterEnd() {
    setState(() {
      _counterEnd++;
      di.get<PoemScreenLogic>().counterEnd.value = _counterEnd;
      widget.poem.extraVisibleWordsEnd = _counterEnd;
    });
  }

  void _decrementCounterEnd() {
    setState(() {
      _counterEnd--;
      if (_counterEnd < 0) {
        _counterEnd = 0;
      }
      di.get<PoemScreenLogic>().counterEnd.value = _counterEnd;
      widget.poem.extraVisibleWordsEnd = _counterEnd;
    });
  }

  void handleTheActions(String choice) {
    if (choice == Constants.blokker) {
      _goAndPickTheBlokker(context);
      if (kDebugMode) {
        print('blokker');
      }
    } else if (choice == Constants.font) {
      _goAndSelectTheFont(context);
      if (kDebugMode) {
        print('font');
      }
    } else if (choice == Constants.edit) {
      _goAndEditThePoem(context, widget.poem);
      if (kDebugMode) {
        print('edit');
      }
    } else if (choice == Constants.aNewPoem) {
      _goAndMakeNewPoem(context);
    } else if (choice == Constants.delete) {
      setState(() {
        helper.deletePoemByID(widget.poem.id!);
      });
      Navigator.pop(context, true);
    } else if (choice == Constants.add) {
      addToDatabase(widget.poem);
    } else if (choice == Constants.prefs) {
//pop up a dialog that lets you choose between use the SharedPrefs or the Prefs from the song
      // pop up a dialog with 2 choices on it
      // 1. use the prefs from the song
      // 2. use the shared prefs
      // if 1 is chosen then use the prefs from the song
      // if 2 is chosen then use the shared prefs
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                  'Save these prefs to the poem or to the shared prefs'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                      child: const Text('Save the prefs to the poem'),
                      onTap: () {
                        Navigator.of(context).pop();
                        di.get<PoemScreenLogic>().savePoemsPrefs();
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                    ),
                    GestureDetector(
                      child: const Text('Save to the shared prefs'),
                      onTap: () {
                        Navigator.of(context).pop();
                        di.get<PoemScreenLogic>().saveSharedPrefs();
                      },
                    ),
                  ],
                ),
              ),
            );
          });
    }
  }

  _goAndSelectTheFont(BuildContext context2) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FontPicker(
          googleFonts: myGoogleFonts,
          onFontChanged: (PickerFont font) async {
            _selectedFont = font.fontFamily;
            _selectedFontStyle = font.fontStyle;
            _selectedFontWeight = font.fontWeight;
            //  _selectedFonttextStyle = font.toTextStyle();
            // obtain shared preferences
            final prefs = await SharedPreferences.getInstance();
            prefs.setString('selectedFont', _selectedFont);
            prefs.setString('selectedFontStyle', _selectedFontStyle.toString());
            prefs.setString(
                'selectedFontWeight', _selectedFontWeight.toString());
            _loadFont();

            if (kDebugMode) {
              print(_selectedFont);
            }
          },
        ),
      ),
    );
  }

  _goAndEditThePoem(BuildContext context, Poem poem) async {
    final result = await Navigator.pushNamed(context, EditorScreen.routeName,
        arguments: poem);
    if (kDebugMode) {
      print('resukltaat:$result');
    }
    //update the excisting lyric in the database with the new lyrics
    if (result is String) {
      setState(() {
        if (result.toString().isNotEmpty) {
          widget.poem.theText = result;
          helper.updatePoem(widget.poem);
        }
      });
    }
  }

  // A method that launches the SelectionScreen and awaits the result from
  // Navigator.pop.
  _goAndPickTheBlokker(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BlokkerScreen()),
    );
    // obtain shared preferences
    //final prefs = await SharedPreferences.getInstance();

    // set value
    if (null != result) {
      // prefs.setString('blokker', result);
      setState(() {
        di.get<PoemScreenLogic>().blokker.value = result.consonant;
        di.get<PoemScreenLogic>().blokkerVowel.value = result.vowel;
        widget.poem.blokker = result.constonant;
        widget.poem.blokkerVowel = result.vowel;
      });
    }
  }

  void _toggleStart() {
    di.get<PoemScreenLogic>().toggleStart.value =
        !di.get<PoemScreenLogic>().toggleStart.value;
    //setState(() {
    widget.poem.seeStart = !widget.poem.seeStart;
    // });
  }

  void _toggleEnd() {
    di.get<PoemScreenLogic>().toggleEnd.value =
        !di.get<PoemScreenLogic>().toggleEnd.value;
    widget.poem.seeEnd = !widget.poem.seeEnd;
  }

  var cycler = di.get<PoemScreenLogic>().cycler.value;
  // void _pickTheScrambleMethod() {

  //   setState(() {
  //     cycler++;
  //     if (cycler > 2) {
  //       cycler = 0;
  //     }
  //     Scramblemethod choosenScrambleMethod;
  //     switch (cycler) {
  //       case 0:
  //         choosenScrambleMethod = Scramblemethod.xForAll;

  //         di.get<PoemScreenLogic>().cycleColor.value = Colors.red;
  //         break;
  //       case 1:
  //         choosenScrambleMethod = Scramblemethod.xForConsonants;
  //         di.get<PoemScreenLogic>().cycleColor.value = Colors.orange;

  //         break;
  //       case 2:
  //         choosenScrambleMethod = Scramblemethod.xForVowels;
  //         di.get<PoemScreenLogic>().cycleColor.value = Colors.green;
  //         break;
  //       default:
  //         choosenScrambleMethod = Scramblemethod.xForAll;
  //         di.get<PoemScreenLogic>().cycleColor.value = Colors.red;
  //     }
  //     di.get<PoemScreenLogic>().cycler.value = cycler;
  //     widget.poem.scramble = choosenScrambleMethod;
  //     di.get<PoemScreenLogic>().scrambleMethod.value = choosenScrambleMethod;
  //   });
  // }

  void _showPoems() {
    setState(() {
      isvisible = !isvisible;
    });
  }

  void _goAndMakeNewPoem(BuildContext context) {}

  void addToDatabase(Poem poem) async {
    int result;
    result = await helper.updatePoem(poem);
    if (result != 0) {
      _showAlertDialog('status', 'saved');
    } else {
      _showAlertDialog('status', 'failed to save');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  // bool ct = false;
  @override
  Widget build(BuildContext context) {
    bool isStartToggled = watchValue((PoemScreenLogic s) => s.toggleStart);
    bool isEndToggled = watchValue((PoemScreenLogic s) => s.toggleEnd);
    bool isVisibilityFirstLetterToggled =
        watchValue((PoemScreenLogic s) => s.toggleVisibilityFirstLetter);
    Color cycleColor = watchValue((PoemScreenLogic s) => s.cycleColor);
    ConnectivityResult connectionStatus =
        watchValue((PoemScreenLogic s) => s.connectionStatus);

    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: IconButton(
                  icon: const Icon(Icons.logout),
                  color: isStartToggled ? Colors.red : null,
                  onPressed: _toggleStart),
            ),
            Visibility(
              visible: isStartToggled,
              child: Flexible(
                child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _incrementCounterStart),
              ),
            ),
            Visibility(
              visible: isStartToggled,
              child: Flexible(
                child: IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _decrementCounterStart),
              ),
            ),
            Flexible(
              child: IconButton(
                  icon: const Icon(Icons.line_weight),
                  color: cycleColor,
                  onPressed: di.get<PoemScreenLogic>().pickTheScrambleMethod),
            ),
            Flexible(
              child: IconButton(
                  icon: const Icon(Icons.double_arrow),
                  color: isVisibilityFirstLetterToggled ? Colors.red : null,
                  onPressed: _hideFirstLetter),
            ),
            Visibility(
              visible: isEndToggled,
              child: Flexible(
                child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _incrementCounterEnd),
              ),
            ),
            Visibility(
              visible: isEndToggled,
              child: Flexible(
                child: IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _decrementCounterEnd),
              ),
            ),
            Flexible(
              child: IconButton(
                  icon: const Icon(Icons.login),
                  color: isEndToggled ? Colors.red : null,
                  onPressed: _toggleEnd),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: handleTheActions,
            itemBuilder: (BuildContext context) {
              return Constants.choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  enabled: choice != "Font" ||
                      connectionStatus != ConnectivityResult.none,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
        title: Text(widget.poem.poemTitle()),
        automaticallyImplyLeading: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RichText(
                text: TextSpan(
                    text: isvisible
                        ? di.get<PoemScreenLogic>().poemText()
                        : di.get<PoemScreenLogic>().transformed(),
                    style: GoogleFonts.getFont(_selectedFont,
                        color: Colors.black, fontSize: 14.0))),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showPoems,
        tooltip: 'show/hide',
        child: isvisible
            ? const Icon(Icons.visibility_off)
            : const Icon(Icons.visibility),
      ), // This trailing comma makies auto-formatting nicer for build methods.
    );
  }

  void _hideFirstLetter() {
    di.get<PoemScreenLogic>().toggleVisibilityFirstLetter.value =
        !di.get<PoemScreenLogic>().toggleVisibilityFirstLetter.value;

    di.get<PoemScreenLogic>().toggleVisibilityFirstLetter.value
        ? widget.poem.extraVisibleLetters = 1
        : widget.poem.extraVisibleLetters = 0;
  }
}
