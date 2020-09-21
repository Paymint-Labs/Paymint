import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/pages.dart';
import 'package:paymint/models/models.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:paymint/services/services.dart';
import 'route_generator.dart';
import 'package:flutter/services.dart';

// main() is the entry point to the app. It initializes Hive (local database),
// runs the MyApp widget and checks for new users, caching the value in the
// miscellaneous box for later use
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDirectory = await path.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDirectory.path);

  // Registering Transaction Model Adapters
  Hive.registerAdapter(TransactionDataAdapter());
  Hive.registerAdapter(TransactionChunkAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(InputAdapter());
  Hive.registerAdapter(OutputAdapter());

  // Registering Utxo Model Adapters
  Hive.registerAdapter(UtxoDataAdapter());
  Hive.registerAdapter(UtxoObjectAdapter());
  Hive.registerAdapter(StatusAdapter());

  runApp(MyApp());
}

/// MyApp initialises relevant services with a MultiProvider
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BitcoinService(),
        )
      ],
      child: MaterialAppWithTheme(),
    );
  }
}

// Sidenote: MaterialAppWithTheme and InitView are only separated for clarity. No other reason.

class MaterialAppWithTheme extends StatefulWidget {
  const MaterialAppWithTheme({
    Key key,
  }) : super(key: key);

  @override
  _MaterialAppWithThemeState createState() => _MaterialAppWithThemeState();
}

class _MaterialAppWithThemeState extends State<MaterialAppWithTheme> {
  @override
  void initState() {
    super.initState();
  }

  /// Returns true if the user has never setup the PIN code before, returns false otherwise
  Future<bool> checkForLockscreen() async {
    final misc = await Hive.openBox('miscellaneous_v2');

    if (misc.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paymint',
      onGenerateRoute: RouteGenerator.generateRoute,
      theme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.rubikTextTheme(),
        primaryColor: Colors.cyan,
        accentColor: Colors.cyanAccent,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          color: Color(0xff121212),
          elevation: 0,
        ),
      ),
      home: FutureBuilder(
        future: checkForLockscreen(),
        builder: (BuildContext context, AsyncSnapshot<bool> shouldRouteToLockSetup) {
          if (shouldRouteToLockSetup.connectionState == ConnectionState.done) {
            if (shouldRouteToLockSetup.data) {
              return SetUpLockscreenView();
            } else {
              return LockscreenView();
            }
          } else {
            return buildLoadingView();
          }
        },
      ),
    );
  }
}

Widget buildLoadingView() {
  return Scaffold(
    body: Container(
      color: Color(0xff121212),
      child: Center(
        child: Image.asset(
          'assets/images/splash.png',
          height: 125,
        ),
      ),
    ),
  );
}
