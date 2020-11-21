import "dart:convert";

import "package:meta/meta.dart";

import "package:cryptarch/providers/providers.dart" show MarketsProvider;

class Price {
  final double current;
  final double last;
  final double high;
  final double low;
  final double percentChange;
  final double absoluteChange;

  Price({
    @required this.current,
    this.percentChange,
    this.last,
    this.high,
    this.low,
    this.absoluteChange,
  }) : assert(current != null);
}

class MarketsService {
  final MarketsProvider _provider;

  MarketsService() : _provider = MarketsProvider();

  Future<Price> getPrice(String ticker, String exchange) async {
    if (ticker == null || exchange == null) {
      return null;
    }

    double current = 0.0;
    double last;
    double high;
    double low;
    double percentChange;
    double absoluteChange;

    final priceResponse = await this._provider.getPrice(ticker, exchange);
    final rawPriceBody =
        Map<String, dynamic>.from(jsonDecode(priceResponse.body));

    if (rawPriceBody == null || rawPriceBody.keys.contains("error")) {
      return null;
    }

    if (rawPriceBody.keys.contains("result")) {
      final result = rawPriceBody["result"];
      if (result != null && result.keys.contains("price")) {
        final rawPrice = result["price"];
        if (rawPrice is double) {
          current = rawPrice;
        } else if (rawPrice is int) {
          current = rawPrice.toDouble();
        }
      }
    }

    final summaryResponse =
        await this._provider.getPriceSummary(ticker, exchange);
    final rawSummaryBody =
        Map<String, dynamic>.from(jsonDecode(summaryResponse.body));

    if (rawSummaryBody != null && rawSummaryBody.keys.contains("result")) {
      final result = rawSummaryBody["result"];
      if (result != null && result.keys.contains("price")) {
        final priceInfo = result["price"];
        final changeInfo = priceInfo["change"];
        var rawLast = priceInfo["last"];
        var rawHigh = priceInfo["high"];
        var rawLow = priceInfo["low"];
        var rawPercentage = changeInfo["percentage"];
        var rawAbsolute = changeInfo["absolute"];
        if (rawLast is int) {
          rawLast = rawLast.toDouble();
        }
        if (rawHigh is int) {
          rawHigh = rawHigh.toDouble();
        }
        if (rawLow is int) {
          rawLow = rawLow.toDouble();
        }
        if (rawPercentage is int) {
          rawPercentage = rawPercentage.toDouble();
        }
        if (rawAbsolute is int) {
          rawAbsolute = rawAbsolute.toDouble();
        }
        last = rawLast;
        high = rawHigh;
        low = rawLow;
        percentChange = rawPercentage * 100;
        absoluteChange = rawAbsolute;
      }
    }

    return Price(
      current: current,
      last: last,
      high: high,
      low: low,
      percentChange: percentChange,
      absoluteChange: absoluteChange,
    );
  }

  Future<Price> getTokenPrice(
    String platform,
    String contractAddress,
    String symbol,
  ) async {
    if (platform == null || contractAddress == null || symbol == null) {
      return null;
    }

    double current = 0.0;
    double percentChange;

    symbol = symbol.toLowerCase();

    final res = await this._provider.getTokenPrice(
          platform,
          contractAddress,
          symbol,
        );
    final raw = Map<String, dynamic>.from(jsonDecode(res.body));
    if (raw != null && raw.keys.contains(contractAddress)) {
      final prices = raw[contractAddress];
      if (prices != null) {
        if (prices.keys.contains(symbol)) {
          var rawPrice = prices[symbol];
          if (rawPrice is int) {
            rawPrice = rawPrice.toDouble();
          }
          current = rawPrice;
        }
        if (prices.keys.contains("${symbol}_24h_change")) {
          var rawChange = prices["${symbol}_24h_change"];
          if (rawChange is int) {
            rawChange = rawChange.toDouble();
          }
          percentChange = rawChange;
        }
      }
    }

    return Price(current: current, percentChange: percentChange);
  }
}
