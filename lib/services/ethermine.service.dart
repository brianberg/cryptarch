import "dart:convert";

import "package:cryptarch/models/models.dart" show Miner;
import "package:cryptarch/providers/providers.dart" show EthermineProvider;
import "package:cryptarch/services/services.dart" show EtherscanService;

const ETH_IN_WEI = 0.000000000000000001;

class EthermineService {
  final EthermineProvider _provider = EthermineProvider();

  Future<double> getProfitability(String address) async {
    final res = await this._provider.getPayouts(address);
    final body = Map<String, dynamic>.from(jsonDecode(res.body));

    if (body != null && body.keys.contains("data")) {
      final data = body["data"];
      final estimates = data["estimates"];
      final coinsPerMin = estimates["coinsPerMin"];
      return coinsPerMin * 60 * 24;
    }

    return 0.0;
  }

  Future<double> getUnpaid(String address) async {
    final res = await this._provider.getDashboard(address);
    final body = Map<String, dynamic>.from(jsonDecode(res.body));

    if (body != null && body.keys.contains("data")) {
      final data = body["data"];
      final stats = data["currentStatistics"];
      final unpaidWei = stats["unpaid"];
      return unpaidWei * ETH_IN_WEI;
    }

    return 0.0;
  }

  Future<Miner> refreshMiner(Miner miner) async {
    final account = miner.account;

    if (account.address != null) {
      final etherscan = EtherscanService();
      final balance = await etherscan.getBalance(account.address);
      final profitability = await this.getProfitability(account.address);
      final unpaid = await this.getUnpaid(account.address);

      account.amount = balance;
      await account.save();

      miner.profitability = profitability;
      miner.unpaidAmount = unpaid;
      await miner.save();
    }

    return miner;
  }
}
