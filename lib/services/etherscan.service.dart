import "dart:convert";

import "package:cryptarch/providers/providers.dart" show EtherscanProvider;

class EtherscanService {
  final EtherscanProvider _provider = EtherscanProvider();

  Future<double> getBalance(String address) async {
    final res = await this._provider.getBalance(address);
    final body = Map<String, dynamic>.from(jsonDecode(res.body));

    if (body != null && body.keys.contains("result")) {
      final balance = int.tryParse(body["result"]);
      if (balance != null) {
        return balance / 1000000000000000000;
      }
    }

    return null;
  }
}
