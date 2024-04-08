import 'package:dotg_playground/1_view/mixed_scroll_tab/mixed_scroll_tab_widget.dart';
import 'package:flutter/material.dart';

class TabIndicatorView extends StatelessWidget {
  const TabIndicatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return const MixedScrollTabWidget(
      scrollWidgets: [
        _Fragment1(),
        _Fragment2(),
        _Fragment3(),
      ],
      tabWidgets: [_Fragment4()],
    );
  }
}

class _Fragment1 extends StatelessWidget {
  const _Fragment1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 1000,
      color: Colors.red,
    );
  }
}

class _Fragment2 extends StatelessWidget {
  const _Fragment2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.green,
    );
  }
}

class _Fragment3 extends StatelessWidget {
  const _Fragment3({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      color: Colors.blue,
    );
  }
}

class _Fragment4 extends StatelessWidget {
  const _Fragment4({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400,
      color: Colors.yellow,
    );
  }
}

class _CustomTab extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const _CustomTab({
    super.key,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        child: Text(text),
      ),
    );
  }
}
