import "package:http/http.dart" as http;

class EthermineProvider {
  Future<http.Response> getDashboard(String address) {
    String url = "https://api.ethermine.org/miner/$address/dashboard";
    return http.get(url);
  }

  Future<http.Response> getDashboardPayouts(String address) {
    String url = "https://api.ethermine.org/miner/$address/dashboard/payouts";
    return http.get(url);
  }

  Future<http.Response> getPayouts(String address) {
    String url = "https://api.ethermine.org/miner/$address/payouts";
    return http.get(url);
  }
}
