import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart" show Asset, Holding;
import "package:cryptarch/ui/widgets.dart";

class HoldingListItem extends StatelessWidget {
  final Holding holding;
  final Function onTap;

  HoldingListItem({
    Key key,
    @required this.holding,
    this.onTap,
  })  : assert(holding != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      key: ValueKey(this.holding.id),
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
      child: Card(
        elevation: 1.0,
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          this.holding.location,
                          style: TextStyle(
                            color: theme.textTheme.bodyText1.color,
                          ),
                        ),
                      ),
                      Text(
                        this.holding.amount.toString(),
                        style: TextStyle(
                          color: theme.textTheme.subtitle1.color,
                        ),
                      ),
                    ],
                  ),
                ),
                FutureBuilder<Asset>(
                  future: Asset.findOneByCurrency(this.holding.currency),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<Asset> snapshot,
                  ) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.active:
                      case ConnectionState.waiting:
                        return LoadingIndicator();
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        }
                        final asset = snapshot.data;
                        if (asset != null) {
                          final value =
                              (holding.amount * asset.value).toStringAsFixed(2);
                          return Text("\$$value");
                        }
                    }

                    return Container();
                  },
                ),
              ],
            ),
          ),
          onTap: () {
            if (this.onTap != null) {
              this.onTap(this.holding);
            }
          },
        ),
      ),
    );
  }
}
