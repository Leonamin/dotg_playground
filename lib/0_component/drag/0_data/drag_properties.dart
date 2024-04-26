enum DragZoomType {
  zoomIn,
  zoomOut,
}

// zoom 관련 클래스
class DragZoomProperties {
  final DragZoomType type;

  /// 본 크기로부터 확대/축소 비율
  final double scaleLimit;

  /// 최대로 확대/축소되는 지점
  final double dragThreshold;

  DragZoomProperties({
    required this.type,
    required this.scaleLimit,
    required this.dragThreshold,
  });
}

/// 드래그 방향
/// [up] : 위로 드래그
/// [down] : 아래로 드래그
/// [left] : 왼쪽으로 드래그
/// [right] : 오른쪽으로 드래그
enum DragDirection {
  up,
  down,
  left,
  right,
}

class DragMoveProperties {
  /// 드래그 방향
  final DragDirection direction;

  /// 최대로 드래그되는 지점
  final double dragThreshold;

  DragMoveProperties({
    this.direction = DragDirection.down,
    required this.dragThreshold,
  });
}

enum DragAxis {
  empty,
  vertical,
  horizontal,
}
