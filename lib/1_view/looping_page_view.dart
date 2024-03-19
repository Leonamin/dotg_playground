import 'package:dotg_playground/1_view/looping_page_view_model.dart';
import 'package:flutter/material.dart';

class LoopPageView extends StatefulWidget {
  final String title;

  const LoopPageView(this.title, {super.key});

  @override
  State<LoopPageView> createState() => _LoopPageViewState();
}

class _LoopPageViewState extends State<LoopPageView> with LoopingPageViewModel {
  /// 위젯이 생성될 시점의 오늘
  final _baseDate = DateTime.now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  @override
  void initState() {
    super.initState();

    initController(_baseDate);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PageView.builder(
        controller: controller,
        itemBuilder: (_, index) {
          return Center(
            child: Column(
              children: [
                Text(
                  'Page - ${index} DateTime - ${indexToDate(index)}',
                  style: TextStyle(
                    color: (index % 5 == 0) ? Colors.blue : Colors.black,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    changePage(pageIdx: 0);
                  },
                  child: const Text('GO TO FIRST PAGE'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    changePage(date: DateTime.now());
                  },
                  child: const Text('GO TO TODAY'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    changePage(pageIdx: 2000);
                  },
                  child: const Text('GO TO 2000 PAGE'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
