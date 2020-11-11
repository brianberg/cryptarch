import "package:http/http.dart" as http;

class MarketsProvider {
  Future<http.Response> getPrice(String ticker, String exchange) {
    ticker = ticker.replaceAll("/", "").toLowerCase();
    exchange = exchange.replaceAll(" ", "-").toLowerCase();
    String url = "https://api.cryptowat.ch/markets/$exchange/$ticker/price";
    return http.get(url);
  }

  Future<http.Response> getTokenPrice(
    String platform,
    String contractAddress,
    String currency,
  ) {
    platform = platform.toLowerCase();
    String url =
        "https://api.coingecko.com/api/v3/simple/token_price/$platform?contract_addresses=$contractAddress&vs_currencies=$currency";
    return http.get(url);
  }
}
