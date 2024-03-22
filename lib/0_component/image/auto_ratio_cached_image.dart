// import 'dart:async';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:careease/theme/app_theme.dart';
// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';

// class AutoRatioCachedNetworkImage extends StatefulWidget {
//   final String imageUrl;
//   final double height;

//   final Widget Function(BuildContext, Widget) imageBuilder;
//   final Widget Function(BuildContext)? loadingBuilder;
//   final Widget Function(BuildContext)? errorBuilder;

//   const AutoRatioCachedNetworkImage({
//     super.key,
//     required this.imageUrl,
//     required this.height,
//     required this.imageBuilder,
//     this.loadingBuilder,
//     this.errorBuilder,
//   });

//   @override
//   State<AutoRatioCachedNetworkImage> createState() =>
//       _AutoRatioCachedNetworkImageState();
// }

// class _AutoRatioCachedNetworkImageState
//     extends State<AutoRatioCachedNetworkImage>
//     with AutomaticKeepAliveClientMixin {
//   late Future<Size> _imageSize;
//   Image? _image;

//   @override
//   void initState() {
//     super.initState();
//     _imageSize = _calculateImageDimension();
//   }

//   Future<Size> _calculateImageDimension() {
//     Completer<Size> completer = Completer();
//     Image image = Image(
//       image: CachedNetworkImageProvider(widget.imageUrl),
//       fit: BoxFit.cover,
//     );
//     image.image.resolve(const ImageConfiguration()).addListener(
//       ImageStreamListener(
//         (ImageInfo imageInfo, bool synchronousCall) {
//           var myImage = imageInfo.image;
//           double aspectRatio = myImage.width / myImage.height;
//           // 비율이 16:9를 초과하는 경우 조정
//           if (aspectRatio > (16 / 9)) {
//             aspectRatio = 16 / 9;
//           }
//           Size size = Size(widget.height * aspectRatio, widget.height);
//           _image = image;
//           completer.complete(size);
//         },
//       ),
//     );
//     return completer.future;
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return FutureBuilder<Size>(
//       future: _imageSize,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return widget.loadingBuilder?.call(context) ??
//               _LoadingImageWidget(
//                 height: widget.height,
//                 width: widget.height,
//               );
//         } else if (snapshot.hasData) {
//           return widget.imageBuilder(context, _image!);
//         } else {
//           return const SizedBox.shrink();
//         }
//       },
//     );
//   }

//   @override
//   bool get wantKeepAlive => true;
// }

// class _LoadingImageWidget extends StatelessWidget {
//   const _LoadingImageWidget({
//     required this.height,
//     required this.width,
//   });

//   final double height;
//   final double width;

//   @override
//   Widget build(BuildContext context) {
//     return Shimmer(
//       gradient: const LinearGradient(
//         colors: [
//           ColorHue.black3,
//           ColorHue.white,
//           ColorHue.black3,
//           ColorHue.white,
//         ],
//       ),
//       child: Container(
//         height: height,
//         width: width,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(4),
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
// }
