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
        final ticker = "${asset.currency}/USD";
        final price = await markets.getPrice(ticker, asset.exchange);
        if (price != null) {
          asset.value = price.current;
        }
        if (price != null) {
          asset.lastPrice = price.last;
          asset.highPrice = price.high;
          asset.lowPrice = price.low;
          asset.percentChange = price.percentChange;
        }
      }

      await asset.save();
    }
  }
}
