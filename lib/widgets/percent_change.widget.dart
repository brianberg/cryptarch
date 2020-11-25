import "package:flutter/material.dart";

class PercentChange extends StatelessWidget {
  final double value;
  final TextStyle style;

  PercentChange({
    Key key,
    @required this.value,
    this.style,
  })  : assert(value != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final prefix = this.value > 0 ? '+' : '';
    final percentChange = this.value.toStringAsFixed(2);

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
      "$prefix$percentChange%",
      style: style,
    );
  }
}
