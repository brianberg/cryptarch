import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/widgets/widgets.dart";

class CurrencyChange extends StatelessWidget {
  final double value;
  final Color color;
  final Duration duration;
  final TextStyle style;

  CurrencyChange({
    Key key,
    @required this.value,
    this.duration,
    this.color,
    this.style,
  })  : assert(value != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final valueChange = NumberFormat.simpleCurrency().format(value);

    bool isPositive;
    if (this.value > 0) {
      isPositive = true;
    } else if (this.value < 0) {
      isPositive = false;
    }

    return Change(
      text: valueChange,
      isPositive: isPositive,
      duration: this.duration,
      color: this.color,
      style: this.style,
    );
  }
}
