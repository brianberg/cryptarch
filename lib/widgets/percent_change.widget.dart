import "package:flutter/material.dart";

import "package:cryptarch/widgets/widgets.dart";

class PercentChange extends StatelessWidget {
  final double value;
  final Duration duration;
  final Color color;
  final TextStyle style;

  PercentChange({
    Key key,
    @required this.value,
    this.duration,
    this.color,
    this.style,
  })  : assert(value != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentChange = this.value.toStringAsFixed(2);

    bool isPositive;
    if (this.value > 0) {
      isPositive = true;
    } else if (this.value < 0) {
      isPositive = false;
    }

    return Change(
      text: "$percentChange%",
      isPositive: isPositive,
      duration: this.duration,
      color: this.color,
      style: this.style,
    );
  }
}
