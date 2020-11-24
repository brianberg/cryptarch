import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart" show PortfolioItem;
import "package:cryptarch/ui/widgets.dart";

class PortfolioList extends StatelessWidget {
  final Function onTap;
  final List<PortfolioItem> items;

  PortfolioList({
    Key key,
    @required this.items,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (this.items.length == 0) {
      return Center(child: Text("Wow, so empty"));
    }

    return ListView.builder(
      itemCount: this.items.length,
      itemBuilder: (BuildContext context, int index) {
        return PortfolioListItem(
          item: this.items[index],
          onTap: this.onTap,
        );
      },
    );
  }
}
