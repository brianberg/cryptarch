import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart" show Miner;
import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/ui/widgets.dart";

class MinerPage extends StatefulWidget {
  final Miner miner;

  MinerPage({
    Key key,
    @required this.miner,
  })  : assert(miner != null),
        super(key: key);

  @override
  _MinerPageState createState() => _MinerPageState();
}

class _MinerPageState extends State<MinerPage> {
  Miner miner;

  @override
  void initState() {
    super.initState();
    this.miner = this.widget.miner;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final symbol = this.miner.asset.symbol;

    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.miner.name),
        bottom: this.miner.active
            ? null
            : AppBar(
                toolbarHeight: 40.0,
                centerTitle: true,
                title: Text(
                  "Inactive",
                  style: theme.textTheme.bodyText1,
                ),
                leading: Container(),
                backgroundColor: theme.colorScheme.surface,
              ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditMinerPage(miner: this.widget.miner),
                ),
              );
              await this._refresh();
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Profitability",
                          style: theme.textTheme.bodyText1,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${this.miner.profitability.toStringAsFixed(6)} $symbol",
                            ),
                            Text(
                              "\$${this.miner.fiatProfitability.toStringAsFixed(2)} / day",
                              style: theme.textTheme.subtitle2,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Unpaid",
                          style: theme.textTheme.bodyText1,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${this.miner.unpaidAmount.toStringAsFixed(6)} $symbol",
                            ),
                            Text(
                              "\$${this.miner.fiatUnpaidAmount.toStringAsFixed(2)}",
                              style: theme.textTheme.subtitle2,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
              child: Text(
                "Asset",
                style: theme.textTheme.bodyText1,
              ),
            ),
            AssetListItem(asset: this.miner.asset),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
              child: Text(
                "Wallet",
                style: theme.textTheme.bodyText1,
              ),
            ),
            AccountListItem(
              account: this.miner.account,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    final miner = await Miner.findOneById(this.miner.id);
    setState(() {
      this.miner = miner;
    });
  }
}
