import "package:flutter/material.dart";

class Change extends StatelessWidget {
  final String text;
  final bool isPositive;
  final Color color;
  final TextStyle style;
  final Duration duration;

  Change({
    Key key,
    @required this.text,
    this.isPositive,
    this.color,
    this.style,
    this.duration,
  })  : assert(text != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String value = text.startsWith("-") ? text.substring(1) : text;

    String prefix = "";
    if (this.isPositive != null) {
      prefix = this.isPositive ? "\u25b2" : "\u25bc";
    }

    Color color = theme.textTheme.bodyText1.color;
    if (this.color != null) {
      color = color;
    } else if (this.isPositive != null) {
      color = this.isPositive ? Colors.green : Colors.red;
    }

    TextStyle style;
    if (this.style != null) {
      style = this.style.copyWith(
            color: color,
            fontWeight: FontWeight.normal,
          );
    } else {
      style = TextStyle(
        color: color,
        fontWeight: FontWeight.normal,
      );
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
        "$prefix $value ($duration)",
        style: style,
      );
    }

    return Text(
      "$prefix $value",
      style: style,
    );
  }
}
