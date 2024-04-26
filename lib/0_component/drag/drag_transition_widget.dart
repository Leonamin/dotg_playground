import 'dart:math';

import 'package:dotg_playground/0_component/drag/0_data/drag_properties.dart';
import 'package:flutter/material.dart';

class DragMoveConfig {
  /// 위에서 아래로 드래그
  final DragMoveProperties? moveTopToBottom;

  /// 아래에서 위로 드래그
  final DragMoveProperties? moveBottomToTop;

  /// 왼쪽에서 오른쪽으로 드래그
  final DragMoveProperties? moveLeftToRight;

  /// 오른쪽에서 왼쪽으로 드래그
  final DragMoveProperties? moveRightToLeft;

  DragMoveConfig({
    this.moveTopToBottom,
    this.moveBottomToTop,
    this.moveLeftToRight,
    this.moveRightToLeft,
  });

  double? get topToBottomMoveThreshold => moveTopToBottom?.dragThreshold;

  double? get bottomToTopMoveThreshold => moveBottomToTop?.dragThreshold;

  double? get leftToRightMoveThreshold => moveLeftToRight?.dragThreshold;

  double? get rightToLeftMoveThreshold => moveRightToLeft?.dragThreshold;
}

class DragZoomConfig {
  /// 위에서 아래로 줌
  final DragZoomProperties? zoomTopToBottom;

  /// 아래에서 위로 줌
  final DragZoomProperties? zoomBottomToTop;

  /// 왼쪽에서 오른쪽으로 줌
  final DragZoomProperties? zoomLeftToRight;

  /// 오른쪽에서 왼쪽으로 줌
  final DragZoomProperties? zoomRightToLeft;

  DragZoomConfig({
    this.zoomTopToBottom,
    this.zoomBottomToTop,
    this.zoomLeftToRight,
    this.zoomRightToLeft,
  });
}

/// 잘못만듦
class DragEndConfig {
  final DragEndProperties? endTopToBottom;
  final DragEndProperties? endBottomToTop;
  final DragEndProperties? endLeftToRight;
  final DragEndProperties? endRightToLeft;

  const DragEndConfig({
    this.endTopToBottom,
    this.endBottomToTop,
    this.endLeftToRight,
    this.endRightToLeft,
  });
}

/// 위젯을 특정 방향으로 드래그
class DragTransitionWidget extends StatefulWidget {
  final DragZoomConfig? zoomConfig;
  final DragMoveConfig? moveConfig;
  final DragEndConfig? endConfig;

  final bool enableMove;
  final bool enableZoom;
  final Widget child;

  const DragTransitionWidget({
    super.key,
    this.moveConfig,
    this.zoomConfig,
    this.endConfig,
    this.enableMove = true,
    this.enableZoom = true,
    required this.child,
  });

  @override
  State<DragTransitionWidget> createState() => _DragTransitionWidgetState();
}

class _DragTransitionWidgetState extends State<DragTransitionWidget> {
  /// 드래그 시작 위치
  double dragStartPos = 0.0;

  _WidgetPosition widgetPostion = _WidgetPosition();

  double widgetSizeFactor = 1.0;

  // double get dragMoveThreshold =>
  //     widget.moveConfig?.dragThreshold ?? defaultDragMoveThreshold;
  double get defaultDragMoveThreshold => MediaQuery.of(context).size.height / 3;

  // double get dragZoomThreshold =>
  //     widget.zoomConfig?.dragThreshold ?? defaultDragZoomThreshold;

  double get defaultDragZoomThreshold => MediaQuery.of(context).size.height / 6;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragCancel: _onDragCancel,
      onVerticalDragEnd: (_) => _onDragEnd(),
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragCancel: _onDragCancel,
      onHorizontalDragEnd: (_) => _onDragEnd(),
      child: Stack(
        children: [
          Positioned(
            top: widgetPostion.top,
            bottom: widgetPostion.bottom,
            left: widgetPostion.left,
            right: widgetPostion.right,
            child: Transform.scale(
              scale: widgetSizeFactor,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _onDragUpdate(DragAxis.vertical, details.globalPosition.dy);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    _onDragUpdate(DragAxis.vertical, details.globalPosition.dy);
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _onDragUpdate(DragAxis.horizontal, details.globalPosition.dx);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _onDragUpdate(DragAxis.horizontal, details.globalPosition.dx);
  }

  void _onDragCancel() {
    _resetDrag();
  }

  void _onDragEnd() {
    _processEndEvent();

    _resetDrag();
  }

  void _processEndEvent() {
    if (widget.endConfig == null) return;

    final dragDirection = _getDragDirection();
    final dragRange = (_lastPosition - dragStartPos).abs();

    switch (dragDirection) {
      case DragDirection.up:
        if (widget.endConfig!.endBottomToTop == null) return;

        final threshold = widget.endConfig!.endBottomToTop!.dragThreshold;

        if (dragRange >= threshold) {
          widget.endConfig!.endBottomToTop!.onDragEnd?.call();
        }
        break;
      case DragDirection.down:
        if (widget.endConfig!.endTopToBottom == null) return;

        final threshold = widget.endConfig!.endTopToBottom!.dragThreshold;

        if (dragRange >= threshold) {
          widget.endConfig!.endTopToBottom!.onDragEnd?.call();
        }

        break;
      case DragDirection.left:
        if (widget.endConfig!.endRightToLeft == null) return;

        final threshold = widget.endConfig!.endRightToLeft!.dragThreshold;

        if (dragRange >= threshold) {
          widget.endConfig!.endRightToLeft!.onDragEnd?.call();
        }
        break;
      case DragDirection.right:
        if (widget.endConfig!.endLeftToRight == null) return;

        final threshold = widget.endConfig!.endLeftToRight!.dragThreshold;

        if (dragRange >= threshold) {
          widget.endConfig!.endLeftToRight!.onDragEnd?.call();
        }
        break;
    }
  }

  DragAxis _draggingAxis = DragAxis.empty;
  double _lastPosition = 0.0;

  /// 드래그 업데이트
  void _onDragUpdate(
    DragAxis axis,
    double position,
  ) {
    if (_draggingAxis != axis) {
      _resetDrag();
      _draggingAxis = axis;
      dragStartPos = position;
    }
    _lastPosition = position;
    print('dragStartPos: $dragStartPos');

    final dragDiff = _lastPosition - dragStartPos;

    _actionDragEvent(dragDiff);
  }

  DragDirection _getDragDirection() {
    final dragDiff = _lastPosition - dragStartPos;

    bool isPositive = dragDiff > 0;

    if (_draggingAxis == DragAxis.vertical) {
      return isPositive ? DragDirection.down : DragDirection.up;
    } else {
      return isPositive ? DragDirection.right : DragDirection.left;
    }
  }

  void _actionDragEvent(double dragDiff) {
    // 드래그 이벤트 방향과 드래그 거리 양수 음수로 방향 구분

    final dragRange = dragDiff.abs();

    DragDirection direction = _getDragDirection();

    _processWidgetMove(direction, dragRange);
    _processWidgetZoom(direction, dragRange);
  }

  void _processWidgetMove(DragDirection dragDirection, double dragRange) {
    switch (dragDirection) {
      case DragDirection.up:
        if (widget.moveConfig?.moveBottomToTop == null) return;
        _updatePosition(
          dragDirection,
          dragRange,
          widget.moveConfig?.moveBottomToTop?.dragThreshold ??
              defaultDragMoveThreshold,
        );
        break;
      case DragDirection.down:
        if (widget.moveConfig?.moveTopToBottom == null) return;
        _updatePosition(
          dragDirection,
          dragRange,
          widget.moveConfig?.moveTopToBottom?.dragThreshold ??
              defaultDragMoveThreshold,
        );
        break;
      case DragDirection.left:
        if (widget.moveConfig?.moveRightToLeft == null) return;
        _updatePosition(
          dragDirection,
          dragRange,
          widget.moveConfig?.moveRightToLeft?.dragThreshold ??
              defaultDragMoveThreshold,
        );
        break;
      case DragDirection.right:
        if (widget.moveConfig?.moveLeftToRight == null) return;
        _updatePosition(
          dragDirection,
          dragRange,
          widget.moveConfig?.moveLeftToRight?.dragThreshold ??
              defaultDragMoveThreshold,
        );
        break;
    }
  }

  void _updatePosition(
    DragDirection dragDirection,
    double dragRange,
    double dragThreshold,
  ) {
    setState(() {
      widgetPostion = _WidgetPosition.onDrag(
        dragDirection: dragDirection,
        moveProperties: DragMoveProperties(
          dragThreshold: dragThreshold,
        ),
        dragRange: dragRange,
      );
    });
  }

  void _processWidgetZoom(DragDirection dragDirection, double dragRange) {
    switch (dragDirection) {
      case DragDirection.up:
        if (widget.zoomConfig?.zoomBottomToTop == null) return;
        _updateZoomScale(
          widget.zoomConfig!.zoomBottomToTop!.type,
          dragRange,
          widget.zoomConfig?.zoomBottomToTop?.dragThreshold ??
              defaultDragZoomThreshold,
          widget.zoomConfig!.zoomBottomToTop!.scaleLimit,
        );
        break;
      case DragDirection.down:
        if (widget.zoomConfig?.zoomTopToBottom == null) return;
        _updateZoomScale(
          widget.zoomConfig!.zoomTopToBottom!.type,
          dragRange,
          widget.zoomConfig?.zoomTopToBottom?.dragThreshold ??
              defaultDragZoomThreshold,
          widget.zoomConfig!.zoomTopToBottom!.scaleLimit,
        );
        break;
      case DragDirection.left:
        if (widget.zoomConfig?.zoomRightToLeft == null) return;
        _updateZoomScale(
          widget.zoomConfig!.zoomRightToLeft!.type,
          dragRange,
          widget.zoomConfig?.zoomRightToLeft?.dragThreshold ??
              defaultDragZoomThreshold,
          widget.zoomConfig!.zoomRightToLeft!.scaleLimit,
        );
        break;
      case DragDirection.right:
        if (widget.zoomConfig?.zoomLeftToRight == null) return;
        _updateZoomScale(
          widget.zoomConfig!.zoomLeftToRight!.type,
          dragRange,
          widget.zoomConfig?.zoomLeftToRight?.dragThreshold ??
              defaultDragZoomThreshold,
          widget.zoomConfig!.zoomLeftToRight!.scaleLimit,
        );
        break;
    }
  }

  void _updateZoomScale(
    DragZoomType zoomType,
    double dragRange,
    double zoomThreshold,
    double scaleLimit,
  ) {
    double limitDragRange = min(dragRange, defaultDragZoomThreshold);

    if (zoomType == DragZoomType.zoomIn) {
      limitDragRange = 1 + _getZoomValue(limitDragRange, 0, zoomThreshold);
      limitDragRange = min(scaleLimit, limitDragRange);
    } else {
      limitDragRange = 1 - _getZoomValue(limitDragRange, 0, zoomThreshold);
      limitDragRange = max(scaleLimit, limitDragRange);
    }

    setState(() {
      widgetSizeFactor = limitDragRange;
    });
  }

  /// [value]를 [fromMin], [fromMax]를 [toMin], [toMax] 비율로 맞춘 범위의 값으로 매핑
  double mapValue(
    double value,
    double fromMin,
    double fromMax,
    double toMin,
    double toMax,
  ) {
    return (value - fromMin) / (fromMax - fromMin) * (toMax - toMin) + toMin;
  }

  double _getZoomValue(
    double dragRange,
    double fromMin,
    double fromMax,
  ) {
    return mapValue(dragRange, fromMin, fromMax, 0, 1);
  }

  void _resetDrag() {
    _initDragProperties();
    _initPosition();
  }

  void _initDragProperties() {
    setState(() {
      _draggingAxis = DragAxis.empty;
      _lastPosition = 0;
      dragStartPos = 0;
    });
  }

  void _initPosition() {
    setState(() {
      widgetPostion = _WidgetPosition.initFromConfig(
        moveConfig: widget.moveConfig,
      );
      widgetSizeFactor = 1.0;
    });
  }
}

class _WidgetPosition {
  double? top;
  double? bottom;
  double? left;
  double? right;

  _WidgetPosition({
    this.top = 0.0,
    this.bottom,
    this.left,
    this.right,
  });

  factory _WidgetPosition.initFromConfig({
    DragMoveConfig? moveConfig,
  }) {
    if (moveConfig == null) {
      return _WidgetPosition(top: 0);
    }

    if (moveConfig.moveBottomToTop == null &&
        moveConfig.moveTopToBottom == null &&
        moveConfig.moveLeftToRight == null &&
        moveConfig.moveRightToLeft == null) {
      return _WidgetPosition(top: 0);
    }

    if (moveConfig.moveTopToBottom != null) {
      return _WidgetPosition(top: 0);
    }

    if (moveConfig.moveBottomToTop != null) {
      return _WidgetPosition(top: 0);
    }

    if (moveConfig.moveLeftToRight != null) {
      return _WidgetPosition(left: 0);
    }

    if (moveConfig.moveRightToLeft != null) {
      return _WidgetPosition(right: 0);
    }

    return _WidgetPosition(top: 0);
  }

  factory _WidgetPosition.onDrag({
    required DragDirection dragDirection,
    required DragMoveProperties moveProperties,
    required double dragRange,
  }) {
    double? top;
    double? bottom;
    double? left;
    double? right;
    switch (dragDirection) {
      case DragDirection.up:
        top = -min(dragRange, moveProperties.dragThreshold);
        break;
      case DragDirection.down:
        top = min(dragRange, moveProperties.dragThreshold);
        break;
      case DragDirection.left:
        right = min(dragRange, moveProperties.dragThreshold);
        break;
      case DragDirection.right:
        left = min(dragRange, moveProperties.dragThreshold);
        break;
    }
    return _WidgetPosition(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
    );
  }
}
