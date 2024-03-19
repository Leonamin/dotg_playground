import 'package:flutter/material.dart';

mixin LoopingPageViewModel {
  late final PageController controller;

  static final _minDate = DateTime(2020, 1, 1);

  void initController(DateTime baseDate) {
    controller = PageController(
      initialPage: datetoPageIndex(baseDate),
    );
  }

  /// 페이지를 변경합니다
  /// [pageIdx] 페이지 인덱스가 있으면 최우선적으로 인덱스 기준으로 합니다
  /// [date] 날짜 자정으로 받습니다
  void changePage({
    int? pageIdx,
    DateTime? date,
    Duration duration = const Duration(milliseconds: 300),
    bool isAnimation = false,
  }) {
    if (pageIdx == null && date == null) {
      return;
    }

    final moveToPageIdx = pageIdx ?? datetoPageIndex(date!);

    if (isAnimation) {
      controller.animateToPage(
        moveToPageIdx,
        duration: duration,
        curve: Curves.easeInOut,
      );
    } else {
      controller.jumpToPage(moveToPageIdx);
    }
  }

  /// 날짜를 페이지 인덱스로 변환합니다
  /// 기준은 [_minDate]입니다
  int datetoPageIndex(DateTime date) {
    if (date.isBefore(_minDate)) {
      return 0;
    }
    return date.difference(_minDate).inDays;
  }

  /// 페이지 인덱스를 날짜로 변환합니다
  /// 기준은 [_minDate]입니다
  DateTime indexToDate(int pageIdx) {
    if (pageIdx < 0) {
      return _minDate;
    }
    return _minDate.add(Duration(days: pageIdx));
  }
}
