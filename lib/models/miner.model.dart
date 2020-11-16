import "package:meta/meta.dart";

import "package:sqflite/sqflite.dart";

import "package:cryptarch/models/models.dart" show Holding;
import "package:cryptarch/services/services.dart" show DatabaseService;

class Miner {
  final String id;
  final String name;
  final String platform;
  final Holding holding;
  double profitability;

  static final String tableName = "miners";

  static final Map<String, String> tableColumns = {
    "id": "TEXT PRIMARY KEY",
    "name": "TEXT",
    "platform": "TEXT",
    "holdingId": "TEXT",
    "profitability": "REAL",
  };

  Miner({
    @required this.id,
    @required this.name,
    @required this.platform,
    @required this.holding,
    @required this.profitability,
  })  : assert(id != null),
        assert(name != null),
        assert(platform != null),
        assert(holding != null),
        assert(profitability != null);

  static Future<Miner> deserialize(Map<String, dynamic> rawMiner) async {
    final holdingId = rawMiner["holdingId"];
    final profitability = rawMiner["profitability"];

    return Miner(
      id: rawMiner["id"],
      name: rawMiner["name"],
      platform: rawMiner["platform"],
      holding: holdingId != null ? await Holding.findOneById(holdingId) : null,
      profitability: profitability != null ? profitability.toDouble() : 0.0,
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
    map["holdingId"] = this.holding.id;
    map["profitability"] = this.profitability;

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
