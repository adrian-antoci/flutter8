import 'package:flutter/material.dart';

double _space = 8;

class Spacer0 extends StatelessWidget {
  const Spacer0({super.key});

  @override
  Widget build(BuildContext context) => SizedBox.square(dimension: _space);
}

class Spacer1 extends StatelessWidget {
  const Spacer1({super.key});

  @override
  Widget build(BuildContext context) => SizedBox.square(dimension: _space * 2);
}

class Spacer2 extends StatelessWidget {
  const Spacer2({super.key});

  @override
  Widget build(BuildContext context) => SizedBox.square(dimension: _space * 4);
}
