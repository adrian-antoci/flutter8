import 'package:flutter/material.dart';
import 'package:flutter8/theme/code_highlighter.dart';
import 'package:flutter8/routing.dart';
import 'package:flutter8/theme/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "env/default.env");
  await GoogleFonts.pendingFonts([
    GoogleFonts.inter(),
    GoogleFonts.roboto(),
  ]);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await CodeHighlighter().init();

  runApp(MyApp(prefs));
}

class MyApp extends StatelessWidget {
  const MyApp(this.sharedPrefs, {super.key});

  final SharedPreferences sharedPrefs;

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routerConfig: routerConfig(
          context: context,
          sharedPrefs: sharedPrefs,
        ),
        title: 'Flutter8',
        theme: appTheme(context),
      );
}
