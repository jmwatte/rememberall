import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'databasehelper.dart';
import 'blokkerscreen.dart';
import 'editorscreen.dart';
import 'lyricschanger_base.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_font_picker/flutter_font_picker.dart';
import 'fonts.dart';

class MyHomePage extends StatefulWidget {
  final LyricsTransformer ltf;
  final String title;
  MyHomePage({Key? key, required this.title, required this.ltf})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var cycler = 0;
  DatabaseHelper helper = DatabaseHelper();
  bool isvisible = false;
  String _selectedFont = "Roboto Mono"; // Use 'Roboto' as a default font
  //TextStyle? _selectedFonttextStyle;
  late FontStyle _selectedFontStyle;
  late FontWeight _selectedFontWeight;

  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _loadBlokker();
    _loadFont();
  }

  void _loadFont() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _selectedFont = prefs.getString('selectedFont') ?? 'Roboto Mono';
    setState(() {});
  }

  _loadBlokker() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      widget.ltf.blokker = (prefs.getString('blokker') ?? "x");
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      widget.ltf.extraVisibleWords = _counter;
    });
  }

  void choiceAction(String choice) {
    if (choice == Constants.blokker) {
      _navigateAndDisplaySelection(context);
      if (kDebugMode) {
        print('blokker');
      }
    } else if (choice == Constants.font) {
      if (kDebugMode) {
        print('font');
        _openfontselector(context);
      }
    } else if (choice == Constants.edit) {
      _openeditor(context, widget.ltf);
      if (kDebugMode) {
        print('edit');
      }
    } else if (choice == Constants.aNewLyric) {
      _openNeweditor(context);
    } else if (choice == Constants.delete) {
      setState(() {
        helper.deletelyric(widget.ltf.id!);
      });
      Navigator.pop(context, true);
    } else if (choice == Constants.add) {
      addToDatabase(widget.ltf);
    }
  }

  _openfontselector(BuildContext context) async {
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

  _openeditor(BuildContext context, LyricsTransformer input) async {
    final result = await Navigator.pushNamed(context, EditorScreen.routeName,
        arguments: input);
    if (kDebugMode) {
      print('resukltaat:$result');
    }
    //update the excisting lyric in the database with the new lyrics
    if (result is String) {
      setState(() {
        if (result.toString().isNotEmpty) {
          widget.ltf.input = result;
          helper.updatelyric(widget.ltf);
        }
      });
    }
  }

  // A method that launches the SelectionScreen and awaits the result from
  // Navigator.pop.
  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectionScreen()),
    );
    // obtain shared preferences
    final prefs = await SharedPreferences.getInstance();

    // set value
    prefs.setString('blokker', result);
    setState(() {
      widget.ltf.blokker = result;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
      if (_counter < 0) {
        _counter = 0;
      }
      widget.ltf.extraVisibleWords = _counter;
    });
  }

  void _toggleStart() {
    setState(() {
      widget.ltf.seeStart = !widget.ltf.seeStart;
    });
  }

  void _toggleEnd() {
    setState(() {
      widget.ltf.seeEnd = !widget.ltf.seeEnd;
    });
  }

  void _cycleXes() {
    setState(() {
      cycler++;
      if (cycler > 2) {
        cycler = 0;
      }
      switch (cycler) {
        case 0:
          widget.ltf.scramble = Scramblemethod.xForAll;
          break;
        case 1:
          widget.ltf.scramble = Scramblemethod.xForConsonants;
          break;
        case 2:
          widget.ltf.scramble = Scramblemethod.xForVowels;
          break;
        default:
      }
    });
  }

  void _showlyrics() {
    setState(() {
      isvisible = !isvisible;
    });
  }

  void _openNeweditor(BuildContext context) {}

  void addToDatabase(LyricsTransformer ltf) async {
    int result;
    result = await helper.updatelyric(ltf);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
                icon: const Icon(Icons.skip_previous), onPressed: _toggleStart),
            IconButton(
                icon: const Icon(Icons.add), onPressed: _incrementCounter),
            IconButton(
                icon: const Icon(Icons.line_weight), onPressed: _cycleXes),
            IconButton(
                icon: const Icon(Icons.remove), onPressed: _decrementCounter),
            IconButton(
                icon: const Icon(Icons.skip_next), onPressed: _toggleEnd),
          ],
        ),
      ),
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return Constants.choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
        title: Text(widget.ltf.title()),
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
                        ? widget.ltf.lyrics()
                        : widget.ltf.transformed(),
                    style: GoogleFonts.getFont(_selectedFont,
                        color: Colors.black, fontSize: 14.0))),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showlyrics,
        tooltip: 'show/hide',
        child: isvisible
            ? const Icon(Icons.visibility_off)
            : const Icon(Icons.visibility),
      ), // This trailing comma makies auto-formatting nicer for build methods.
    );
  }
}
