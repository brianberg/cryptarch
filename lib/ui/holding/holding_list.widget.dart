import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart";
import "package:cryptarch/ui/widgets.dart";

class HoldingList extends StatelessWidget {
  final Function onTap;
  final List<Holding> items;
  final Map<String, dynamic> filters;

  HoldingList({
    Key key,
    this.items,
    this.onTap,
    this.filters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (this.items != null) {
      return _buildList(this.items);
    }
    return FutureBuilder<List<Holding>>(
      future: Holding.find(filters: this.filters),
      builder: (BuildContext context, AsyncSnapshot<List<Holding>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return LoadingIndicator();
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }
            List<Holding> holdings = snapshot.data;
            return _buildList(holdings);
        }
        return Container(child: const Text("Unable to get holdings"));
      },
    );
  }

  Widget _buildList(List<Holding> holdings) {
    if (holdings.length == 0) {
      return Center(child: Text("Wow, so empty"));
    }

    return ListView.builder(
      itemCount: holdings.length,
      itemBuilder: (BuildContext context, int index) {
        return HoldingListItem(
          holding: holdings[index],
          onTap: this.onTap,
        );
      },
    );
  }
}
