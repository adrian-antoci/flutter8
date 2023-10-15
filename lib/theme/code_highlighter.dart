import 'package:flutter/material.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

class CodeHighlighter {
  static final CodeHighlighter _instance = CodeHighlighter._internal();

  factory CodeHighlighter() {
    return _instance;
  }

  CodeHighlighter._internal();

  Highlighter? _highlighter;

  Future<void> init() async {
    await Highlighter.initialize(['dart']);
    var theme = await HighlighterTheme.loadDarkTheme();
    _highlighter ??= Highlighter(
      language: 'dart',
      theme: theme,
    );
  }

  TextSpan highlight(String text) => _highlighter!.highlight(text);
}
