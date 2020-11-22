import "package:cryptarch/models/models.dart"
    show Asset, Account, PortfolioItem;

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
