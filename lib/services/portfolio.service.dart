import "package:cryptarch/models/models.dart"
    show Asset, Account, PortfolioItem;

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

  Future<double> getValue() async {
    final items = await this.getItems();
    return this.calculateValue(items);
  }
}
