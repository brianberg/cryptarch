import "package:http/http.dart" as http;

class MarketsProvider {
  Future<http.Response> getPrice(String ticker, String exchange) {
    if (ticker == null || exchange == null) {
      return null;
    }
    ticker = ticker.replaceAll("/", "").toLowerCase();
    exchange = exchange.replaceAll(" ", "-").toLowerCase();
    String url = "https://api.cryptowat.ch/markets/$exchange/$ticker/price";
    return http.get(url);
  }
}
