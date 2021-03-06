import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart";
import "package:cryptarch/widgets/widgets.dart";

class PayoutList extends StatelessWidget {
  final Function onTap;
  final List<Payout> items;

  PayoutList({
    Key key,
    this.items,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (this.items == null || this.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text("No payouts")),
      );
    }

    return Column(
      children: this.items.map((payout) {
        return PayoutListItem(
          payout: payout,
          onTap: this.onTap,
        );
      }).toList(),
    );
  }
}
