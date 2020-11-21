import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart";
import "package:cryptarch/ui/widgets.dart";

class MinerList extends StatelessWidget {
  final Function onTap;
  final List<Miner> items;
  final Map<String, dynamic> filters;

  MinerList({
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
    return FutureBuilder<List<Miner>>(
      future: Miner.find(filters: this.filters),
      builder: (BuildContext context, AsyncSnapshot<List<Miner>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return LoadingIndicator();
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }
            List<Miner> miners = snapshot.data;
            return _buildList(miners);
        }
        return Container(child: const Text("Unable to get miners"));
      },
    );
  }

  Widget _buildList(List<Miner> miners) {
    if (miners.length == 0) {
      return Center(child: Text("Wow, so empty"));
    }

    return ListView.builder(
      itemCount: miners.length,
      itemBuilder: (BuildContext context, int index) {
        return MinerListItem(
          miner: miners[index],
          onTap: this.onTap,
        );
      },
    );
  }
}
