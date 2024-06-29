import 'package:example/demos/example_editor/example_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:super_editor/super_editor.dart';

/// Demo of a basic text editor, as well as various widgets that
/// are available in this package.
Future<void> main() async {
  initLoggers(Level.FINE, {});

  runApp(SuperEditorDemoApp());
}

class SuperEditorDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Editor Demo App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: HomeScreen(),
      supportedLocales: const [
        Locale('en', ''),
        Locale('es', ''),
      ],
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Displays various demos that are selected from a list of
/// options in a drawer.
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // We need a FocusScope above the Overlay so that focus can be shared between
    // SuperEditor in one OverlayEntry, and the popover toolbar in another OverlayEntry.
    return FocusScope(
      // We need our own [Overlay] instead of the one created by the navigator
      // because overlay entries added to navigator's [Overlay] are always
      // displayed above all routes.
      //
      // We display the editor's toolbar in an [OverlayEntry], so inserting it
      // at the navigator's [Overlay] causes widgets that are displayed in routes,
      // e.g. [DropdownButton] items, to be displayed beneath the toolbar.
      child: Scaffold(
        key: _scaffoldKey,
        body: ExampleEditor(),
      ),
    );
  }
}
