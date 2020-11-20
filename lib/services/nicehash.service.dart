import "dart:convert";

import "package:meta/meta.dart";

import "package:cryptarch/models/models.dart" show Miner;
import "package:cryptarch/providers/providers.dart" show NiceHashProvider;
import "package:cryptarch/services/services.dart" show StorageService;

class NiceHashBalance {
  final double available;
  final double pending;
  final double total;

  NiceHashBalance({
    @required this.available,
    @required this.pending,
    @required this.total,
  })  : assert(available != null),
        assert(pending != null),
        assert(total != null);

  factory NiceHashBalance.fromMap(Map<String, dynamic> rawAccount) {
    final available = double.parse(rawAccount["available"]);
    final pending = double.parse(rawAccount["pending"]);
    final total = double.parse(rawAccount["totalBalance"]);

    return NiceHashBalance(
      available: available,
      pending: pending,
      total: total,
    );
  }
}

class NiceHashRig {
  final String id;
  final String name;
  final double profitability;

  NiceHashRig({
    @required this.id,
    @required this.name,
    @required this.profitability,
  })  : assert(id != null),
        assert(name != null),
        assert(profitability != null);

  factory NiceHashRig.fromMap(Map<String, dynamic> rawRig) {
    var profitability = rawRig["profitability"];
    if (profitability is int) {
      profitability = profitability.toDouble();
    }
    return NiceHashRig(
      id: rawRig["rigId"],
      name: rawRig["name"],
      profitability: profitability,
    );
  }
}

class NiceHashService {
  Future<NiceHashBalance> getAccountBalance() async {
    final provider = await this._createProvider();
    if (provider != null) {
      final res = await provider.getAccounts();
      final rawAccounts = Map<String, dynamic>.from(jsonDecode(res.body));
      if (rawAccounts.keys.contains("total")) {
        final totalAccount = rawAccounts["total"];
        return NiceHashBalance.fromMap(totalAccount);
      }
    }

    return NiceHashBalance(available: 0.0, pending: 0.0, total: 0.0);
  }

  Future<double> getProfitability() async {
    final provider = await this._createProvider();
    if (provider != null) {
      final res = await provider.getMiningRigs();
      final rawRigsData = Map<String, dynamic>.from(jsonDecode(res.body));
      if (rawRigsData.keys.contains("miningRigs")) {
        final rawRigs = rawRigsData["miningRigs"] as List;
        final rigs = List<NiceHashRig>.from(
          rawRigs.map((rawRig) {
            return NiceHashRig.fromMap(rawRig);
          }),
        );

        return rigs.fold<double>(0.0, (value, rig) {
          return value + rig.profitability;
        });
      }
    }

    return 0.0;
  }

  Future<Miner> refreshMiner(Miner miner) async {
    final holding = miner.holding;
    final balance = await this.getAccountBalance();
    final profitability = await this.getProfitability();

    holding.amount = balance.available;
    await holding.save();

    miner.profitability = profitability;
    await miner.save();

    return miner;
  }

  Future<NiceHashProvider> _createProvider() async {
    final credentials = await StorageService.getItem("nicehash");
    if (credentials != null) {
      return NiceHashProvider(
        organizationId: credentials["organization_id"],
        key: credentials["api_key"],
        secret: credentials["api_secret"],
      );
    }
    return null;
  }
}
