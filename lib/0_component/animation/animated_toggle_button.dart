import 'package:flutter/material.dart';

class AnimatedToggleButton extends StatefulWidget {
  const AnimatedToggleButton({
    super.key,
    required this.on,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.fastOutSlowIn,
    this.iconSize = 24,
    this.openIcon = Icons.add,
    this.closeIcon = Icons.close,
    this.openLabel,
    this.closeLabel,
    this.openLabelStyle,
    this.closeLabelStyle,
    this.openColor,
    this.closeColor,
    this.openIconColor,
    this.closeIconColor,
    this.openBorderColor = Colors.transparent,
    this.closeBorderColor = Colors.transparent,
    this.openBorderWidth = 1,
    this.closeBorderWidth = 1,
    this.openPadding = const EdgeInsets.all(0),
    this.closePadding = const EdgeInsets.all(0),
    this.openMargin = const EdgeInsets.all(0),
    this.closeMargin = const EdgeInsets.all(0),
    this.onTap,
    required this.getTextWidth,
    required this.getTextHeight,
  });

  final bool on;
  final Duration duration;
  final Curve curve;

  final double iconSize;

  final IconData openIcon;
  final IconData closeIcon;
  final String? openLabel;
  final String? closeLabel;
  final TextStyle? openLabelStyle;
  final TextStyle? closeLabelStyle;
  final Color? openColor;
  final Color? closeColor;
  final Color? openIconColor;
  final Color? closeIconColor;
  final Color openBorderColor;
  final Color closeBorderColor;
  final double openBorderWidth;
  final double closeBorderWidth;

  final EdgeInsets openPadding;
  final EdgeInsets closePadding;
  final EdgeInsets openMargin;
  final EdgeInsets closeMargin;

  final Function()? onTap;

  final double Function(
    String text,
    TextStyle style,
  ) getTextWidth;
  final double Function(
    String text,
    TextStyle style,
    double screenWidth,
  ) getTextHeight;

  @override
  State<AnimatedToggleButton> createState() => _AnimatedToggleButtonState();
}

class _AnimatedToggleButtonState extends State<AnimatedToggleButton> {
  late final Color openColor =
      widget.openColor ?? Theme.of(context).colorScheme.primary;
  late final Color closeColor = widget.closeColor ?? Colors.white;

  late final TextStyle openLabelStyle = widget.openLabelStyle ??
      const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  late final TextStyle closeLabelStyle = widget.closeLabelStyle ??
      const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  late Size openSize;
  late Size closeSize;

  bool get isOpend => !widget.on;

  Color get color => isOpend ? openColor : closeColor;
  double get borderRadius => isOpend ? openSize.width : closeSize.width;
  Color get borderColor =>
      isOpend ? widget.openBorderColor : widget.closeBorderColor;

  double get borderWidth =>
      isOpend ? widget.openBorderWidth : widget.closeBorderWidth;
  double get width => isOpend ? openSize.width : closeSize.width;
  double get height => isOpend ? openSize.height : closeSize.height;

  double get openOpacity => isOpend ? 1 : 0;
  double get closeOpacity => isOpend ? 0 : 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    double openTextWidth = 0;
    double closeTextWidth = 0;
    double openTextHeight = 0;
    double closeTextHeight = 0;

    if (widget.openLabel != null) {
      openTextWidth = widget.getTextWidth(
        widget.openLabel!,
        openLabelStyle,
      );
      openTextHeight = widget.getTextHeight(
        widget.openLabel!,
        openLabelStyle,
        MediaQuery.of(context).size.width,
      );
    }

    var openWidth = openTextWidth +
        widget.iconSize +
        widget.openPadding.horizontal +
        widget.openMargin.horizontal +
        4;
    var openHeight = openTextHeight +
        widget.openPadding.vertical +
        widget.openMargin.vertical;

    if (openWidth < 56) {
      openWidth = 56;
    }
    if (openHeight < 56) {
      openHeight = 56;
    }

    openSize = Size(openWidth, openHeight);

    if (widget.closeLabel != null) {
      closeTextWidth = widget.getTextWidth(
        widget.closeLabel!,
        closeLabelStyle,
      );
      closeTextHeight = widget.getTextHeight(
        widget.closeLabel!,
        closeLabelStyle,
        MediaQuery.of(context).size.width,
      );
    }

    var closeWidth = closeTextWidth +
        widget.iconSize +
        widget.closePadding.horizontal +
        widget.closeMargin.horizontal +
        4;
    var closeHeight = closeTextHeight +
        widget.closePadding.vertical +
        widget.closeMargin.vertical;
    if (closeWidth < 56) {
      closeWidth = 56;
    }
    if (closeHeight < 56) {
      closeHeight = 56;
    }

    closeSize = Size(closeWidth, closeHeight);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        constraints: const BoxConstraints(minHeight: 56, minWidth: 56),
        width: width,
        height: height,
        padding: isOpend ? widget.openPadding : widget.closePadding,
        margin: isOpend ? widget.openMargin : widget.closeMargin,
        alignment: isOpend ? Alignment.center : AlignmentDirectional.topCenter,
        duration: widget.duration,
        curve: widget.curve,
        child: Center(
          child: Stack(
            children: [
              _ChildButton(
                key: UniqueKey(),
                opacity: openOpacity,
                duration: widget.duration,
                iconData: widget.openIcon,
                iconSize: widget.iconSize,
                iconColor: widget.openIconColor,
                label: widget.openLabel,
                labelStyle: openLabelStyle,
              ),
              _ChildButton(
                key: UniqueKey(),
                opacity: closeOpacity,
                duration: widget.duration,
                iconData: widget.closeIcon,
                iconSize: widget.iconSize,
                iconColor: widget.closeIconColor,
                label: widget.closeLabel,
                labelStyle: closeLabelStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildButton extends StatelessWidget {
  const _ChildButton({
    super.key,
    required this.opacity,
    required this.duration,
    required this.iconData,
    this.iconColor,
    required this.iconSize,
    required this.label,
    required this.labelStyle,
  });

  final double opacity;
  final Duration duration;
  final IconData iconData;
  final double iconSize;
  final Color? iconColor;
  final String? label;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: opacity,
        duration: duration,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: iconSize,
              color: iconColor,
            ),
            if (label != null)
              Flexible(
                child: ClipRect(
                  child: Text(
                    label!,
                    style: labelStyle,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
