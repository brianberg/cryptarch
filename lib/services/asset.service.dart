import "package:cryptarch/models/models.dart" show Asset;
import "package:cryptarch/services/services.dart" show MarketsService;

class AssetService {
  Future<void> refreshPrices() async {
    final markets = MarketsService();
    final assets = await Asset.find();
    for (Asset asset in assets) {
      if (asset.tokenPlatform != null) {
        final price = await markets.getTokenPrice(
          asset.tokenPlatform,
          asset.contractAddress,
          "USD",
        );
        if (price != null) {
          asset.value = price.current;
          asset.percentChange = price.percentChange;
        }
      } else {
        final ticker = "${asset.symbol}/USD";
        final price = await markets.getPrice(ticker, asset.exchange);
        if (price != null) {
          asset.value = price.current;
          asset.lastPrice = price.last ?? asset.lastPrice;
          asset.highPrice = price.high ?? asset.highPrice;
          asset.lowPrice = price.low ?? asset.lowPrice;
          asset.percentChange = price.percentChange ?? asset.percentChange;
        }
      }

      await asset.save();
    }
  }
}
