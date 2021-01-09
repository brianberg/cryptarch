import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart";
import "package:cryptarch/widgets/widgets.dart";

class PayoutList extends StatelessWidget {
  final Function onTap;
  final List<Payout> items;
  final Map<String, dynamic> filters;

  PayoutList({
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
    return FutureBuilder<List<Payout>>(
      future: Payout.find(
        filters: this.filters,
        orderBy: "date DESC",
      ),
      builder: (BuildContext context, AsyncSnapshot<List<Payout>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return LoadingIndicator();
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }
            List<Payout> payouts = snapshot.data;
            return _buildList(payouts);
        }
        return Container(child: const Text("Unable to get payouts"));
      },
    );
  }

  Widget _buildList(List<Payout> payouts) {
    if (payouts.length == 0) {
      return Center(child: Text("Wow, so empty"));
    }

    return ListView.builder(
      itemCount: payouts.length,
      itemBuilder: (BuildContext context, int index) {
        return PayoutListItem(
          payout: payouts[index],
          onTap: this.onTap,
        );
      },
    );
  }
}
