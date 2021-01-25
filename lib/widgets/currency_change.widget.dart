import "package:flutter/material.dart";

import "package:intl/intl.dart";

class CurrencyChange extends StatelessWidget {
  final double value;
  final TextStyle style;

  CurrencyChange({
    Key key,
    @required this.value,
    this.style,
  })  : assert(value != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final change = NumberFormat.simpleCurrency().format(value);
    final prefix = this.value > 0 ? "+" : "";

    Color color = theme.textTheme.subtitle2.color;
    if (this.value > 0) {
      color = Colors.green;
    } else if (this.value < 0) {
      color = Colors.red;
    }

    TextStyle style;
    if (this.style != null) {
      style = this.style.copyWith(color: color);
    } else {
      style = TextStyle(color: color);
    }

    return Text(
      "$prefix$change",
      style: style,
    );
  }
}
