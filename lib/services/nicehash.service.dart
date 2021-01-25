import "dart:convert";

import "package:flutter/foundation.dart";

import "package:uuid/uuid.dart";

import "package:cryptarch/models/models.dart" show Miner, Payout;
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

class NiceHashPayout {
  final String id;
  final String currency;
  final String accountType;
  final DateTime created;
  final double amount;

  NiceHashPayout({
    @required this.id,
    @required this.currency,
    @required this.accountType,
    @required this.created,
    @required this.amount,
  })  : assert(id != null),
        assert(currency != null),
        assert(accountType != null),
        assert(created != null),
        assert(amount != null);

  factory NiceHashPayout.fromMap(Map<String, dynamic> rawPayout) {
    var currency = rawPayout["currency"];
    if (currency != null) {
      currency = currency["enumName"];
    }

    var accountType = rawPayout["accountType"];
    if (accountType != null) {
      accountType = accountType["enumName"];
    }

    final createdMillis = rawPayout["created"];
    final created = createdMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(createdMillis, isUtc: true)
        : null;

    var amount = rawPayout["amount"];
    if (amount is int) {
      amount = double.parse(amount);
    } else if (amount is String) {
      amount = double.tryParse(amount);
    } else {
      amount = 0.0;
    }

    var fee = rawPayout["feeAmount"];
    if (fee is int) {
      fee = double.parse(fee);
    } else if (fee is String) {
      fee = double.tryParse(fee);
    } else {
      fee = 0.0;
    }

    return NiceHashPayout(
      id: rawPayout["id"],
      currency: currency,
      accountType: accountType,
      created: created,
      amount: amount - fee,
    );
  }
}

class NiceHashService {
  static const String PAYOUT_USER = "USER";

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

  Future<List<NiceHashPayout>> getPayouts({
    int pageSize = 84,
    int afterMillis,
  }) async {
    final provider = await this._createProvider();
    if (provider != null) {
      final res = await provider.getRigPayouts(
        pageSize: pageSize,
        afterMillis: afterMillis,
      );
      final rawData = Map<String, dynamic>.from(jsonDecode(res.body));
      if (rawData.keys.contains("list")) {
        final rawPayouts = rawData["list"] as List;
        if (rawPayouts.isNotEmpty) {
          return List<NiceHashPayout>.from(rawPayouts.map((rawPayout) {
            return NiceHashPayout.fromMap(rawPayout);
          }));
        }
      }
    }

    return List<NiceHashPayout>();
  }

  Future<void> getPayoutHistory(
    Miner miner, {
    int afterMillis,
    Payout currentPayout,
  }) async {
    final uuid = Uuid();
    final DateTime now = DateTime.now();
    // final DateTime now = DateTime.now().subtract(Duration(days: 2));
    final int pageSize = 168; // 4 weeks * 7 days * 6 payouts per day

    // Keep track of the previous page"s last payout
    // in case the next page has payouts on the same day
    DateTime recentPayoutDate;
    DateTime lastPayoutDate; // of the current page
    List<NiceHashPayout> payouts;
    int beforeMillis = now.toUtc().millisecondsSinceEpoch;
    bool fetchMore = false;

    do {
      // Get a page of payouts
      payouts = await this.getPayouts(
        pageSize: pageSize,
        afterMillis: beforeMillis, // this is confusing
      );
      if (payouts.isEmpty) {
        break;
      }
      // Keep fetching pages until we get back less than the limit
      fetchMore = payouts.length == pageSize;
      // Aggregate payouts by day
      final Map<DateTime, Payout> daily = {};
      for (NiceHashPayout payout in payouts) {
        // Only care about payouts to the user (mining payouts)
        if (payout.accountType == NiceHashService.PAYOUT_USER) {
          // Short-circuit if payout is too old
          final createdMillis = payout.created.millisecondsSinceEpoch;
          if (afterMillis != null && createdMillis <= afterMillis) {
            fetchMore = false;
            break;
          }
          final created = payout.created.toLocal();
          final date = DateTime(created.year, created.month, created.day);
          final existingPayout = daily[date];
          if (existingPayout == null) {
            daily[date] = Payout(
              id: uuid.v1(),
              miner: miner,
              asset: miner.asset,
              date: date,
              amount: payout.amount,
            );
          } else {
            existingPayout.amount += payout.amount;
            daily[date] = existingPayout;
          }
          // If first payout of first page, set recent payout date
          if (payout.id == payouts.first.id) {
            if (recentPayoutDate == null) {
              recentPayoutDate = created;
            }
          } else if (payout.id == payouts.last.id) {
            lastPayoutDate = date;
            beforeMillis = created.millisecondsSinceEpoch;
          }
        }
      }
      // Save payouts
      for (Payout payout in daily.values) {
        // If payout is on the same day as current payout add to it instead
        if (currentPayout?.date == payout.date) {
          currentPayout.amount += payout.amount;
          await currentPayout.save();
        } else {
          await payout.save();
        }
      }
      // Set current payout to the last payout of this page
      currentPayout = daily[lastPayoutDate];
    } while (fetchMore);

    // Set recent payout date on miner
    if (recentPayoutDate != null) {
      miner.recentPayoutDate = recentPayoutDate;
      await miner.save();
    }
  }

  Future<Miner> refreshMiner(Miner miner) async {
    final account = miner.account;
    final balance = await this.getAccountBalance();
    final profitability = await this.getProfitability();

    account.amount = balance.available;
    await account.save();

    miner.profitability = profitability;
    miner.unpaidAmount = balance.pending;
    await miner.save();

    if (miner.recentPayoutDate != null) {
      final recentPayouts = await Payout.find(
        filters: {
          "minerId": miner.id,
        },
        orderBy: "date DESC",
        limit: 1,
      );
      await this.getPayoutHistory(
        miner,
        currentPayout: recentPayouts.first,
        afterMillis: miner.recentPayoutDate.toUtc().millisecondsSinceEpoch,
      );
    } else {
      await this.getPayoutHistory(miner);
    }

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
