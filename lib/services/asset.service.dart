import "package:cryptarch/models/models.dart" show Asset;
import "package:cryptarch/services/services.dart" show MarketsService;

class AssetService {
  static Future<void> refreshPrices() async {
    final assets = await Asset.find();
    for (Asset asset in assets) {
      await AssetService.refreshPrice(asset);
    }
  }

  static Future<Asset> refreshPrice(Asset asset) async {
    final markets = MarketsService();
    if (asset.exchange != null) {
      final ticker = "${asset.symbol}/USD";
      final price = await markets.getPrice(ticker, asset.exchange);
      if (price != null) {
        asset.value = price.current;
        asset.lastPrice = price.last ?? asset.lastPrice;
        asset.highPrice = price.high ?? asset.highPrice;
        asset.lowPrice = price.low ?? asset.lowPrice;
        asset.percentChange = price.percentChange ?? asset.percentChange;
      }
    } else if (asset.isToken) {
      final price = await markets.getTokenPrice(
        asset.tokenPlatform,
        asset.contractAddress,
        "USD",
      );
      if (price != null) {
        asset.value = price.current;
        asset.percentChange = price.percentChange;
      }
    }

    await asset.save();

    return asset;
  }
}
