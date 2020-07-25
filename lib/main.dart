import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:paymint/models/models.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:paymint/services/services.dart';
import 'route_generator.dart';

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

  final mscData = await Hive.openBox('miscellaneous');
  if (mscData.isEmpty) {
    mscData.put('first_launch', true);
  }
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

class MaterialAppWithTheme extends StatelessWidget {
  const MaterialAppWithTheme({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paymint',
      onGenerateRoute: RouteGenerator.generateRoute,
      theme: ThemeData(
          textTheme: GoogleFonts.rubikTextTheme(Theme.of(context).textTheme),
          primarySwatch: Colors.blue,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
            },
          )),
      home: InitView(),
    );
  }
}

/// The initView
class InitView extends StatefulWidget {
  const InitView({Key key}) : super(key: key);

  @override
  _InitViewState createState() => _InitViewState();
}

class _InitViewState extends State<InitView> {
  bool _isFirstLaunch;

  _checkFirstLaunch() async {
    final mscData = await Hive.openBox('miscellaneous');
    _isFirstLaunch = mscData.get('first_launch');
    print(_isFirstLaunch);
    if (this._isFirstLaunch == false) {
      Navigator.pushNamed(context, '/lockscreen');
    } else {
      await Future.delayed(Duration(milliseconds: 1000));
      Navigator.pushNamed(context, '/onboard');
    }
  }

  @override
  void initState() {
    this._checkFirstLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black, body: _buildLoading(context));
  }
}

Widget _buildLoading(BuildContext context) {
  return Center(
    child: Container(
      width: MediaQuery.of(context).size.width / 2,
      child: LinearProgressIndicator(),
    ),
  );
}
