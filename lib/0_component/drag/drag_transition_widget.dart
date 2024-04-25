import 'dart:math';

import 'package:dotg_playground/0_component/drag/0_data/drag_properties.dart';
import 'package:dotg_playground/0_component/scale_sized_box.dart';
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
  final DragZoomProperties? zoomUpToDown;

  /// 아래에서 위로 줌
  final DragZoomProperties? zoomDownToUp;

  /// 왼쪽에서 오른쪽으로 줌
  final DragZoomProperties? zoomLeftToRight;

  /// 오른쪽에서 왼쪽으로 줌
  final DragZoomProperties? zoomRightToLeft;

  DragZoomConfig({
    this.zoomUpToDown,
    this.zoomDownToUp,
    this.zoomLeftToRight,
    this.zoomRightToLeft,
  });
}

/// 위젯을 특정 방향으로 드래그
class DragTransitionWidget extends StatefulWidget {
  final DragZoomConfig? zoomConfig;
  final DragMoveConfig? moveConfig;

  final bool enableMove;
  final bool enableZoom;
  final Widget child;

  const DragTransitionWidget({
    super.key,
    this.moveConfig,
    this.zoomConfig,
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
      onVerticalDragEnd: (_) => _onDragCancel(),
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragCancel: _onDragCancel,
      onHorizontalDragEnd: (_) => _onDragCancel(),
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

  DragAxis _lastAxis = DragAxis.empty;

  /// 드래그 업데이트
  void _onDragUpdate(
    DragAxis axis,
    double position,
  ) {
    if (_lastAxis != axis) {
      _resetDrag();
      _lastAxis = axis;
      dragStartPos = position;
    }

    final dragDiff = position - dragStartPos;

    bool isPositive = dragDiff > 0;

    _actionDragEvent(dragDiff, isPositive);
  }

  void _actionDragEvent(double dragDiff, bool isPositive) {
    // 드래그 이벤트 방향과 드래그 거리 양수 음수로 방향 구분

    final dragRange = dragDiff.abs();

    late DragDirection direction;

    if (_lastAxis == DragAxis.vertical) {
      direction = isPositive ? DragDirection.down : DragDirection.up;
    } else {
      direction = isPositive ? DragDirection.right : DragDirection.left;
    }

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
                defaultDragMoveThreshold);
        break;
      case DragDirection.down:
        if (widget.moveConfig?.moveTopToBottom == null) return;
        _updatePosition(
            dragDirection,
            dragRange,
            widget.moveConfig?.moveTopToBottom?.dragThreshold ??
                defaultDragMoveThreshold);
        break;
      case DragDirection.left:
        if (widget.moveConfig?.moveRightToLeft == null) return;
        _updatePosition(
            dragDirection,
            dragRange,
            widget.moveConfig?.moveRightToLeft?.dragThreshold ??
                defaultDragMoveThreshold);
        break;
      case DragDirection.right:
        if (widget.moveConfig?.moveLeftToRight == null) return;
        _updatePosition(
            dragDirection,
            dragRange,
            widget.moveConfig?.moveLeftToRight?.dragThreshold ??
                defaultDragMoveThreshold);
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
          dragThreshold: defaultDragMoveThreshold,
        ),
        dragRange: dragRange,
      );
    });
  }

  void _processWidgetZoom(DragDirection dragDirection, double dragRange) {
    switch (dragDirection) {
      case DragDirection.up:
        if (widget.zoomConfig?.zoomDownToUp == null) return;
        _updateZoomScale(
            dragRange,
            widget.zoomConfig?.zoomDownToUp?.dragThreshold ??
                defaultDragZoomThreshold);
        break;
      case DragDirection.down:
        if (widget.zoomConfig?.zoomUpToDown == null) return;
        _updateZoomScale(
            dragRange,
            widget.zoomConfig?.zoomUpToDown?.dragThreshold ??
                defaultDragZoomThreshold);
        break;
      case DragDirection.left:
        if (widget.zoomConfig?.zoomRightToLeft == null) return;
        _updateZoomScale(
            dragRange,
            widget.zoomConfig?.zoomRightToLeft?.dragThreshold ??
                defaultDragZoomThreshold);
        break;
      case DragDirection.right:
        if (widget.zoomConfig?.zoomLeftToRight == null) return;
        _updateZoomScale(
            dragRange,
            widget.zoomConfig?.zoomLeftToRight?.dragThreshold ??
                defaultDragZoomThreshold);
        break;
    }
  }

  void _updateZoomScale(double dragRange, double zoomThreshold) {
    final zoomValue = min(dragRange, defaultDragZoomThreshold);

    setState(() {
      widgetSizeFactor = _getZoomValue(zoomValue, 0, zoomThreshold);
    });
  }

  double _getZoomValue(
    double value,
    double fromMin,
    double fromMax,
  ) {
    return (value - fromMin) / (fromMax - fromMin) * (1.0 - 0.0) + 0.0;
  }

  void _resetDrag() {
    _initDragProperties();
    _initPosition();
  }

  void _initDragProperties() {
    setState(() {
      _lastAxis = DragAxis.empty;
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
      return _WidgetPosition(bottom: 0);
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
        bottom = min(dragRange, moveProperties.dragThreshold);
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
