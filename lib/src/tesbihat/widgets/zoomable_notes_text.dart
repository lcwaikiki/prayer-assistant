import 'package:flutter/material.dart';

/// Selectable, scrollable notes text. When [zoomable], a two-finger pinch
/// scales the font size so the text reflows instead of being magnified.
///
/// Pointers are tracked with a [Listener], which stays out of the gesture
/// arena, so one-finger scrolling and text selection keep working.
class ZoomableNotesText extends StatefulWidget {
  const ZoomableNotesText({
    super.key,
    required this.text,
    required this.style,
    this.zoomable = true,
    this.textKey,
  });

  final String text;
  final TextStyle? style;
  final bool zoomable;
  final Key? textKey;

  @override
  State<ZoomableNotesText> createState() => _ZoomableNotesTextState();
}

class _ZoomableNotesTextState extends State<ZoomableNotesText> {
  static const _minScale = 0.8;
  static const _maxScale = 3.0;

  final Map<int, Offset> _pointers = {};
  double _scale = 1.0;
  double _pinchStartScale = 1.0;
  double? _pinchStartDistance;

  double get _pointerDistance {
    final positions = _pointers.values.toList();
    return (positions[0] - positions[1]).distance;
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointers[event.pointer] = event.position;
    if (_pointers.length == 2) {
      _pinchStartDistance = _pointerDistance;
      _pinchStartScale = _scale;
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_pointers.containsKey(event.pointer)) return;
    _pointers[event.pointer] = event.position;
    final startDistance = _pinchStartDistance;
    if (_pointers.length != 2 || startDistance == null || startDistance == 0) {
      return;
    }
    final scale = (_pinchStartScale * _pointerDistance / startDistance).clamp(
      _minScale,
      _maxScale,
    );
    if (scale != _scale) setState(() => _scale = scale);
  }

  void _onPointerEnd(PointerEvent event) {
    _pointers.remove(event.pointer);
    if (_pointers.length < 2) _pinchStartDistance = null;
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? DefaultTextStyle.of(context).style;
    final fontSize = (style.fontSize ?? 14) * (widget.zoomable ? _scale : 1);
    return Listener(
      onPointerDown: widget.zoomable ? _onPointerDown : null,
      onPointerMove: widget.zoomable ? _onPointerMove : null,
      onPointerUp: widget.zoomable ? _onPointerEnd : null,
      onPointerCancel: widget.zoomable ? _onPointerEnd : null,
      child: SingleChildScrollView(
        child: SelectableText(
          widget.text,
          key: widget.textKey,
          style: style.copyWith(fontSize: fontSize),
        ),
      ),
    );
  }
}
