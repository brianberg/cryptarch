import "package:meta/meta.dart";

import "package:sqflite/sqflite.dart";

import "package:cryptarch/models/models.dart" show Asset, Account;
import "package:cryptarch/services/services.dart" show DatabaseService;

const ENERGY_COST = 0.07746; // TODO: set via settings

class Miner {
  final String id;
  String name;
  final String platform;
  final Asset asset;
  final Account account;
  double profitability;
  double energy;
  bool active;
  double unpaidAmount;

  static final String tableName = "miners";

  static final Map<String, String> tableColumns = {
    "id": "TEXT PRIMARY KEY",
    "name": "TEXT",
    "platform": "TEXT",
    "assetId": "TEXT",
    "accountId": "TEXT",
    "profitability": "REAL",
    "energy": "REAL",
    "active": "INTEGER",
    "unpaidAmount": "REAL",
  };

  Miner({
    @required this.id,
    @required this.name,
    @required this.platform,
    @required this.asset,
    @required this.account,
    @required this.profitability,
    @required this.energy,
    @required this.active,
    @required this.unpaidAmount,
  })  : assert(id != null),
        assert(name != null),
        assert(platform != null),
        assert(account != null),
        assert(profitability != null),
        assert(energy != null),
        assert(active != null),
        assert(unpaidAmount != null);

  double get fiatProfitability {
    final cost = this.energy * ENERGY_COST;
    return (this.profitability * this.asset.value) - cost;
  }

  double get fiatUnpaidAmount {
    return this.unpaidAmount * this.asset.value;
  }

  static Future<Miner> deserialize(Map<String, dynamic> rawMiner) async {
    final assetId = rawMiner["assetId"];
    final accountId = rawMiner["accountId"];
    final profitability = rawMiner["profitability"];
    final energy = rawMiner["energy"];
    final unpaid = rawMiner["unpaidAmount"];

    return Miner(
      id: rawMiner["id"],
      name: rawMiner["name"],
      platform: rawMiner["platform"],
      asset: assetId != null ? await Asset.findOneById(assetId) : null,
      account: accountId != null ? await Account.findOneById(accountId) : null,
      profitability: profitability != null ? profitability.toDouble() : 0.0,
      energy: energy != null ? energy.toDouble() : 0.0,
      unpaidAmount: unpaid != null ? unpaid.toDouble() : 0.0,
      active: rawMiner["active"] == 1,
    );
  }

  static Future<List<Miner>> find({
    Map<String, dynamic> filters,
    String orderBy,
    int limit,
    int offset,
  }) async {
    final List<Miner> assets = new List();

    final List<Map<String, dynamic>> rawMiners = await DatabaseService().find(
      Miner.tableName,
      Miner.tableColumns.keys.toList(),
      filters,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    for (Map<String, dynamic> rawMiner in rawMiners) {
      Miner price = await Miner.deserialize(rawMiner);
      assets.add(price);
    }

    return assets;
  }

  static Future<Miner> findOneById(String id) async {
    final db = await DatabaseService().connect();
    final rawMiners = await db.query(
      Miner.tableName,
      columns: Miner.tableColumns.keys.toList(),
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );
    if (rawMiners.isNotEmpty) {
      return Miner.deserialize(rawMiners.first);
    }

    return null;
  }

  Map<String, dynamic> serialize() {
    final map = new Map<String, dynamic>();
    map["id"] = this.id;
    map["name"] = this.name;
    map["platform"] = this.platform;
    map["assetId"] = this.asset.id;
    map["accountId"] = this.account.id;
    map["profitability"] = this.profitability;
    map["energy"] = this.energy;
    map["unpaidAmount"] = this.unpaidAmount;
    map["active"] = this.active ? 1 : 0;

    return map;
  }

  Future<void> save() async {
    final db = await DatabaseService().connect();
    await db.insert(
      Miner.tableName,
      this.serialize(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete() async {
    Map<String, dynamic> filters = {};
    filters["id"] = this.id;
    await DatabaseService().delete(Miner.tableName, filters);
  }

  @override
  String toString() => "$name";
}
