import "package:meta/meta.dart";

import "package:cryptarch/models/models.dart" show Asset, Account;

class PortfolioItem {
  final Asset asset;
  final List<Account> accounts;

  PortfolioItem({
    @required this.asset,
    @required this.accounts,
  })  : assert(asset != null),
        assert(accounts != null);

  double get amount {
    if (this.accounts.isEmpty) {
      return 0;
    }
    final amounts = this.accounts.map((h) => h.amount);
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
      Map<String, dynamic> accountFilters = {};
      accountFilters["assetId"] = asset.id;
      final item = PortfolioItem(
        asset: asset,
        accounts: await Account.find(filters: accountFilters),
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
