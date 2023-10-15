import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ElevatedAutoLoadingButton extends StatefulWidget {
  const ElevatedAutoLoadingButton({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.statesController,
    this.loadingIcon,
    this.loadingLabel,
    this.switchDuration = kThemeAnimationDuration,
    required this.child,
  });

  ElevatedAutoLoadingButton.icon({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    bool? autofocus,
    Clip? clipBehavior,
    this.statesController,
    this.loadingIcon,
    this.loadingLabel,
    Duration? switchDuration,
    required Widget icon,
    required Widget label,
  })  : autofocus = autofocus ?? false,
        clipBehavior = clipBehavior ?? Clip.none,
        switchDuration = switchDuration ?? kThemeAnimationDuration,
        child = _ButtonWithIconChild(label: label, icon: icon);

  final AsyncCallback? onPressed;
  final AsyncCallback? onLongPress;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocusChange;
  final ButtonStyle? style;
  final Clip clipBehavior;
  final FocusNode? focusNode;
  final bool autofocus;
  final MaterialStatesController? statesController;
  final Widget? child;
  final Widget? loadingIcon;
  final Widget? loadingLabel;
  final Duration switchDuration;

  @override
  State createState() => _ElevatedAutoLoadingButtonState();
}

class _ElevatedAutoLoadingButtonState extends AutoLoadingButtonState<ElevatedAutoLoadingButton> {
  @override
  AsyncCallback? get _onPressed => widget.onPressed;

  @override
  AsyncCallback? get _onLongPress => widget.onLongPress;

  @override
  Widget build(BuildContext context) {
    return ElevatedLoadingButton(
      isLoading: _isLoading,
      onPressed: _wrapOnPressed(),
      onLongPress: _wrapOnLongPress(),
      onHover: widget.onHover,
      onFocusChange: widget.onFocusChange,
      style: widget.style,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      clipBehavior: widget.clipBehavior,
      statesController: widget.statesController,
      loadingIcon: widget.loadingIcon,
      loadingLabel: widget.loadingLabel,
      loadingPressable: false,
      switchDuration: widget.switchDuration,
      child: widget.child,
    );
  }
}

class ElevatedLoadingButton extends ElevatedButton {
  ElevatedLoadingButton({
    super.key,
    required bool isLoading,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.clipBehavior = Clip.none,
    super.statesController,
    bool loadingPressable = false,
    Duration switchDuration = kThemeAnimationDuration,
    Widget? loadingIcon,
    Widget? loadingLabel,
    required Widget? child,
  }) : super(
          onPressed: isLoading && !loadingPressable ? null : onPressed,
          onLongPress: isLoading && !loadingPressable ? null : onLongPress,
          child: AnimatedSize(
            duration: switchDuration,
            child: !isLoading
                ? child
                : loadingLabel == null
                    ? loadingIcon ?? const _LoadingChild()
                    : _ButtonWithIconChild(
                        icon: loadingIcon ?? const _LoadingChild(),
                        label: loadingLabel,
                      ),
          ),
        );

  ElevatedLoadingButton.icon({
    super.key,
    required bool isLoading,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    bool? autofocus,
    Clip? clipBehavior,
    super.statesController,
    Widget? loadingIcon,
    Widget? loadingLabel,
    bool loadingPressable = false,
    Duration switchDuration = kThemeAnimationDuration,
    required Widget icon,
    required Widget label,
  }) : super(
          autofocus: autofocus ?? false,
          clipBehavior: clipBehavior ?? Clip.none,
          onPressed: isLoading && !loadingPressable ? null : onPressed,
          onLongPress: isLoading && !loadingPressable ? null : onLongPress,
          child: AnimatedSize(
            duration: switchDuration,
            child: !isLoading
                ? _ButtonWithIconChild(icon: icon, label: label)
                : loadingLabel == null
                    ? loadingIcon ?? const _LoadingChild()
                    : _ButtonWithIconChild(
                        icon: loadingIcon ?? const _LoadingChild(),
                        label: loadingLabel,
                      ),
          ),
        );

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    if ((child as AnimatedSize).child is! _ButtonWithIconChild) {
      return super.defaultStyleOf(context);
    }

    final EdgeInsetsGeometry scaledPadding = ButtonStyleButton.scaledPadding(
      const EdgeInsetsDirectional.fromSTEB(12, 0, 16, 0),
      const EdgeInsets.symmetric(horizontal: 8),
      const EdgeInsetsDirectional.fromSTEB(8, 0, 4, 0),
      MediaQuery.maybeOf(context)?.textScaleFactor ?? 1,
    );
    return super.defaultStyleOf(context).copyWith(
          padding: MaterialStatePropertyAll<EdgeInsetsGeometry>(scaledPadding),
        );
  }
}

abstract class AutoLoadingButtonState<T extends StatefulWidget> extends State<T> {
  Future<void> doPress() {
    if (_onPressedFuture != null) {
      return _onPressedFuture!;
    }

    final onPressed = _onPressed;

    if (onPressed == null) {
      return Future.value();
    }

    final completer = Completer<void>();

    setState(() {
      _onPressedFuture = completer.future;
    });

    onPressed().then((value) {
      _onPressedFuture = null;
      completer.complete();

      if (mounted) {
        setState(() {});
      }
    });

    return completer.future;
  }

  Future<void> doLongPress() {
    if (_onLongPressFuture != null) {
      return _onLongPressFuture!;
    }

    final onPressed = _onLongPress;

    if (onPressed == null) {
      return Future.value();
    }

    final completer = Completer<void>();

    setState(() {
      _onLongPressFuture = completer.future;
    });

    onPressed().then((value) {
      _onLongPressFuture = null;
      completer.complete();

      if (mounted) {
        setState(() {});
      }
    });

    return completer.future;
  }

  bool get _isLoading => _onPressedFuture != null || _onLongPressFuture != null;
  Future<void>? _onPressedFuture;
  Future<void>? _onLongPressFuture;

  AsyncCallback? get _onPressed;

  AsyncCallback? get _onLongPress;

  VoidCallback? _wrapOnPressed() {
    return _onPressed == null ? null : doPress;
  }

  VoidCallback? _wrapOnLongPress() {
    return _onLongPress == null ? null : doLongPress;
  }
}

class _ButtonWithIconChild extends StatelessWidget {
  const _ButtonWithIconChild({Key? key, required this.label, required this.icon}) : super(key: key);

  final Widget label;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.maybeOf(context)?.textScaleFactor ?? 1;
    final double gap = scale <= 1 ? 8 : lerpDouble(8, 4, min(scale - 1, 1))!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[icon, SizedBox(width: gap), Flexible(child: label)],
    );
  }
}

class _LoadingChild extends StatelessWidget {
  const _LoadingChild({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    Widget result = const CircularProgressIndicator(
      strokeWidth: 2,
    );

    result = Padding(
      padding: const EdgeInsets.all(2),
      child: result,
    );

    result = SizedBox.square(
      dimension: iconTheme.size ?? 24,
      child: result,
    );

    return result;
  }
}
