import 'package:flutter/material.dart';
import 'package:focus_detector_v2/focus_detector_v2.dart';

typedef OnGainVisibility = void Function();
typedef OnLostVisibility = void Function();

class MixedScrollTabWidget extends StatefulWidget {
  final List<Widget> scrollWidgets;
  final List<Widget> tabWidgets;

  const MixedScrollTabWidget({
    super.key,
    required this.scrollWidgets,
    required this.tabWidgets,
  });

  @override
  State<MixedScrollTabWidget> createState() => _MixedScrollTabWidgetState();
}

class _MixedScrollTabWidgetState extends State<MixedScrollTabWidget>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final PageController _pageController;
  late final ScrollController _scrollController;

  late final List<(Key, Widget, OnGainVisibility, OnLostVisibility)>
      _scrollWidgets = [
    for (var i = 0; i < widget.scrollWidgets.length; i++)
      (
        GlobalKey(),
        widget.scrollWidgets[i],
        () => _onVisibilityGained(i),
        () => _onVisibilityLost(i)
      ),
  ];

  late final List<Widget> _tabWidgets = [...widget.tabWidgets];

  /// 현재 보이는 스크롤 위젯의 인덱스
  final Set<int> _visibaleScrollWidgetIndexs = {};
  int get _primaryVisibleScrollWidgetIndex {
    if (_visibaleScrollWidgetIndexs.isEmpty) {
      return 0;
    }
    return _visibaleScrollWidgetIndexs.reduce((v, e) => v > e ? v : e);
  }

  /// 탭 인디케이터에 사용할 인덱스 중 탭 위젯의 시작 인덱스
  int get _tabWidgetStartIndex => _scrollWidgets.length;

  int get _pageLength => 1 + _tabWidgets.length;

  int get _tabIndicatorLength => _scrollWidgets.length + _tabWidgets.length;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: _tabIndicatorLength,
      vsync: this,
    );

    _pageController = PageController(keepPage: true);

    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              for (int i = 0; i < 4; i++)
                _TabWrapper(
                  text: 'Tab $i',
                  onTap: () => _onTapTabBar(i),
                ),
            ],
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                IntergratedView(
                  sc: _scrollController,
                  children: [
                    for (final widget in _scrollWidgets)
                      FocusDetector(
                        key: widget.$1,
                        onVisibilityGained: () => widget.$3(),
                        onVisibilityLost: () => widget.$4(),
                        child: widget.$2,
                      )
                  ],
                ),
                ..._tabWidgets,
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onTapTabBar(int index) {
    _changeTabIndicator(index);

    if (index >= _tabWidgetStartIndex) {
      _changePage(_tabIndexToPage(index));
    } else {
      /// 스크롤 위젯
      /// 마지막으로 보였던 화면의 인덱스 가져오기
      /// 해당 인덱스를 통해 해당 화면의 키 가져오기
      /// 스크롤 화면으로 이동(일반적으로 0번 인덱스)
      _changePage(0).then((value) {
        /// 해당 키로 스크롤 이동
        final scrollIndex = index;
        final key = _scrollWidgets[scrollIndex].$1 as GlobalKey;

        if (key.currentContext != null) {
          Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 300),
          );
        }
      });
    }
  }

  int _tabIndexToPage(int index) {
    if (index >= _tabWidgetStartIndex) {
      final tabWidgetIndex = index - _tabWidgetStartIndex;
      return 1 + tabWidgetIndex;
    }
    return 0;
  }

  void _onVisibilityGained(int index) {
    _setCurrentVisible(index);
    final primaryIndex = _primaryVisibleScrollWidgetIndex;
    if (_tabController.index >= _tabWidgetStartIndex) {
      return;
    }
    _changeTabIndicator(primaryIndex);
  }

  void _onVisibilityLost(int index) {
    _removeCurrentVisible(index);

    if (_tabController.index >= _tabWidgetStartIndex) {
      return;
    }
    final primaryIndex = _primaryVisibleScrollWidgetIndex;
    _changeTabIndicator(primaryIndex);
  }

  void _setCurrentVisible(int scrollIndex) {
    _visibaleScrollWidgetIndexs.add(scrollIndex);
  }

  void _removeCurrentVisible(int scrollIndex) {
    if (_visibaleScrollWidgetIndexs.contains(scrollIndex)) {
      _visibaleScrollWidgetIndexs.remove(scrollIndex);
    }
  }

  /// 탭바(탭인디케이터) 변경
  void _changeTabIndicator(int index) {
    if (index >= _tabIndicatorLength) {
      return;
    }
    if (_tabController.index == index) {
      return;
    }
    _tabController.animateTo(index);
  }

  /// 페이지 변경
  Future<void> _changePage(int page) async {
    if (page > _pageLength) {
      return;
    }
    await _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

class _TabWrapper extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const _TabWrapper({
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

class IntergratedView extends StatelessWidget {
  final ScrollController sc;
  final List<Widget> children;
  const IntergratedView({
    super.key,
    required this.sc,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: sc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
