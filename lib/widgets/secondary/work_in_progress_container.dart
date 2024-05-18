import "package:flutter/material.dart";

/// Container - Work In Progress
class WorkInProgressContainer extends StatelessWidget {
  const WorkInProgressContainer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: const Text(
            "Work in Progress",
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
            )
        )
    );
  }
}