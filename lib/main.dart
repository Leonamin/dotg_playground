// import 'package:dotg_playground/1_view/home_view.dart';
// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: '땃쥐 놀이터',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const HomeView(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'disable_screenshots.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Secure App'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              DisableScreenshots.disable();
            },
            child: Text('Disable Screenshots'),
          ),
        ),
      ),
    );
  }
}
