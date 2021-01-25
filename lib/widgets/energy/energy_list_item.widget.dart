import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart" show Energy;
import "package:intl/intl.dart";

class EnergyListItem extends StatelessWidget {
  final Energy energy;
  final Function onTap;

  EnergyListItem({
    Key key,
    @required this.energy,
    this.onTap,
  })  : assert(energy != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat("MM/dd/yyyy");
    final fiatValue = NumberFormat.simpleCurrency().format(this.energy.cost);

    return ListTile(
      key: ValueKey(this.energy.id),
      title: Text(
        "Energy Usage",
        style: TextStyle(
          color: theme.textTheme.bodyText1.color,
        ),
      ),
      subtitle: Text(
        dateFormat.format(this.energy.date),
        style: theme.textTheme.subtitle2,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(this.energy.amount.toStringAsFixed(8)),
          Text(
            fiatValue,
            style: theme.textTheme.subtitle2,
          ),
        ],
      ),
    );
  }
}
