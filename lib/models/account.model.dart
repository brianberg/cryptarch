import "package:meta/meta.dart";

import "package:sqflite/sqflite.dart";

import "package:cryptarch/models/models.dart" show Asset;
import "package:cryptarch/services/services.dart" show DatabaseService;

class Account {
  final String id;
  String name;
  final Asset asset;
  double amount;
  String address;

  static final String tableName = "accounts";

  static final Map<String, String> tableColumns = {
    "id": "TEXT PRIMARY KEY",
    "name": "TEXT",
    "assetId": "TEXT",
    "amount": "REAL",
    "address": "TEXT",
  };

  Account({
    @required this.id,
    @required this.name,
    @required this.asset,
    @required this.amount,
    this.address,
  })  : assert(id != null),
        assert(name != null),
        assert(asset != null),
        assert(amount != null);

  double get value {
    return this.amount * this.asset.value;
  }

  static Future<Account> deserialize(Map<String, dynamic> rawAccount) async {
    final amount = rawAccount["amount"];
    final assetId = rawAccount["assetId"];

    return Account(
      id: rawAccount["id"],
      name: rawAccount["name"],
      asset: assetId != null ? await Asset.findOneById(assetId) : null,
      amount: amount != null ? amount.toDouble() : null,
      address: rawAccount["address"],
    );
  }

  static Future<List<Account>> find({Map<String, dynamic> filters}) async {
    final List<Account> assets = new List();

    final List<Map<String, dynamic>> rawAccounts = await DatabaseService().find(
      Account.tableName,
      Account.tableColumns.keys.toList(),
      filters,
    );

    for (Map<String, dynamic> rawAccount in rawAccounts) {
      Account asset = await Account.deserialize(rawAccount);
      assets.add(asset);
    }

    return assets;
  }

  static Future<Account> findOneById(String id) async {
    final db = await DatabaseService().connect();
    final rawAccounts = await db.query(
      Account.tableName,
      columns: Account.tableColumns.keys.toList(),
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );
    if (rawAccounts.isNotEmpty) {
      return Account.deserialize(rawAccounts.first);
    }

    return null;
  }

  Map<String, dynamic> serialize() {
    final map = new Map<String, dynamic>();
    map["id"] = this.id;
    map["name"] = this.name;
    map["assetId"] = this.asset.id;
    map["amount"] = this.amount;
    map["address"] = this.address;

    return map;
  }

  Future<void> save() async {
    final db = await DatabaseService().connect();
    await db.insert(
      Account.tableName,
      this.serialize(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete() async {
    Map<String, dynamic> filters = {};
    filters["id"] = this.id;
    await DatabaseService().delete(Account.tableName, filters);
  }

  @override
  String toString() => "$name";
}
