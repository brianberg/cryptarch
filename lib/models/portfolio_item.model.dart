import "package:meta/meta.dart";

import "package:cryptarch/models/models.dart" show Account, Asset;

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

  double get valueChange {
    final previousValue = value / (1 + this.asset.percentChange / 100);
    return value - previousValue;
  }
}
