import "package:flutter/material.dart";

class CustomTextButton extends StatefulWidget {
  CustomTextButton({
    required this.text,
    required this.fontSize
  });

  final String text;
  final double fontSize;

  @override
  State<CustomTextButton> createState() => _CustomTextButtonState();
}

/// CustomTextButton's state
class _CustomTextButtonState extends State<CustomTextButton> {
  // FontWeight fontWeight = FontWeight.normal;
  bool isCustomTextButtonClicked = false;

  @override
  GestureDetector build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        setState(() => {
              // fontWeight == FontWeight.normal ? FontWeight.w700 : FontWeight.normal
              isCustomTextButtonClicked = !isCustomTextButtonClicked
            })
      },
      child: Text(widget.text,
          style: TextStyle(
            fontFamily: "PT-Mono",
            fontSize: widget.fontSize,
            fontWeight:
                isCustomTextButtonClicked ? FontWeight.w700 : FontWeight.normal,
          )),
    );
  }
}
