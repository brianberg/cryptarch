import "dart:convert";

import "package:cryptarch/models/models.dart" show Miner;
import "package:cryptarch/providers/providers.dart" show EthermineProvider;
import "package:cryptarch/services/services.dart" show EtherscanService;

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

  Future<Miner> refreshMiner(Miner miner) async {
    final holding = miner.holding;

    if (holding.address != null) {
      final etherscan = EtherscanService();
      final balance = await etherscan.getBalance(holding.address);
      final profitability = await this.getProfitability(holding.address);

      holding.amount = balance;
      await holding.save();

      miner.profitability = profitability;
      await miner.save();
    }

    return miner;
  }
}
