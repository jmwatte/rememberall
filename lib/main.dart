//import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rememberall2/blokkerscreen_logic.dart';
import 'package:rememberall2/helpers.dart';
import 'package:rememberall2/poem_screen_logic.dart';
import 'package:rememberall2/poems_screen.dart';
import 'package:rememberall2/poems_screen_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/watch_it.dart';
import 'editorscreen.dart';

//import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
//import 'dart:async' show Future;
//import 'package:flutter/services.dart' show rootBundle;
bool isDebugMode = false;
bool isFirstRun = true;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setup();
  assert(() {
    isDebugMode = true;
    return true;
  }());
  runApp(const MyApp());
}

void setup() {
  di.registerLazySingleton<PoemScreenLogic>(() => PoemScreenLogic());
  di.registerLazySingleton<PoemsScreenLogic>(() => PoemsScreenLogic());
  di.registerLazySingleton<BlokkerScreenLogic>(() => BlokkerScreenLogic());
  SharedPreferences.getInstance().then((prefs) {
    isFirstRun = prefs.getBool('isFirstRun') ?? true;
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // final songScreenLogic = di.get<SongScreenLogic>();
    // GoogleFonts.config.allowRuntimeFetching = false;
    return MaterialApp(
      // showPerformanceOverlay: true,
      debugShowCheckedModeBanner: false,
      title: 'Rememberall',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: ThemeData.light().textTheme.apply(
              fontFamily: 'Roboto Mono',
            ),
      ),
      routes: {
        EditorScreen.routeName: (context) => EditorScreen(),
      },
      home: isFirstRun ? const FirstRunScreen() : const MyPoems(),
    );
  }
}
