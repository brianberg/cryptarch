import "package:flutter/material.dart";

import "package:cryptarch/constants/constants.dart" show CURRENCIES;
import "package:cryptarch/models/models.dart" show Asset;
import "package:cryptarch/widgets/widgets.dart";

class AssetAddPage extends StatelessWidget {
  static String routeName = "/asset_add";

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => AssetAddPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencies = CURRENCIES.values.toList();
    currencies.sort((a, b) {
      return a["name"].toString().compareTo(b["name"].toString());
    });

    return Scaffold(
      appBar: FlatAppBar(
        title: const Text("Add Asset"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: FutureBuilder<List<Asset>>(
              future: Asset.find(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final assets = snapshot.data;
                  final symbols = assets.map((a) => a.symbol).toList();

                  final newCurrencies = currencies.where((currency) {
                    return !symbols.contains(currency["symbol"]);
                  }).toList();

                  return ListView.builder(
                    itemCount: newCurrencies.length,
                    itemBuilder: (BuildContext context, int index) {
                      final currency = newCurrencies[index];
                      return CurrencyListItem(
                        currency: currency,
                        onTap: (currency) {
                          Navigator.pop(context, currency);
                        },
                      );
                    },
                  );
                }

                return LoadingIndicator();
              }),
        ),
      ),
    );
  }
}
