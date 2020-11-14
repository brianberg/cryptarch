import "package:meta/meta.dart";

import "package:cryptarch/models/models.dart" show Asset, Holding;

class PortfolioItem {
  final Asset asset;
  final List<Holding> holdings;

  PortfolioItem({
    @required this.asset,
    @required this.holdings,
  })  : assert(asset != null),
        assert(holdings != null);

  double get amount {
    if (this.holdings.isEmpty) {
      return 0;
    }
    final amounts = this.holdings.map((h) => h.amount);
    return amounts.reduce((value, amount) {
      return value + amount;
    });
  }

  double get value {
    return this.amount * this.asset.value;
  }
}

class PortfolioService {
  Future<List<PortfolioItem>> getItems() async {
    final List<PortfolioItem> items = [];
    final assets = await Asset.find();
    for (Asset asset in assets) {
      Map<String, dynamic> holdingFilters = {};
      holdingFilters["currency"] = asset.currency;
      final item = PortfolioItem(
        asset: asset,
        holdings: await Holding.find(filters: holdingFilters),
      );
      items.add(item);
    }

    items.sort((a, b) => b.value.compareTo(a.value));

    return items;
  }

  double calculateValue(List<PortfolioItem> items) {
    return items.fold(0, (value, item) {
      return value + item.value;
    });
  }

  Future<double> getValue() async {
    final items = await this.getItems();
    return this.calculateValue(items);
  }
}
