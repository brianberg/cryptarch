import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart";
import "package:cryptarch/widgets/widgets.dart";

class EnergyList extends StatelessWidget {
  final Function onTap;
  final List<Energy> items;
  final Map<String, dynamic> filters;

  EnergyList({
    Key key,
    this.items,
    this.onTap,
    this.filters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (this.items == null || this.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text("No energy usage")),
      );
    }

    return Column(
      children: this.items.map((energy) {
        return EnergyListItem(
          energy: energy,
          onTap: this.onTap,
        );
      }).toList(),
    );
  }
}
