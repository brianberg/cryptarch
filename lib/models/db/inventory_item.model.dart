import "package:flutter/foundation.dart";

import "package:sqflite/sqflite.dart";

import "package:cryptarch/models/models.dart" show Miner;
import "package:cryptarch/services/services.dart" show DatabaseService;

class InventoryItem {
  final String id;
  String name;
  double cost;
  double value;
  int quantity;
  Miner miner;

  static final String tableName = "inventory_items";

  static final Map<String, String> tableColumns = {
    "id": "TEXT PRIMARY KEY",
    "name": "TEXT",
    "cost": "REAL",
    "value": "REAL",
    "quantity": "INTEGER",
    "minerId": "TEXT",
  };

  InventoryItem({
    @required this.id,
    @required this.name,
    @required this.cost,
    this.value = 0.0,
    this.quantity = 1,
    this.miner,
  })  : assert(id != null),
        assert(name != null),
        assert(cost != null),
        assert(value != null),
        assert(quantity != null);

  double get totalCost {
    return this.cost * this.quantity; 
  }

  static Future<InventoryItem> deserialize(
    Map<String, dynamic> rawItem,
  ) async {
    final cost = rawItem["cost"];
    final value = rawItem["value"];
    final quantity = rawItem["quantity"];
    final minerId = rawItem["minerId"];

    return InventoryItem(
      id: rawItem["id"],
      name: rawItem["name"],
      cost: cost != null ? cost.toDouble() : 0.0,
      value: value != null ? value.toDouble() : 0.0,
      quantity: quantity,
      miner: minerId != null ? await Miner.findOneById(minerId) : null,
    );
  }

  static Future<List<InventoryItem>> find({
    Map<String, dynamic> filters,
    String orderBy,
    int limit,
    int offset,
  }) async {
    final List<InventoryItem> assets = new List();

    final List<Map<String, dynamic>> rawItems = await DatabaseService().find(
      InventoryItem.tableName,
      InventoryItem.tableColumns.keys.toList(),
      filters,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    for (Map<String, dynamic> rawItem in rawItems) {
      InventoryItem price = await InventoryItem.deserialize(rawItem);
      assets.add(price);
    }

    return assets;
  }

  static Future<InventoryItem> findOneById(String id) async {
    final db = await DatabaseService().connect();
    final rawItems = await db.query(
      InventoryItem.tableName,
      columns: InventoryItem.tableColumns.keys.toList(),
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );
    if (rawItems.isNotEmpty) {
      return InventoryItem.deserialize(rawItems.first);
    }

    return null;
  }

  Map<String, dynamic> serialize() {
    final map = new Map<String, dynamic>();
    map["id"] = this.id;
    map["name"] = this.name;
    map["cost"] = this.cost;
    map["value"] = this.value;
    map["quantity"] = this.quantity;
    map["minerId"] = this.miner?.id;

    return map;
  }

  Future<void> save() async {
    final db = await DatabaseService().connect();
    await db.insert(
      InventoryItem.tableName,
      this.serialize(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete() async {
    Map<String, dynamic> filters = {};
    filters["id"] = this.id;
    await DatabaseService().delete(InventoryItem.tableName, filters);
  }

  @override
  String toString() => "$name";
}
