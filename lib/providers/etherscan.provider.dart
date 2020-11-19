import "package:http/http.dart" as http;

const API_TOKEN = "5YIRWG4WP5X487YMQCR8455M453CXQ1DHW";

class EtherscanProvider {
  Future<http.Response> getBalance(String address) {
    String url =
        "https://api.etherscan.io/api?module=account&action=balance&address=$address&tag=latest&apikey=$API_TOKEN";
    return http.get(url);
  }
}
