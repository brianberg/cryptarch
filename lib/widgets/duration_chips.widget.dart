import "package:flutter/material.dart";

class DurationChips extends StatelessWidget {
  static const DURATION_7D = "7d";
  static const DURATION_30D = "30d";
  static const DURATION_90D = "90d";
  static const DURATION_1Y = "1y";
  static const DURATION_ALL = "All";

  final String selected;
  final Function onSelected;

  DurationChips({
    Key key,
    @required this.selected,
    this.onSelected,
  })  : assert(selected != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final chips = [
      DURATION_7D,
      DURATION_30D,
      DURATION_90D,
      DURATION_1Y,
      DURATION_ALL,
    ].map((duration) {
      return ChoiceChip(
        label: Text(duration, style: theme.textTheme.caption),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        selected: this.selected == duration,
        onSelected: this.onSelected != null
            ? (selected) {
                if (selected) {
                  this.onSelected(duration);
                }
              }
            : null,
      );
    }).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: chips,
    );
  }
}
