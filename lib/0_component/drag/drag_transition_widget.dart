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

  const DragMoveConfig({
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

  const DragZoomConfig({
    this.zoomTopToBottom,
    this.zoomBottomToTop,
    this.zoomLeftToRight,
    this.zoomRightToLeft,
  });
}

/// 위젯을 특정 방향으로 드래그
class DragTransitionWidget extends StatefulWidget {
  final DragZoomConfig? zoomConfig;
  final DragMoveConfig? moveConfig;
  final List<DragEndEventConfig> dragEndEvents;

  final bool enableMove;
  final bool enableZoom;

  /// 사이즈 무조건 갖고 있을것
  final Widget child;

  const DragTransitionWidget({
    super.key,
    this.moveConfig,
    this.zoomConfig,
    this.dragEndEvents = const [],
    this.enableMove = true,
    this.enableZoom = true,
    required this.child,
  });

  @override
  State<DragTransitionWidget> createState() => _DragTransitionWidgetState();
}

class _DragTransitionWidgetState extends State<DragTransitionWidget> {
  /// 드래그 시작 위치
  double _initialDragPosition = 0.0;
  DragAxis _draggingAxis = DragAxis.empty;
  double _lastPosition = 0.0;

  _WidgetPosition widgetPosition = _WidgetPosition();

  double widgetSizeFactor = 1.0;

  double get defaultDragMoveThreshold => MediaQuery.of(context).size.height / 3;
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
      onLongPress: () {},
      onLongPressMoveUpdate: (details) {},
      child: Stack(
        children: [
          Positioned(
            top: widgetPosition.top,
            bottom: widgetPosition.bottom,
            left: widgetPosition.left,
            right: widgetPosition.right,
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
    _callEndEvents();

    _resetDrag();
  }

  void _callEndEvents() {
    if (widget.dragEndEvents.isEmpty) return;

    final dragDirection = _getDragDirection();
    final dragRange = (_lastPosition - _initialDragPosition).abs();

    final matchedEvents = widget.dragEndEvents
        .where((event) => event.direction == dragDirection)
        .where((event) => event.dragThreshold <= dragRange)
        .toList();

    for (final event in matchedEvents) {
      event.onDragEnd?.call();
    }
  }

  /// 드래그 업데이트
  void _onDragUpdate(
    DragAxis axis,
    double position,
  ) {
    if (_draggingAxis != axis) {
      _resetDrag();
      _draggingAxis = axis;
      _initialDragPosition = position;
    }
    _lastPosition = position;

    final dragDiff = _lastPosition - _initialDragPosition;

    _actionDragEvent(dragDiff);
  }

  DragDirection _getDragDirection() {
    final dragDiff = _lastPosition - _initialDragPosition;

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
    DragMoveProperties? properties =
        _getMovePropertiesForDirection(dragDirection);
    if (properties == null) return;

    double dragThreshold = properties.dragThreshold;
    _updatePosition(dragDirection, dragRange, dragThreshold);
  }

  DragMoveProperties? _getMovePropertiesForDirection(DragDirection direction) {
    switch (direction) {
      case DragDirection.up:
        return widget.moveConfig?.moveBottomToTop;
      case DragDirection.down:
        return widget.moveConfig?.moveTopToBottom;
      case DragDirection.left:
        return widget.moveConfig?.moveRightToLeft;
      case DragDirection.right:
        return widget.moveConfig?.moveLeftToRight;
    }
  }

  void _updatePosition(
    DragDirection dragDirection,
    double dragRange,
    double dragThreshold,
  ) {
    setState(() {
      widgetPosition = _WidgetPosition.onDrag(
        dragDirection: dragDirection,
        moveProperties: DragMoveProperties(dragThreshold: dragThreshold),
        dragRange: dragRange,
      );
    });
  }

  void _processWidgetZoom(DragDirection dragDirection, double dragRange) {
    if (!widget.enableZoom) return;

    DragZoomProperties? properties =
        _getZoomPropertiesForDirection(dragDirection);

    if (properties == null) return;

    double dragThreshold = properties.dragThreshold;

    _updateZoomScale(
      properties.type,
      dragRange,
      dragThreshold,
      properties.scaleLimit,
    );
  }

  DragZoomProperties? _getZoomPropertiesForDirection(DragDirection direction) {
    switch (direction) {
      case DragDirection.up:
        return widget.zoomConfig?.zoomBottomToTop;
      case DragDirection.down:
        return widget.zoomConfig?.zoomTopToBottom;
      case DragDirection.left:
        return widget.zoomConfig?.zoomRightToLeft;
      case DragDirection.right:
        return widget.zoomConfig?.zoomLeftToRight;
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
      _initialDragPosition = 0;
    });
  }

  void _initPosition() {
    setState(() {
      widgetPosition = _WidgetPosition.initFromConfig(
        moveConfig: widget.moveConfig,
      );
      widgetSizeFactor = 1.0;
    });
  }
}

class _WidgetPosition {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const _WidgetPosition({
    this.top = 0.0,
    this.bottom,
    this.left,
    this.right,
  });

  factory _WidgetPosition.initFromConfig({
    DragMoveConfig? moveConfig,
  }) {
    if (moveConfig == null) {
      return const _WidgetPosition(top: 0);
    }

    if (moveConfig.moveBottomToTop == null &&
        moveConfig.moveTopToBottom == null &&
        moveConfig.moveLeftToRight == null &&
        moveConfig.moveRightToLeft == null) {
      return const _WidgetPosition(top: 0);
    }

    if (moveConfig.moveTopToBottom != null) {
      return const _WidgetPosition(top: 0);
    }

    if (moveConfig.moveBottomToTop != null) {
      return const _WidgetPosition(top: 0);
    }

    if (moveConfig.moveLeftToRight != null) {
      return const _WidgetPosition(left: 0);
    }

    if (moveConfig.moveRightToLeft != null) {
      return const _WidgetPosition(right: 0);
    }

    return const _WidgetPosition(top: 0);
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
