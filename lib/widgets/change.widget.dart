import "package:flutter/material.dart";

import "package:intl/intl.dart";

class Change extends StatelessWidget {
  final String text;
  final bool isPositive;
  final TextStyle style;
  final Duration duration;

  Change({
    Key key,
    @required this.text,
    this.isPositive,
    this.style,
    this.duration,
  })  : assert(text != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String prefix = this.isPositive == true ? "+" : "";

    Color color = theme.textTheme.subtitle2.color;
    if (this.isPositive != null) {
      color = this.isPositive ? Colors.green : Colors.red;
    }

    TextStyle style;
    if (this.style != null) {
      style = this.style.copyWith(color: color);
    } else {
      style = TextStyle(color: color);
    }

    if (this.duration != null) {
      int durationHours = this.duration.inHours;
      String duration = "${durationHours}h";
      if (durationHours > 24) {
        if (durationHours % 24 == 0) {
          int durationDays = this.duration.inDays;
          if (durationDays % 365 == 0) {
            duration = "${durationDays / 365}y";
          } else {
            duration = "${durationDays}d";
          }
        } else {
          duration = "${durationHours}h";
        }
      }
      return Text(
        "$prefix$text ($duration)",
        style: style,
      );
    }

    return Text(
      "$prefix$text",
      style: style,
    );
  }
}
