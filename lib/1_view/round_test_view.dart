import 'package:dotg_playground/1_view/round_containter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RoundTestView extends StatefulWidget {
  const RoundTestView({super.key});

  @override
  State<RoundTestView> createState() => _RoundTestViewState();
}

class _RoundTestViewState extends State<RoundTestView> {
  double widthSlider = 100;
  double heightSlider = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Slider(
              value: widthSlider,
              min: 0,
              max: 500,
              onChanged: _onWidthChanged,
            ),
            const SizedBox(height: 20),
            Slider(
                value: heightSlider,
                min: 0,
                max: 500,
                onChanged: _onHeightChanged),
            const SizedBox(height: 20),
            Container(
              width: widthSlider,
              height: heightSlider,
              child: const RoundContainer(),
            ),
          ],
        ),
      ),
    );
  }

  void _onWidthChanged(double value) {
    setState(() {
      widthSlider = value;
    });
  }

  void _onHeightChanged(double value) {
    setState(() {
      heightSlider = value;
    });
  }
}
