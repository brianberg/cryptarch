import "package:uuid/uuid.dart";

import "package:cryptarch/constants/constants.dart" show CURRENCIES;
import "package:cryptarch/models/models.dart" show Asset;
import "package:cryptarch/services/services.dart" show MarketsService;

class AssetService {
  static Future<Asset> addAsset(
    String symbol, {
    String exchange,
    String tokenPlatform,
    String contractAddress,
  }) async {
    double value = 0.0;
    double lastPrice = 0.0;
    double highPrice = 0.0;
    double lowPrice = 0.0;
    double percentChange = 0.0;

    final currency = CURRENCIES[symbol];

    if (currency == null) {
      throw new Exception("Unsupported asset symbol");
    }

    if (exchange == null && currency.keys.contains("exchanges")) {
      exchange = (currency["exchanges"] as List).first;
    }

    if (exchange != null) {
      final ticker = "$symbol/USD";
      final price = await MarketsService().getPrice(ticker, exchange);
      if (price != null) {
        value = price.current;
        value = price.current;
        lastPrice = price.last;
        highPrice = price.high;
        lowPrice = price.low;
        percentChange = price.percentChange;
      }
    } else {
      final price = await MarketsService().getTokenPrice(
        tokenPlatform,
        contractAddress,
        "USD",
      );
      if (price != null) {
        value = price.current;
        lastPrice = price.last;
        highPrice = price.high;
        lowPrice = price.low;
        percentChange = price.percentChange;
      }
      exchange = null;
    }

    final asset = Asset(
      id: Uuid().v1(),
      name: currency["name"],
      symbol: symbol,
      value: value,
      exchange: exchange,
      tokenPlatform: tokenPlatform,
      contractAddress: contractAddress,
      lastPrice: lastPrice,
      highPrice: highPrice,
      lowPrice: lowPrice,
      percentChange: percentChange,
    );
    await asset.save();

    return asset;
  }

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
