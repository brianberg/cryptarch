import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart" show InventoryItem;
import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/widgets/widgets.dart";

class InventoryPage extends StatefulWidget {
  static String routeName = "/inventory";

  static Route route() {
    return MaterialPageRoute(
      builder: (context) => InventoryPage(),
    );
  }

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<InventoryItem> items;

  @override
  void initState() {
    super.initState();
    this._getInventory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FlatAppBar(
        title: Text("Inventory"),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () async {
              final success = await Navigator.push(
                context,
                InventoryAddPage.route(),
              );
              if (success == 1) {
                await this._getInventory();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: this.items != null
            ? ListView.builder(
                itemCount: this.items.length,
                itemBuilder: (BuildContext context, int index) {
                  return InventoryListItem(
                    item: this.items[index],
                    onTap: (item) {
                      // TODO:
                    },
                  );
                },
              )
            : LoadingIndicator(),
      ),
    );
  }

  Future<void> _getInventory() async {
    final items = await InventoryItem.find(orderBy: "name");

    setState(() {
      this.items = items;
    });
  }
}
