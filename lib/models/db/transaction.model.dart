import "package:flutter/foundation.dart";

import "package:sqflite/sqflite.dart";
import "package:uuid/uuid.dart";

import "package:cryptarch/models/models.dart" show Asset;
import "package:cryptarch/services/services.dart" show DatabaseService;

class Transaction {
  final String id;
  final String type;
  final DateTime date;
  String transactionId;
  String comment;
  // Sent
  String sendAccount;
  String sentAddress;
  Asset sentAsset;
  double sentQuantity;
  // Receive
  String receivedAccount;
  String receivedAddress;
  Asset receivedAsset;
  double receivedQuantity;
  // Fee
  Asset feeAsset;
  double feeQuantity;

  static final String tableName = "transactions";

  static final Map<String, String> tableColumns = {
    "id": "TEXT PRIMARY KEY",
    "type": "TEXT",
    "date": "INTEGER",
    "transactionId": "TEXT",
    "comment": "TEXT",
    "sendAccount": "TEXT",
    "sentAddress": "TEXT",
    "sentAssetId": "TEXT",
    "sentQuantity": "REAL",
    "receivedAccount": "TEXT",
    "receivedAddress": "TEXT",
    "receivedAssetId": "TEXT",
    "receivedQuantity": "REAL",
    "feeAssetId": "TEXT",
    "feeQuantity": "REAL",
  };

  static const TYPE_BUY = "buy";
  static const TYPE_CONVERT = "convert";
  static const TYPE_RECEIVE = "received";
  static const TYPE_SELL = "sell";
  static const TYPE_SEND = "send";

  Transaction({
    @required this.id,
    @required this.type,
    @required this.date,
    this.transactionId,
    this.comment,
    this.sendAccount,
    this.sentAddress,
    this.sentAsset,
    this.sentQuantity = 0.0,
    this.receivedAccount,
    this.receivedAddress,
    this.receivedAsset,
    this.receivedQuantity = 0.0,
    this.feeAsset,
    this.feeQuantity = 0.0,
  })  : assert(id != null),
        assert(type != null),
        assert(date != null);

  double get rate {
    switch (this.type) {
      case Transaction.TYPE_CONVERT:
      case Transaction.TYPE_SELL:
        return this.receivedQuantity / this.sentQuantity;
      default:
        return this.sentQuantity / this.receivedQuantity;
    }
  }

  double get total {
    switch (this.type) {
      case Transaction.TYPE_CONVERT:
        if (this.feeAsset.id == this.sentAsset.id) {
          return this.sentQuantity - this.feeQuantity;
        }
        return this.receivedQuantity - this.feeQuantity;
      default:
        if (this.feeAsset.id == this.sentAsset.id) {
          return this.sentQuantity + this.feeQuantity;
        }
        return this.receivedQuantity - this.feeQuantity;
    }
  }

  double get currentValue {
    switch (this.type) {
      case Transaction.TYPE_BUY:
        return this.receivedAsset.value * this.receivedQuantity;
      case Transaction.TYPE_SELL:
        return this.sentAsset.value * this.sentQuantity;
      case Transaction.TYPE_CONVERT:
        return this.receivedAsset.value * this.receivedQuantity;
      default:
        return 0.0;
    }
  }

  double get returnValue {
    switch (type) {
      case Transaction.TYPE_BUY:
        return this.currentValue - this.total;
      case Transaction.TYPE_SELL:
        return this.currentValue - this.total;
      case Transaction.TYPE_CONVERT:
        final sentValue = this.sentAsset.value * this.sentQuantity;
        final totalValue = this.receivedAsset.value * this.total;
        return totalValue - sentValue;
      default:
        return 0.0;
    }
  }

  factory Transaction.fromCsv(
    List<dynamic> rawRow, {
    Asset receivedAsset,
    Asset sentAsset,
    Asset feeAsset,
  }) {
    if (rawRow.isEmpty || rawRow.length < 10) {
      throw Exception("Malformed transaction row");
    }

    var receivedQuantity = rawRow[2];
    if (receivedQuantity is String) {
      receivedQuantity = double.parse(receivedQuantity);
    } else if (receivedQuantity is int) {
      receivedQuantity = receivedQuantity.toDouble();
    }

    var sentQuantity = rawRow[5];
    if (sentQuantity is String) {
      sentQuantity = double.parse(sentQuantity);
    } else if (sentQuantity is int) {
      sentQuantity = sentQuantity.toDouble();
    }

    var feeQuantity = rawRow[8];
    if (feeQuantity is String) {
      feeQuantity = double.parse(feeQuantity);
    } else if (feeQuantity is int) {
      feeQuantity = feeQuantity.toDouble();
    }

    return Transaction(
      id: Uuid().v1(),
      type: rawRow[1].toString().toLowerCase(),
      receivedQuantity: receivedQuantity,
      receivedAsset: receivedAsset,
      receivedAddress: rawRow[4],
      sentQuantity: sentQuantity,
      sentAsset: sentAsset,
      sentAddress: rawRow[7],
      feeQuantity: feeQuantity,
      feeAsset: feeAsset,
      date: DateTime.parse(rawRow[0]).toUtc(),
      transactionId: rawRow.length > 10 ? rawRow[10] : null,
      comment: rawRow.length > 11 ? rawRow[11] : null,
    );
  }

  static Future<Transaction> deserialize(
    Map<String, dynamic> rawTransaction,
  ) async {
    final rawSentQuantity = rawTransaction["sentQuantity"];
    final rawReceivedQuantity = rawTransaction["receivedQuantity"];
    final rawFeeQuantity = rawTransaction["feeQuantity"];
    final sentAssetId = rawTransaction["sentAssetId"];
    final receivedAssetId = rawTransaction["receivedAssetId"];
    final feeAssetId = rawTransaction["feeAssetId"];

    return Transaction(
      id: rawTransaction["id"],
      type: rawTransaction["type"],
      date: DateTime.fromMillisecondsSinceEpoch(rawTransaction["date"]),
      transactionId: rawTransaction["transactionId"],
      comment: rawTransaction["comment"],
      sendAccount: rawTransaction["sendAccount"],
      sentAddress: rawTransaction["sentAddress"],
      sentAsset:
          sentAssetId != null ? await Asset.findOneById(sentAssetId) : null,
      sentQuantity: rawSentQuantity != null ? rawSentQuantity.toDouble() : null,
      receivedAccount: rawTransaction["receivedAccount"],
      receivedAddress: rawTransaction["receivedAddress"],
      receivedAsset: receivedAssetId != null
          ? await Asset.findOneById(receivedAssetId)
          : null,
      receivedQuantity:
          rawReceivedQuantity != null ? rawReceivedQuantity.toDouble() : null,
      feeAsset: feeAssetId != null ? await Asset.findOneById(feeAssetId) : null,
      feeQuantity: rawFeeQuantity != null ? rawFeeQuantity.toDouble() : null,
    );
  }

  static Future<List<Transaction>> find({
    Map<String, dynamic> filters,
    String orderBy,
    int limit,
    int offset,
  }) async {
    final List<Transaction> transactions = new List();

    final List<Map<String, dynamic>> rawTransactions =
        await DatabaseService().find(
      Transaction.tableName,
      Transaction.tableColumns.keys.toList(),
      filters,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    for (Map<String, dynamic> rawTransaction in rawTransactions) {
      Transaction transaction = await Transaction.deserialize(rawTransaction);
      transactions.add(transaction);
    }

    return transactions;
  }

  static Future<Transaction> findOneById(String id) async {
    final db = await DatabaseService().connect();
    final rawTransactions = await db.query(
      Transaction.tableName,
      columns: Transaction.tableColumns.keys.toList(),
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );
    if (rawTransactions.isNotEmpty) {
      return Transaction.deserialize(rawTransactions.first);
    }

    return null;
  }

  Map<String, dynamic> serialize() {
    final map = new Map<String, dynamic>();
    map["id"] = this.id;
    map["type"] = this.type;
    map["date"] = this.date.millisecondsSinceEpoch;
    map["transactionId"] = this.transactionId;
    map["comment"] = this.comment;
    map["sendAccount"] = this.sendAccount;
    map["sentAddress"] = this.sentAddress;
    map["sentAssetId"] = this.sentAsset?.id;
    map["sentQuantity"] = this.sentQuantity;
    map["receivedAccount"] = this.receivedAccount;
    map["receivedAddress"] = this.receivedAddress;
    map["receivedAssetId"] = this.receivedAsset?.id;
    map["receivedQuantity"] = this.receivedQuantity;
    map["feeAssetId"] = this.feeAsset?.id;
    map["feeQuantity"] = this.feeQuantity;

    return map;
  }

  Future<void> save() async {
    final db = await DatabaseService().connect();
    await db.insert(
      Transaction.tableName,
      this.serialize(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete() async {
    Map<String, dynamic> filters = {};
    filters["id"] = this.id;
    await DatabaseService().delete(Transaction.tableName, filters);
  }

  List<dynamic> toCsv() {
    return [
      this.date.toString().split(" ")[0],
      this.type,
      this.receivedQuantity,
      this.receivedAsset.symbol,
      this.receivedAddress,
      this.sentQuantity,
      this.sentAsset.symbol,
      this.sentAddress,
      this.feeQuantity,
      this.feeAsset.symbol,
      this.transactionId,
      this.comment,
      this.total,
      this.rate,
      this.returnValue,
    ];
  }

  @override
  String toString() {
    if (this.receivedAsset == null) {
      return "$type $sentQuantity ${sentAsset.symbol}";
    }
    return "$type $receivedQuantity ${receivedAsset.symbol}";
  }
}
