import 'package:flutter/material.dart';

class BottomSliverView extends StatelessWidget {
  const BottomSliverView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            floating: false,
            pinned: true,
            expandedHeight: kToolbarHeight,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('앱바 냐옹~'),
            ),
          ),
          SliverList.list(children: [
            Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: () {},
                  child: Icon(Icons.add),
                ),
                body: _TextContent()),
            Container(
              height: 200,
              color: Colors.blue,
              child: Center(child: Text('바텀 콘텐츠 냥')),
            ),
          ]),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 50.0,
              maxHeight: 50.0,
              child: Container(
                color: Colors.green,
                child: Center(
                  child: Text('바텀바 슬라이버 냥'),
                ),
              ),
            ),
          ),
          // SliverToBoxAdapter(
          //   child: Container(
          //     height: 200,
          //     color: Colors.blue,
          //     child: Center(child: Text('바텀 콘텐츠 냥')),
          //   ),
          // ),
        ],
      ),
    );
  }
}

// _SliverAppBarDelegate
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class _TextContent extends StatelessWidget {
  const _TextContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      '''Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque mauris est, mollis vel convallis vel, placerat non leo. Aenean sapien magna, auctor quis laoreet sit amet, volutpat vitae nunc. Nam posuere tellus at auctor mollis. Nullam eget nisl convallis, mollis lorem fermentum, varius lorem. Maecenas ac dui quis arcu laoreet lobortis. Etiam scelerisque eget dui et elementum. Aliquam vel mi aliquet mauris rutrum fringilla. Donec aliquet, risus ut tincidunt fermentum, orci sapien convallis lacus, eu bibendum quam sapien malesuada ipsum. Fusce vitae nulla at metus faucibus convallis. Nullam euismod tempus velit id rhoncus. Aliquam semper ex nec velit cursus consequat.

Integer nec vulputate purus, nec congue nisl. Vivamus ornare tincidunt magna quis gravida. Morbi quis hendrerit ipsum. Praesent eu massa non neque rhoncus condimentum. Integer feugiat tortor sit amet vulputate imperdiet. Nullam eu ante quam. Cras nec vulputate nisi, porta volutpat ipsum. Aliquam consequat pretium egestas. Proin lobortis lectus quam, at aliquet tortor lacinia sit amet. Etiam volutpat quis erat et blandit. Sed tristique bibendum orci, quis porttitor lorem fermentum a. Sed sapien turpis, maximus posuere sapien sit amet, eleifend ultricies turpis. Vivamus dui leo, cursus at dictum ut, consectetur vitae nulla.

Integer bibendum nibh at mattis viverra. Pellentesque vulputate fringilla facilisis. Nulla efficitur erat blandit, volutpat massa non, finibus nisi. Aliquam faucibus accumsan orci, vitae dictum mi lacinia in. Praesent arcu tortor, semper rhoncus est quis, facilisis rhoncus metus. Pellentesque finibus vitae dolor a venenatis. Aliquam erat volutpat. Cras sagittis magna enim, ac gravida sem feugiat in. Praesent aliquam porttitor mauris id commodo. Duis sed dictum diam, quis aliquet lorem. Etiam vitae nulla libero. Vivamus euismod nibh at dictum ultrices.

Praesent nec diam eget enim condimentum sodales non vitae eros. In laoreet nisl eu gravida tincidunt. Vivamus tellus purus, sodales ut odio placerat, vehicula varius felis. Aliquam in libero dapibus, dapibus est pharetra, bibendum dolor. Vestibulum nulla lorem, posuere quis egestas nec, vehicula semper nisl. Vivamus tincidunt lectus vel felis tincidunt rutrum. Praesent mollis lectus ultricies vestibulum tincidunt. In hac habitasse platea dictumst. Nam malesuada hendrerit eros convallis elementum. Curabitur lacinia posuere est eget sagittis. Donec malesuada congue justo, at feugiat mauris fringilla a. Nam a magna ligula. Sed pulvinar nunc in sem gravida aliquet.

Mauris a lacinia eros, in ultricies ante. Maecenas et ipsum sed ex bibendum lobortis. Nunc maximus a ipsum eget tincidunt. Fusce accumsan neque metus, eu efficitur est bibendum eu. Donec imperdiet, velit non lacinia tincidunt, metus ex molestie felis, non volutpat ante lorem eget arcu. Nulla porttitor nibh eget rhoncus commodo. Sed pharetra pellentesque porttitor. Cras maximus placerat odio in tempus. Vivamus sollicitudin mollis dui ornare scelerisque. Vestibulum pulvinar sit amet sapien in feugiat. Nam molestie est eu enim tempus, eget pulvinar nunc vestibulum. Vivamus ornare elit sit amet bibendum dictum. Integer interdum porttitor massa, eu gravida massa elementum sed.
''',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
