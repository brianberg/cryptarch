import "package:http/http.dart" as http;

class EthermineProvider {
  Future<http.Response> getProfitability(String address) {
    String url = "https://api.ethermine.org/miner/$address/dashboard/payouts";
    return http.get(url);
  }
}
