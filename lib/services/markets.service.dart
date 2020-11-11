import "dart:convert";

import "package:cryptarch/providers/providers.dart" show MarketsProvider;

class MarketsService {
  final MarketsProvider _provider;

  MarketsService() : _provider = MarketsProvider();

  Future<double> getPrice(String ticker, String exchange) async {
    if (ticker == null || exchange == null) {
      return null;
    }
    final res = await this._provider.getPrice(ticker, exchange);
    final raw = Map<String, dynamic>.from(jsonDecode(res.body));
    if (raw != null && raw.keys.contains("result")) {
      final result = raw["result"];
      if (result != null && result.keys.contains("price")) {
        final price = result["price"];
        if (price is double) {
          return price;
        } else if (price is int) {
          return price.toDouble();
        }
      }
    }

    return null;
  }

  Future<double> getTokenPrice(
    String platform,
    String contractAddress,
    String currency,
  ) async {
    if (platform == null || contractAddress == null || currency == null) {
      return null;
    }
    currency = currency.toLowerCase();
    final res =
        await this._provider.getTokenPrice(platform, contractAddress, currency);
    final raw = Map<String, dynamic>.from(jsonDecode(res.body));
    if (raw != null && raw.keys.contains(contractAddress)) {
      final prices = raw[contractAddress];
      if (prices != null && prices.keys.contains(currency)) {
        final price = prices[currency];
        if (price is double) {
          return price;
        } else if (price is int) {
          return price.toDouble();
        }
      }
    }

    return null;
  }
}
