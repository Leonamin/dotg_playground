import 'package:flutter/material.dart';

/// 위젯을 아래로 드래그하면 이벤트를 발생시키고 실제로 드래그 효과 표시
class DragActionWidget extends StatefulWidget {
  /// 위젯 드래그 액션이 발동하는 지점 및 UI가 최대로 표시되는 지점
  final double? dragActionThreshold;
  final bool enableWidgetDrag;

  final VoidCallback? onDragEnd;

  /// 위젯은 무조건 사이즈를 명시적으로 가지고 있어야합니다.
  final Widget child;

  const DragActionWidget({
    super.key,
    this.dragActionThreshold,
    this.enableWidgetDrag = true,
    this.onDragEnd,
    required this.child,
  });

  @override
  State<DragActionWidget> createState() => _DragActionWidgetState();
}

class _DragActionWidgetState extends State<DragActionWidget> {
  double dragActionThreshold = 0.0;

  double get defaultDragActionThreshold =>
      MediaQuery.of(context).size.height / 3;

  double dragStartPos = 0.0;
  double dragRange = 0.0;
  double videoPostion = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DragActionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.dragActionThreshold != oldWidget.dragActionThreshold) {
      dragActionThreshold =
          widget.dragActionThreshold ?? defaultDragActionThreshold;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.dragActionThreshold != null) {
      dragActionThreshold = widget.dragActionThreshold!;
    } else {
      /// 3분의 일
      dragActionThreshold = defaultDragActionThreshold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragCancel: _onVerticalDragCancel,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: Stack(
        children: [
          Positioned(
            top: widget.enableWidgetDrag ? videoPostion : 0,
            child: widget.child,
          ),
        ],
      ),
    );
  }

  void _onVerticalDragStart(DragStartDetails details) {
    dragStartPos = details.globalPosition.dy;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      dragRange = details.globalPosition.dy - dragStartPos;

      if (dragRange > dragActionThreshold) {
        videoPostion = dragActionThreshold;
      } else if (dragRange < 0) {
        videoPostion = 0;
      } else {
        videoPostion = dragRange;
      }
    });
  }

  void _onVerticalDragCancel() {
    _resetDrag();
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (dragRange > dragActionThreshold) {
      widget.onDragEnd?.call();
    }

    _resetDrag();
  }

  void _resetDrag() {
    setState(() {
      dragStartPos = 0;
      dragRange = 0;
      videoPostion = 0;
    });
  }
}
