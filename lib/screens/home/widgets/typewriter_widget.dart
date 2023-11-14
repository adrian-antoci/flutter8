import 'package:flutter/material.dart';

class TypeWriterTextWidget extends StatefulWidget {
  const TypeWriterTextWidget(
    this.data, {
    Key? key,
    required this.builder,
    required this.controller,
  }) : super(key: key);

  final String data;
  final Widget Function(BuildContext context, String value)? builder;
  final TypeWriterController controller;

  @override
  State<TypeWriterTextWidget> createState() => _TypeWriterTextWidgetState();
}

class _TypeWriterTextWidgetState extends State<TypeWriterTextWidget> {
  @override
  void initState() {
    widget.controller.isPlaying.addListener(() {
      if (widget.controller.isPlaying.value) {
        widget.controller.isPaused = false;
        widget.controller.run();
      } else {
        widget.controller.isPaused = true;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller.tick,
      builder: (context, value, child) {
        return widget.builder!(
          context,
          "${widget.data.substring(0, widget.controller.tick.value)}${widget.controller.progress.value == 100 ? "" : "|"}\n",
        );
      },
    );
  }
}

class TypeWriterController {
  TypeWriterController(this.dataLength);

  final int dataLength;

  ValueNotifier<int> progress = ValueNotifier(0);
  ValueNotifier<bool> isPlaying = ValueNotifier(false);
  ValueNotifier<int> tick = ValueNotifier(0);

  bool isPaused = true;

  void playPause() {
    isPlaying.value = !isPlaying.value;
  }

  void seekTo(double seek) {
    var value = (seek * dataLength) ~/ 100;
    if (value > dataLength) {
      value = dataLength;
    }
    tick.value = value;

    progress.value = tick.value * 100 ~/ dataLength;
    run();
  }

  void run() {
    Future.delayed(const Duration(milliseconds: 40), () {
      if (tick.value <= dataLength && !isPaused) {
        if (tick.value >= dataLength) {
          tick.value = dataLength;
          isPlaying.value = false;
          progress.value = 100;
          return;
        }
        tick.value++;
        progress.value = tick.value * 100 ~/ dataLength;
        run();
      }
    });
  }
}
