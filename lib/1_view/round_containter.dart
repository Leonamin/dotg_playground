import 'dart:math';

import 'package:flutter/material.dart';

class RoundContainer extends StatelessWidget {
  const RoundContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

        // 가장 둥글게 보이도록 borderRadius 계산
        double borderRadius = (height <= width) ? height / 2 : width / 2;

        // 둥근 부분의 너비 계산
        double widthOfCurvedPart = 0;
        if (width <= height) {
          // width가 height보다 작거나 같은 경우, 둥근 부분의 너비는 width와 같습니다.
          widthOfCurvedPart = width;
        } else {
          // width가 height보다 큰 경우, 원래의 계산 방식을 사용합니다.
          widthOfCurvedPart = 2 * borderRadius -
              2 *
                  sqrt(borderRadius * borderRadius -
                      (height / 2) * (height / 2));
        }

        double padding = widthOfCurvedPart / 2;
        if (padding < 0) {
          padding = 0;
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            color: Colors.blue,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Center(
                child: Text(
                  '오늘로 이동',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
