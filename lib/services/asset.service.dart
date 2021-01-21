import "package:uuid/uuid.dart";

import "package:cryptarch/constants/constants.dart" show CURRENCIES;
import "package:cryptarch/models/models.dart" show Asset;
import "package:cryptarch/services/services.dart" show MarketsService;

class AssetService {
  static Future<Asset> addAsset(
    String symbol, {
    String exchange,
    String blockchain,
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
    } else if (blockchain != null && contractAddress != null) {
      final price = await MarketsService().getTokenPrice(
        blockchain,
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
      type: currency["type"],
      value: value,
      exchange: exchange,
      blockchain: blockchain,
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
    final coins = await Asset.find(filters: {"type": Asset.TYPE_COIN});
    for (Asset coin in coins) {
      await AssetService.refreshPrice(coin);
    }
    final tokens = await Asset.find(filters: {"type": Asset.TYPE_TOKEN});
    for (Asset token in tokens) {
      await AssetService.refreshPrice(token);
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
    } else if (asset.blockchain != null && asset.contractAddress != null) {
      final price = await markets.getTokenPrice(
        asset.blockchain,
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
