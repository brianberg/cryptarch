import "package:cryptarch/models/models.dart" show Miner;
import "package:cryptarch/services/services.dart"
    show EthermineService, NiceHashService;

class MiningService {
  static Future<void> refreshMiners({Map<String, dynamic> filters}) async {
    final miners = await Miner.find(filters: filters);
    for (Miner miner in miners) {
      await MiningService.refreshMiner(miner);
    }
  }

  static Future<Miner> refreshMiner(Miner miner) async {
    if (miner.platform == "Ethermine") {
      final ethermine = EthermineService();
      return ethermine.refreshMiner(miner);
    } else if (miner.platform == "NiceHash") {
      final nicehash = NiceHashService();
      return nicehash.refreshMiner(miner);
    }

    return miner;
  }
}
