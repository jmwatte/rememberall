//import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'editorscreen.dart';
import 'songlist_screen.dart';
//import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
//import 'dart:async' show Future;
//import 'package:flutter/services.dart' show rootBundle;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // GoogleFonts.config.allowRuntimeFetching = false;
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: ThemeData.light().textTheme.apply(
              fontFamily: 'Roboto Mono',
            ),
      ),
      routes: {
        EditorScreen.routeName: (context) => EditorScreen(),
      },
      home: const MySongList(),
    );
  }
}

/* class MySongList extends StatefulWidget {
  MySongList({
    Key key,
  }) : super(key: key);

  @override
  _MySongList createState() => _MySongList();
}

class _MySongList extends State<MySongList> {
  static var pieces = catchSong.allMatches(songslist);
  var songpieces =
      pieces.map((e) => LyricsTransformer()..input = e.group(0)).toList();
  //final items = List<String>.generate(10000, (i) => "Item $i");

  //  List<String> getList() {
  //   //var f = File(r'assets/songsheets.txt');
  //   //var songs = f.readAsStringSync();
  //   return catchSong.allMatches(songslist).map((element) {
  //     LyricsTransformer()..input = element.group(0);
  //   }).toList();
  //}
 void choiceAction(String choice) {
    if (choice == Constants.Save) {
     // _navigateAndDisplaySelection(context);
      print('save');
    } else if (choice == Constants.Import) {
      print('import');
    } else if (choice == Constants.ToArchive) {
    //  _openeditor(context, widget.ltf);
      print('archiveren');
    } else if (choice == Constants.New) {
      _openeditor(context,new LyricsTransformer()..input='tik/paste hier je lyrics.titel in ALLCAPS',
      );
print('new');
    }
  }
_openeditor(BuildContext context, LyricsTransformer input) async {
    final result = await Navigator.pushNamed(context, EditorScreen.routeName,
        arguments: input);
    print('resukltaat:' + result.toString());
    setState(() {
      songpieces.add(LyricsTransformer()..input= result);
     // widget.ltf.input = result;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Songlist"),
         actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return Constants.listChoices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],





        ),
        body:(
          AlphabetListScrollView(
            indexedHeight: (i) {
              return 80;
            },
            strList:songpieces.map((e) => e.title()).toList() ,
         highlightTextStyle: TextStyle(
           color: Colors.yellow,
         ),
         // itemCount: songpieces.length,
          itemBuilder: (context, index) {
            return Column(children: <Widget>[
              ListTile(
                leading: Text(index.toString()+'.'),
                title: Text('${songpieces[index].title()}'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MyHomePage(
                                title: songpieces[index].title(),
                                ltf: songpieces[index],
                              )));
                },
              ),
              Divider(),
            ]);
          },
        )));
  }
}
 */
/* class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.ltf}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

// Try reading data from the counter key. If it doesn't exist, return 0.

  final String title;
  final LyricsTransformer ltf;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _loadBlokker();
  }

  _loadBlokker() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      widget.ltf.blokker = (prefs.getString('blokker') ?? "x");
    });
  }

  // LyricsTransformer ltf2 = LyricsTransformer()
  //   ..input = testLyrics
  //   ..blokker = '_';

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      //ltf2.input = testLyrics;
      //widget.ltf.input = testLyrics;
      widget.ltf.extraVisibleWords = _counter;
    });
  }

  void choiceAction(String choice) {
    if (choice == Constants.Blokker) {
      _navigateAndDisplaySelection(context);
      print('blokker');
    } else if (choice == Constants.Font) {
      print('font');
    } else if (choice == Constants.Edit) {
      _openeditor(context, widget.ltf);
      print('edit');
    } else if (choice == Constants.New) {
      _openNeweditor(context);
    }
  }

  _openeditor(BuildContext context, LyricsTransformer input) async {
    final result = await Navigator.pushNamed(context, EditorScreen.routeName,
        arguments: input);
    print('resukltaat:' + result.toString());
    setState(() {
      widget.ltf.input = result;
    });
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

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.skip_previous), onPressed: _toggleStart),
            IconButton(icon: Icon(Icons.add), onPressed: _incrementCounter),
            IconButton(icon: Icon(Icons.line_weight), onPressed: _cycleXes),
            IconButton(icon: Icon(Icons.remove), onPressed: _decrementCounter),
            IconButton(icon: Icon(Icons.skip_next), onPressed: _toggleEnd),
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
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.ltf.title()),
        automaticallyImplyLeading: true,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,

          children: <Widget>[

            RichText(

                text: TextSpan(
              text: isvisible ? widget.ltf.lyrics() : widget.ltf.transformed(),
              style: TextStyle(color: Colors.black, fontSize: 14.0),
            )),
            /* Text(
                          '$_counter',
                          style: Theme.of(context).textTheme.headline4,
                         )*/
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showlyrics,
        tooltip: 'show/hide',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
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

  var cycler = 0;
  void _cycleXes() {
    setState(() {
      cycler++;
      if (cycler > 2) {
        cycler = 0;
      }
      switch (cycler) {
        case 0:
          widget.ltf.scramble = scramblemethod.xForAll;
          break;
        case 1:
          widget.ltf.scramble = scramblemethod.xForConsonants;
          break;
        case 2:
          widget.ltf.scramble = scramblemethod.xForVowels;
          break;
        default:
      }
    });
  }

  bool isvisible = false;
  void _showlyrics() {
    setState(() {
      isvisible = !isvisible;
    });
  }

  void _openNeweditor(BuildContext context) {}
}
 */
