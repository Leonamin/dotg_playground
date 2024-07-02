import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class QuillView extends StatelessWidget {
  QuillView({super.key});

  static const int largeScreenSize = 1366;
  static const int mediumScreenSize = 768;
  static const int smallScreenSize = 360;

  final QuillController _controller = QuillController.basic();

  bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > mediumScreenSize;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfffbf7),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuillToolbar.simple(
            configurations: QuillSimpleToolbarConfigurations(
              controller: _controller,
              sharedConfigurations: const QuillSharedConfigurations(
                locale: Locale('de'),
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: isLargeScreen(context) ? 2 : 1,
                  child: Container(),
                ),
                Flexible(
                  flex: isLargeScreen(context) ? 4 : 4,
                  child: QuillEditor.basic(
                    configurations: QuillEditorConfigurations(
                      controller: _controller,
                      sharedConfigurations: const QuillSharedConfigurations(
                        locale: Locale('kr'),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: isLargeScreen(context) ? 2 : 1,
                  child: Container(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Positioned.fill(
//                         child: Image.network(
//                           'http://cutehamster.cuteshrew.xyz/file/OP2KbFY1Qvu_hpAWWCYfew%3D%3D',
//                         ),
