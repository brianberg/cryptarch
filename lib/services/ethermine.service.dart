import "dart:convert";

import "package:flutter/foundation.dart";

import "package:uuid/uuid.dart";

import "package:cryptarch/models/models.dart" show Miner, Payout;
import "package:cryptarch/providers/providers.dart" show EthermineProvider;
import "package:cryptarch/services/services.dart" show EtherscanService;

const ETH_IN_WEI = 0.000000000000000001;
const MS_IN_S = 1000;

class EtherminePayout {
  final double amount;
  final DateTime created;
  final String txHash;

  EtherminePayout({
    @required this.amount,
    @required this.created,
    @required this.txHash,
  })  : assert(amount != null),
        assert(created != null),
        assert(txHash != null);

  factory EtherminePayout.fromMap(Map<String, dynamic> rawPayout) {
    final amountWei = rawPayout["amount"];
    final createdSeconds = rawPayout["paidOn"];

    final amount = amountWei != null ? amountWei * ETH_IN_WEI : 0.0;
    final createdMillis =
        createdSeconds != null ? createdSeconds * MS_IN_S : null;
    final created = createdMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(createdMillis, isUtc: true)
        : null;

    return EtherminePayout(
      amount: amount,
      created: created,
      txHash: rawPayout["txHash"],
    );
  }
}

class EthermineService {
  final EthermineProvider _provider = EthermineProvider();

  Future<List<EtherminePayout>> getPayouts(String address) async {
    final res = await this._provider.getPayouts(address);
    final rawData = Map<String, dynamic>.from(jsonDecode(res.body));
    if (rawData.keys.contains("data")) {
      final rawPayouts = rawData["data"] as List;
      if (rawPayouts.isNotEmpty) {
        return List<EtherminePayout>.from(rawPayouts.map((rawPayout) {
          return EtherminePayout.fromMap(rawPayout);
        }));
      }
    }

    return List<EtherminePayout>();
  }

  Future<double> getProfitability(String address) async {
    final res = await this._provider.getDashboardPayouts(address);
    final body = Map<String, dynamic>.from(jsonDecode(res.body));

    if (body != null && body.keys.contains("data")) {
      final data = body["data"];
      final estimates = data["estimates"];
      final coinsPerMin = estimates["coinsPerMin"];
      if (coinsPerMin != null) {
        return coinsPerMin * 60 * 24;
      }
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

  Future<void> getPayoutHistory(
    Miner miner, {
    int afterMillis,
  }) async {
    final uuid = Uuid();
    final payouts = await this.getPayouts(miner.account.address);
    final DateTime recentPayoutDate =
        payouts.isNotEmpty ? payouts.first.created : null;
    for (EtherminePayout payout in payouts) {
      final createdMillis = payout.created.millisecondsSinceEpoch;
      if (afterMillis != null && createdMillis <= afterMillis) {
        break;
      }
      final created = payout.created.toLocal();

      final date = DateTime(created.year, created.month, created.day);
      final miningPayout = Payout(
        id: uuid.v1(),
        miner: miner,
        asset: miner.asset,
        date: date,
        amount: payout.amount,
      );
      await miningPayout.save();
    }

    if (recentPayoutDate != null) {
      miner.recentPayoutDate = recentPayoutDate.toLocal();
      await miner.save();
    }
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

      if (miner.recentPayoutDate != null) {
        await this.getPayoutHistory(
          miner,
          afterMillis: miner.recentPayoutDate.toUtc().millisecondsSinceEpoch,
        );
      } else {
        await this.getPayoutHistory(miner);
      }
    }

    return miner;
  }
}
