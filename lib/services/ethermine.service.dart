import "dart:convert";

import "package:cryptarch/providers/providers.dart" show EthermineProvider;

class EthermineService {
  final EthermineProvider _provider = EthermineProvider();

  Future<double> getProfitability(String address) async {
    final res = await this._provider.getProfitability(address);
    final body = Map<String, dynamic>.from(jsonDecode(res.body));

    if (body != null && body.keys.contains("data")) {
      final data = body["data"];
      final estimates = data["estimates"];
      final coinsPerMin = estimates["coinsPerMin"];
      return coinsPerMin * 60 * 24;
    }

    return null;
  }
}
