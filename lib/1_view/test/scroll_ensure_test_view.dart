import 'package:flutter/material.dart';

class ScrollEnsureTestView extends StatefulWidget {
  const ScrollEnsureTestView({super.key});

  @override
  State<ScrollEnsureTestView> createState() => _ScrollEnsureTestViewState();
}

class _ScrollEnsureTestViewState extends State<ScrollEnsureTestView> {
  final oneKey = GlobalKey();
  final twoKey = GlobalKey();
  final threeKey = GlobalKey();
  final sc = ScrollController();

  @override
  Widget build(BuildContext context) {
    final headerWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        controller: sc,
        child: Column(
          children: [
            ScrollDockerWidget(
              key: oneKey,
              selectedDocker: DockerType.one,
              onDockerTap: onTapDocker,
            ),
            _build1(),
            ScrollDockerWidget(
              key: twoKey,
              selectedDocker: DockerType.two,
              onDockerTap: onTapDocker,
            ),
            _build2(),
            ScrollDockerWidget(
              key: threeKey,
              selectedDocker: DockerType.three,
              onDockerTap: onTapDocker,
            ),
            _build3(),
          ],
        ),
      ),
    );
  }

  void onTapDocker(
    DockerType docker,
  ) {
    switch (docker) {
      case DockerType.one:
        Scrollable.ensureVisible(
          oneKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
        break;
      case DockerType.two:
        Scrollable.ensureVisible(
          twoKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
        break;
      case DockerType.three:
        Scrollable.ensureVisible(
          threeKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
        break;

      default:
    }

    return;

    switch (docker) {
      case DockerType.one:
        sc.animateTo(
          oneKey.currentContext!
              .findRenderObject()!
              .getTransformTo(null)
              .getTranslation()
              .y,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        break;
      case DockerType.two:
        sc.animateTo(
          twoKey.currentContext!
              .findRenderObject()!
              .getTransformTo(null)
              .getTranslation()
              .y,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        break;
      case DockerType.three:
        sc.animateTo(
          threeKey.currentContext!
              .findRenderObject()!
              .getTransformTo(null)
              .getTranslation()
              .y,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        break;

      default:
    }
  }

  Widget _build1() {
    return Column(
      children: [
        for (int i = 0; i < 10; i++)
          Container(
            height: 100,
            color: i.isEven ? Colors.blue : Colors.red,
            child: Center(
              child: Text(
                'Item $i',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _build2() {
    return Column(
      children: [
        for (int i = 0; i < 10; i++)
          Container(
            height: 100,
            color: i.isEven ? Colors.green : Colors.yellow,
            child: Center(
              child: Text(
                'Item $i',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _build3() {
    return Column(
      children: [
        for (int i = 0; i < 10; i++)
          Container(
            height: 100,
            color: i.isEven ? Colors.purple : Colors.orange,
            child: Center(
              child: Text(
                'Item $i',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

enum DockerType {
  one,
  two,
  three,
  four,
}

class ScrollDockerWidget extends StatelessWidget {
  final DockerType selectedDocker;
  final Function(DockerType) onDockerTap;

  const ScrollDockerWidget({
    super.key,
    required this.selectedDocker,
    required this.onDockerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        children: [
          DockerButton(
            isEnabled: selectedDocker == DockerType.one,
            label: 'One',
            onTap: () => onDockerTap(DockerType.one),
          ),
          DockerButton(
            isEnabled: selectedDocker == DockerType.two,
            label: 'Two',
            onTap: () => onDockerTap(DockerType.two),
          ),
          DockerButton(
            isEnabled: selectedDocker == DockerType.three,
            label: 'Three',
            onTap: () => onDockerTap(DockerType.three),
          ),
          DockerButton(
            isEnabled: selectedDocker == DockerType.four,
            label: 'Four',
            onTap: () => onDockerTap(DockerType.four),
          ),
        ],
      ),
    );
  }
}

class DockerButton extends StatelessWidget {
  final bool isEnabled;
  final String label;

  final VoidCallback? onTap;

  const DockerButton({
    super.key,
    required this.isEnabled,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isEnabled ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
