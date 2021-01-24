import "package:cryptarch/models/models.dart"
    show Asset, Account, PortfolioItem, Transaction;

class PortfolioService {
  Future<List<PortfolioItem>> getItems() async {
    final List<PortfolioItem> items = [];
    final assets = await Asset.find();
    for (Asset asset in assets) {
      final accounts = await Account.find(filters: {"assetId": asset.id});
      if (accounts.length > 0) {
        final item = PortfolioItem(
          asset: asset,
          accounts: accounts,
        );
        items.add(item);
      }
    }

    items.sort((a, b) => 0 - a.value.compareTo(b.value));

    return items;
  }

  double calculateValue(List<PortfolioItem> items) {
    return items.fold(0, (value, item) {
      return value + item.value;
    });
  }

  double calculateValueChange(List<PortfolioItem> items) {
    return items.fold(0, (value, item) {
      return value + item.valueChange;
    });
  }

  Future<double> getValue() async {
    final items = await this.getItems();
    return this.calculateValue(items);
  }

  Future<double> getValueChange() async {
    final items = await this.getItems();
    return this.calculateValueChange(items);
  }

  Future<double> getTotalReturn() async {
    final trades = await Transaction.find(filters: {
      "type": [Transaction.TYPE_BUY, Transaction.TYPE_SELL],
    });

    if (trades.isEmpty) {
      return null;
    }

    final portfolioValue = await this.getValue();
    final totalSpent = trades.fold(0.0, (total, trade) {
      if (trade.type == Transaction.TYPE_BUY) {
        total += trade.total;
      } else if (trade.type == Transaction.TYPE_SELL) {
        total -= trade.total;
      }
      return total;
    });

    return portfolioValue - totalSpent;
  }
}
