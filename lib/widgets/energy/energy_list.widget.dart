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
    if (this.items != null) {
      return _buildList(this.items);
    }
    return FutureBuilder<List<Energy>>(
      future: Energy.find(
        filters: this.filters,
        orderBy: "date DESC",
      ),
      builder: (BuildContext context, AsyncSnapshot<List<Energy>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return LoadingIndicator();
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }
            List<Energy> energyUsages = snapshot.data;
            return _buildList(energyUsages);
        }
        return Container(child: const Text("Unable to get energyUsages"));
      },
    );
  }

  Widget _buildList(List<Energy> energyUsages) {
    if (energyUsages.length == 0) {
      return Center(child: Text("Wow, so empty"));
    }

    return ListView.builder(
      itemCount: energyUsages.length,
      itemBuilder: (BuildContext context, int index) {
        return EnergyListItem(
          energy: energyUsages[index],
          onTap: this.onTap,
        );
      },
    );
  }
}
