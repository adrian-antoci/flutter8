import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TitleText extends StatelessWidget {
  const TitleText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 22),
      );
}

class AppBarText extends StatelessWidget {
  const AppBarText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style:
            GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.white),
      );
}
