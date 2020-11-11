import "dart:convert";

import "package:cryptarch/providers/providers.dart" show MarketsProvider;

class MarketsService {
  final MarketsProvider _provider;

  MarketsService() : _provider = MarketsProvider();

  Future<double> getPrice(String ticker, String exchange) async {
    final res = await this._provider.getPrice(ticker, exchange);
    final raw = Map<String, dynamic>.from(jsonDecode(res.body));
    final result = raw["result"];
    return result["price"];
  }
}
