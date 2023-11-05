import 'package:flutter/material.dart';
import 'package:flutter8/services/models.dart';
import 'package:flutter8/theme/code_highlighter.dart';
import 'package:flutter8/theme/colors.dart';
import 'package:flutter8/theme/spacers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';

class PostCardWidget extends StatelessWidget {
  const PostCardWidget({
    super.key,
    required this.post,
    required this.onCopyCode,
  });

  final Post post;
  final Function() onCopyCode;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                    width: 50,
                    height: 50,
                    decoration: post.createdByAvatar.isEmpty
                        ? const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)
                        : BoxDecoration(
                            color: Colors.black,
                            image: DecorationImage(image: NetworkImage(post.createdByAvatar), fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(50),
                          ),
                    child: post.createdByAvatar.isEmpty
                        ? Center(
                            child: Text(post.createdByName.substring(0, 1), style: const TextStyle(fontSize: 18)),
                          )
                        : const SizedBox.shrink()),
                const Spacer0(),
                Text(
                  post.createdByName,
                  style: GoogleFonts.inter().copyWith(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              height: double.infinity,
              decoration: BoxDecoration(color: lightBackgroundColor),
              child: SelectionArea(
                child: _PostContentWidget(
                  post: post,
                  onCopyCode: onCopyCode,
                ),
              ),
            ),
          ),
        ],
      );
}

class _PostContentWidget extends StatefulWidget {
  const _PostContentWidget({
    required this.post,
    required this.onCopyCode,
  });

  final Post post;
  final Function() onCopyCode;

  @override
  State<_PostContentWidget> createState() => _PostContentWidgetState();
}

class _PostContentWidgetState extends State<_PostContentWidget> {
  final ScrollController _scrollController = ScrollController();
  late final _controller = TypeWriterController(widget.post.code.length);

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey(widget.post.id),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 1 && !_controller.isPlaying.value) {
          _controller.isPlaying.value = true;
        } else if (visibilityInfo.visibleFraction < 0.5 && _controller.isPlaying.value) {
          _controller.isPlaying.value = false;
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
                controller: _scrollController,
                child: _TypeWriterTextWidget(
                  widget.post.code,
                  controller: _controller,
                  builder: (context, value) {
                    if (value.length > 100 &&
                        _scrollController.hasClients &&
                        _scrollController.position.maxScrollExtent > 30) {
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) {
                          _scrollController.animateTo(_scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 150), curve: Curves.ease);
                        },
                      );
                    }
                    return Text.rich(
                      CodeHighlighter().highlight(value),
                      style: GoogleFonts.roboto(height: 1.5),
                    );
                  },
                )),
          ),
          Row(
            children: [
              _MediaControlWidget(_controller),
              Expanded(
                child: _SliderWidget(_controller),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                ),
                onPressed: () => widget.onCopyCode(),
                child: Text(
                  "${widget.post.copyCodeCount.toString()} · Copy code",
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MediaControlWidget extends StatefulWidget {
  const _MediaControlWidget(this.controller);

  final TypeWriterController controller;

  @override
  State<_MediaControlWidget> createState() => _MediaControlWidgetState();
}

class _MediaControlWidgetState extends State<_MediaControlWidget> {
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 30,
        height: 30,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(5),
            backgroundColor: Colors.white.withOpacity(0.4),
          ),
          onPressed: () {
            if (!widget.controller.isPlaying.value && widget.controller.progress.value == 100) {
              widget.controller.tick.value = 0;
              widget.controller.isPlaying.value = true;
              return;
            }
            widget.controller.isPlaying.value = !widget.controller.isPlaying.value;
          },
          child: ValueListenableBuilder(
              builder: (context, value, child) =>
                  Icon(!value ? Icons.play_arrow_rounded : Icons.pause, color: Colors.white, size: 16),
              valueListenable: widget.controller.isPlaying),
        ),
      );
}

class _SliderWidget extends StatefulWidget {
  const _SliderWidget(this.controller);

  final TypeWriterController controller;

  @override
  State<_SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<_SliderWidget> {
  bool pendingPlay = false;

  @override
  void initState() {
    super.initState();
    widget.controller.tick.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 1,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
        activeTrackColor: Colors.pink,
        inactiveTrackColor: Colors.white.withOpacity(0.1),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 15.0),
      ),
      child: Slider(
        value: widget.controller.progress.value.toDouble(),
        divisions: 100,
        max: 100,
        label: widget.controller.progress.value.toString(),
        onChangeEnd: (value) {
          if (pendingPlay && !widget.controller.isPlaying.value) {
            widget.controller.playPause();
          }
        },
        onChangeStart: (value) {
          if (widget.controller.isPlaying.value) {
            widget.controller.isPlaying.value = false;
            pendingPlay = true;
          }
        },
        onChanged: (double value) {
          widget.controller.seekTo(value);
          if (!mounted) return;
          setState(() {});
        },
      ),
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

class _TypeWriterTextWidget extends StatefulWidget {
  const _TypeWriterTextWidget(
    this.data, {
    Key? key,
    required this.builder,
    required this.controller,
  }) : super(key: key);

  final String data;
  final Widget Function(BuildContext context, String value)? builder;
  final TypeWriterController controller;

  @override
  State<_TypeWriterTextWidget> createState() => _TypeWriterTextWidgetState();
}

class _TypeWriterTextWidgetState extends State<_TypeWriterTextWidget> {
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
