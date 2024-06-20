import "package:flutter/material.dart";

/// dot divider - Alerts menu
class DotDivider extends StatelessWidget {
  const DotDivider({
    Key? key,
    required this.widthDotDivider,
    required this.iconSizeDotDivider,
  }) : super(key: key);

  final double widthDotDivider;
  final double iconSizeDotDivider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widthDotDivider,
      // color: Colors.tealAccent,
      child: IconButton(
        onPressed: () => {},
        icon: const Icon(Icons.circle),
        iconSize: iconSizeDotDivider,
        padding: EdgeInsets.zero,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
    );
  }
}