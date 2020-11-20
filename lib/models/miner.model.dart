import "package:meta/meta.dart";

import "package:sqflite/sqflite.dart";

import "package:cryptarch/models/models.dart" show Asset, Holding;
import "package:cryptarch/services/services.dart" show DatabaseService;

const ENERGY_COST = 0.00774; // TODO: set via settings

class Miner {
  final String id;
  String name;
  final String platform;
  final Asset asset;
  final Holding holding;
  double profitability;
  double energy;
  bool active;

  static final String tableName = "miners";

  static final Map<String, String> tableColumns = {
    "id": "TEXT PRIMARY KEY",
    "name": "TEXT",
    "platform": "TEXT",
    "assetId": "TEXT",
    "holdingId": "TEXT",
    "profitability": "REAL",
    "energy": "REAL",
    "active": "INTEGER",
  };

  Miner({
    @required this.id,
    @required this.name,
    @required this.platform,
    @required this.asset,
    @required this.holding,
    @required this.profitability,
    @required this.energy,
    @required this.active,
  })  : assert(id != null),
        assert(name != null),
        assert(platform != null),
        assert(holding != null),
        assert(profitability != null),
        assert(energy != null),
        assert(active != null);

  static Future<Miner> deserialize(Map<String, dynamic> rawMiner) async {
    final assetId = rawMiner["assetId"];
    final holdingId = rawMiner["holdingId"];
    final profitability = rawMiner["profitability"];
    final energy = rawMiner["energy"];

    return Miner(
      id: rawMiner["id"],
      name: rawMiner["name"],
      platform: rawMiner["platform"],
      asset: assetId != null ? await Asset.findOneById(assetId) : null,
      holding: holdingId != null ? await Holding.findOneById(holdingId) : null,
      profitability: profitability != null ? profitability.toDouble() : 0.0,
      energy: energy != null ? energy.toDouble() : 0.0,
      active: rawMiner["active"] == 1,
    );
  }

  static Future<List<Miner>> find({Map<String, dynamic> filters}) async {
    final List<Miner> assets = new List();

    final List<Map<String, dynamic>> rawMiners = await DatabaseService().find(
      Miner.tableName,
      Miner.tableColumns.keys.toList(),
      filters,
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
    map["holdingId"] = this.holding.id;
    map["profitability"] = this.profitability;
    map["energy"] = this.energy;
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

  double calculateFiatProfitability() {
    final cost = this.energy * ENERGY_COST;
    return this.profitability * this.asset.value - cost;
  }
}
