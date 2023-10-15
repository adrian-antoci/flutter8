import 'package:flutter/material.dart';

import 'colors.dart';

ThemeData appTheme(BuildContext context) => ThemeData(
    scaffoldBackgroundColor: backgroundColor,
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: Colors.pinkAccent),
    appBarTheme: Theme.of(context).appBarTheme.copyWith(
        elevation: 0,
        iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.white),
        color: backgroundColor,
        surfaceTintColor: Colors.transparent),
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
    iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.white),
    textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
    useMaterial3: true);
