import "package:flutter/foundation.dart";

import "package:sqflite/sqflite.dart";

import "package:cryptarch/services/services.dart" show DatabaseService;

class Asset {
  final String id;
  final String name;
  final String currency;
  final double value;
  final String exchange;

  static final String tableName = "assets";

  static final Map<String, String> tableColumns = {
    "id": "TEXT PRIMARY KEY",
    "name": "TEXT",
    "currency": "TEXT",
    "value": "REAL",
    "exchange": "TEXT",
  };

  Asset({
    @required this.id,
    @required this.name,
    @required this.currency,
    @required this.value,
    @required this.exchange,
  })  : assert(id != null),
        assert(name != null),
        assert(currency != null),
        assert(value != null),
        assert(exchange != null);

  static Future<Asset> deserialize(Map<String, dynamic> rawAsset) async {
    final value = rawAsset["value"];
    return Asset(
      id: rawAsset["id"],
      name: rawAsset["name"],
      currency: rawAsset["currency"],
      value: value != null ? value.toDouble() : null,
      exchange: rawAsset["exchange"],
    );
  }

  static Future<List<Asset>> find({Map<String, dynamic> filters}) async {
    final List<Asset> assets = new List();

    final List<Map<String, dynamic>> rawAssets = await DatabaseService().find(
      Asset.tableName,
      Asset.tableColumns.keys.toList(),
      filters,
    );

    for (Map<String, dynamic> rawAsset in rawAssets) {
      Asset price = await Asset.deserialize(rawAsset);
      assets.add(price);
    }

    return assets;
  }

  static Future<Asset> findOneById(String id) async {
    final db = await DatabaseService().connect();
    final rawAssets = await db.query(
      Asset.tableName,
      columns: Asset.tableColumns.keys.toList(),
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );
    if (rawAssets.isNotEmpty) {
      return Asset.deserialize(rawAssets.first);
    }

    return null;
  }

  static Future<Asset> findOneByCurrency(String currency) async {
    final db = await DatabaseService().connect();
    final rawAssets = await db.query(
      Asset.tableName,
      columns: Asset.tableColumns.keys.toList(),
      where: "currency = ?",
      whereArgs: [currency],
      limit: 1,
    );
    if (rawAssets.isNotEmpty) {
      return Asset.deserialize(rawAssets.first);
    }

    return null;
  }

  Map<String, dynamic> serialize() {
    final map = new Map<String, dynamic>();
    map["id"] = this.id;
    map["name"] = this.name;
    map["currency"] = this.currency;
    map["value"] = this.value;
    map["exchange"] = this.exchange;

    return map;
  }

  Future<void> save() async {
    final db = await DatabaseService().connect();
    await db.insert(
      Asset.tableName,
      this.serialize(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete() async {
    Map<String, dynamic> filters = {};
    filters["id"] = this.id;
    await DatabaseService().delete(Asset.tableName, filters);
  }

  @override
  String toString() => "$name";
}
