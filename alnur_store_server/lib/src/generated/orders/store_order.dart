/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod/serverpod.dart' as _i1;

abstract class StoreOrder
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  StoreOrder._({
    this.id,
    required this.orderRef,
    required this.customerEmail,
    required this.customerName,
    required this.customerPhone,
    required this.shippingAddress,
    required this.totalAmount,
    required this.paymentStatus,
    required this.fulfillmentStatus,
    this.idempotencyKey,
    this.paymentReference,
    required this.itemsJson,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoreOrder({
    int? id,
    required String orderRef,
    required String customerEmail,
    required String customerName,
    required String customerPhone,
    required String shippingAddress,
    required double totalAmount,
    required String paymentStatus,
    required String fulfillmentStatus,
    String? idempotencyKey,
    String? paymentReference,
    required String itemsJson,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _StoreOrderImpl;

  factory StoreOrder.fromJson(Map<String, dynamic> jsonSerialization) {
    return StoreOrder(
      id: jsonSerialization['id'] as int?,
      orderRef: jsonSerialization['orderRef'] as String,
      customerEmail: jsonSerialization['customerEmail'] as String,
      customerName: jsonSerialization['customerName'] as String,
      customerPhone: jsonSerialization['customerPhone'] as String,
      shippingAddress: jsonSerialization['shippingAddress'] as String,
      totalAmount: (jsonSerialization['totalAmount'] as num).toDouble(),
      paymentStatus: jsonSerialization['paymentStatus'] as String,
      fulfillmentStatus: jsonSerialization['fulfillmentStatus'] as String,
      idempotencyKey: jsonSerialization['idempotencyKey'] as String?,
      paymentReference: jsonSerialization['paymentReference'] as String?,
      itemsJson: jsonSerialization['itemsJson'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = StoreOrderTable();

  static const db = StoreOrderRepository._();

  @override
  int? id;

  String orderRef;

  String customerEmail;

  String customerName;

  String customerPhone;

  String shippingAddress;

  double totalAmount;

  String paymentStatus;

  String fulfillmentStatus;

  String? idempotencyKey;

  String? paymentReference;

  String itemsJson;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [StoreOrder]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  StoreOrder copyWith({
    int? id,
    String? orderRef,
    String? customerEmail,
    String? customerName,
    String? customerPhone,
    String? shippingAddress,
    double? totalAmount,
    String? paymentStatus,
    String? fulfillmentStatus,
    String? idempotencyKey,
    String? paymentReference,
    String? itemsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StoreOrder',
      if (id != null) 'id': id,
      'orderRef': orderRef,
      'customerEmail': customerEmail,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'shippingAddress': shippingAddress,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'fulfillmentStatus': fulfillmentStatus,
      if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
      if (paymentReference != null) 'paymentReference': paymentReference,
      'itemsJson': itemsJson,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'StoreOrder',
      if (id != null) 'id': id,
      'orderRef': orderRef,
      'customerEmail': customerEmail,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'shippingAddress': shippingAddress,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'fulfillmentStatus': fulfillmentStatus,
      if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
      if (paymentReference != null) 'paymentReference': paymentReference,
      'itemsJson': itemsJson,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static StoreOrderInclude include() {
    return StoreOrderInclude._();
  }

  static StoreOrderIncludeList includeList({
    _i1.WhereExpressionBuilder<StoreOrderTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<StoreOrderTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<StoreOrderTable>? orderByList,
    StoreOrderInclude? include,
  }) {
    return StoreOrderIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StoreOrder.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(StoreOrder.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StoreOrderImpl extends StoreOrder {
  _StoreOrderImpl({
    int? id,
    required String orderRef,
    required String customerEmail,
    required String customerName,
    required String customerPhone,
    required String shippingAddress,
    required double totalAmount,
    required String paymentStatus,
    required String fulfillmentStatus,
    String? idempotencyKey,
    String? paymentReference,
    required String itemsJson,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         orderRef: orderRef,
         customerEmail: customerEmail,
         customerName: customerName,
         customerPhone: customerPhone,
         shippingAddress: shippingAddress,
         totalAmount: totalAmount,
         paymentStatus: paymentStatus,
         fulfillmentStatus: fulfillmentStatus,
         idempotencyKey: idempotencyKey,
         paymentReference: paymentReference,
         itemsJson: itemsJson,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [StoreOrder]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  StoreOrder copyWith({
    Object? id = _Undefined,
    String? orderRef,
    String? customerEmail,
    String? customerName,
    String? customerPhone,
    String? shippingAddress,
    double? totalAmount,
    String? paymentStatus,
    String? fulfillmentStatus,
    Object? idempotencyKey = _Undefined,
    Object? paymentReference = _Undefined,
    String? itemsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoreOrder(
      id: id is int? ? id : this.id,
      orderRef: orderRef ?? this.orderRef,
      customerEmail: customerEmail ?? this.customerEmail,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      fulfillmentStatus: fulfillmentStatus ?? this.fulfillmentStatus,
      idempotencyKey: idempotencyKey is String?
          ? idempotencyKey
          : this.idempotencyKey,
      paymentReference: paymentReference is String?
          ? paymentReference
          : this.paymentReference,
      itemsJson: itemsJson ?? this.itemsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class StoreOrderUpdateTable extends _i1.UpdateTable<StoreOrderTable> {
  StoreOrderUpdateTable(super.table);

  _i1.ColumnValue<String, String> orderRef(String value) => _i1.ColumnValue(
    table.orderRef,
    value,
  );

  _i1.ColumnValue<String, String> customerEmail(String value) =>
      _i1.ColumnValue(
        table.customerEmail,
        value,
      );

  _i1.ColumnValue<String, String> customerName(String value) => _i1.ColumnValue(
    table.customerName,
    value,
  );

  _i1.ColumnValue<String, String> customerPhone(String value) =>
      _i1.ColumnValue(
        table.customerPhone,
        value,
      );

  _i1.ColumnValue<String, String> shippingAddress(String value) =>
      _i1.ColumnValue(
        table.shippingAddress,
        value,
      );

  _i1.ColumnValue<double, double> totalAmount(double value) => _i1.ColumnValue(
    table.totalAmount,
    value,
  );

  _i1.ColumnValue<String, String> paymentStatus(String value) =>
      _i1.ColumnValue(
        table.paymentStatus,
        value,
      );

  _i1.ColumnValue<String, String> fulfillmentStatus(String value) =>
      _i1.ColumnValue(
        table.fulfillmentStatus,
        value,
      );

  _i1.ColumnValue<String, String> idempotencyKey(String? value) =>
      _i1.ColumnValue(
        table.idempotencyKey,
        value,
      );

  _i1.ColumnValue<String, String> paymentReference(String? value) =>
      _i1.ColumnValue(
        table.paymentReference,
        value,
      );

  _i1.ColumnValue<String, String> itemsJson(String value) => _i1.ColumnValue(
    table.itemsJson,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class StoreOrderTable extends _i1.Table<int?> {
  StoreOrderTable({super.tableRelation}) : super(tableName: 'store_order') {
    updateTable = StoreOrderUpdateTable(this);
    orderRef = _i1.ColumnString(
      'orderRef',
      this,
    );
    customerEmail = _i1.ColumnString(
      'customerEmail',
      this,
    );
    customerName = _i1.ColumnString(
      'customerName',
      this,
    );
    customerPhone = _i1.ColumnString(
      'customerPhone',
      this,
    );
    shippingAddress = _i1.ColumnString(
      'shippingAddress',
      this,
    );
    totalAmount = _i1.ColumnDouble(
      'totalAmount',
      this,
    );
    paymentStatus = _i1.ColumnString(
      'paymentStatus',
      this,
    );
    fulfillmentStatus = _i1.ColumnString(
      'fulfillmentStatus',
      this,
    );
    idempotencyKey = _i1.ColumnString(
      'idempotencyKey',
      this,
    );
    paymentReference = _i1.ColumnString(
      'paymentReference',
      this,
    );
    itemsJson = _i1.ColumnString(
      'itemsJson',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final StoreOrderUpdateTable updateTable;

  late final _i1.ColumnString orderRef;

  late final _i1.ColumnString customerEmail;

  late final _i1.ColumnString customerName;

  late final _i1.ColumnString customerPhone;

  late final _i1.ColumnString shippingAddress;

  late final _i1.ColumnDouble totalAmount;

  late final _i1.ColumnString paymentStatus;

  late final _i1.ColumnString fulfillmentStatus;

  late final _i1.ColumnString idempotencyKey;

  late final _i1.ColumnString paymentReference;

  late final _i1.ColumnString itemsJson;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    orderRef,
    customerEmail,
    customerName,
    customerPhone,
    shippingAddress,
    totalAmount,
    paymentStatus,
    fulfillmentStatus,
    idempotencyKey,
    paymentReference,
    itemsJson,
    createdAt,
    updatedAt,
  ];
}

class StoreOrderInclude extends _i1.IncludeObject {
  StoreOrderInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => StoreOrder.t;
}

class StoreOrderIncludeList extends _i1.IncludeList {
  StoreOrderIncludeList._({
    _i1.WhereExpressionBuilder<StoreOrderTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StoreOrder.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => StoreOrder.t;
}

class StoreOrderRepository {
  const StoreOrderRepository._();

  /// Returns a list of [StoreOrder]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<StoreOrder>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<StoreOrderTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<StoreOrderTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<StoreOrderTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StoreOrder>(
      where: where?.call(StoreOrder.t),
      orderBy: orderBy?.call(StoreOrder.t),
      orderByList: orderByList?.call(StoreOrder.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [StoreOrder] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<StoreOrder?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<StoreOrderTable>? where,
    int? offset,
    _i1.OrderByBuilder<StoreOrderTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<StoreOrderTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StoreOrder>(
      where: where?.call(StoreOrder.t),
      orderBy: orderBy?.call(StoreOrder.t),
      orderByList: orderByList?.call(StoreOrder.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StoreOrder] by its [id] or null if no such row exists.
  Future<StoreOrder?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StoreOrder>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StoreOrder]s in the list and returns the inserted rows.
  ///
  /// The returned [StoreOrder]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<StoreOrder>> insert(
    _i1.DatabaseSession session,
    List<StoreOrder> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<StoreOrder>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [StoreOrder] and returns the inserted row.
  ///
  /// The returned [StoreOrder] will have its `id` field set.
  Future<StoreOrder> insertRow(
    _i1.DatabaseSession session,
    StoreOrder row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<StoreOrder>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [StoreOrder]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<StoreOrder>> update(
    _i1.DatabaseSession session,
    List<StoreOrder> rows, {
    _i1.ColumnSelections<StoreOrderTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<StoreOrder>(
      rows,
      columns: columns?.call(StoreOrder.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StoreOrder]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StoreOrder> updateRow(
    _i1.DatabaseSession session,
    StoreOrder row, {
    _i1.ColumnSelections<StoreOrderTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<StoreOrder>(
      row,
      columns: columns?.call(StoreOrder.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StoreOrder] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StoreOrder?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<StoreOrderUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<StoreOrder>(
      id,
      columnValues: columnValues(StoreOrder.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StoreOrder]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<StoreOrder>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<StoreOrderUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<StoreOrderTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<StoreOrderTable>? orderBy,
    _i1.OrderByListBuilder<StoreOrderTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<StoreOrder>(
      columnValues: columnValues(StoreOrder.t.updateTable),
      where: where(StoreOrder.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StoreOrder.t),
      orderByList: orderByList?.call(StoreOrder.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [StoreOrder]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<StoreOrder>> delete(
    _i1.DatabaseSession session,
    List<StoreOrder> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<StoreOrder>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [StoreOrder].
  Future<StoreOrder> deleteRow(
    _i1.DatabaseSession session,
    StoreOrder row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StoreOrder>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<StoreOrder>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<StoreOrderTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<StoreOrder>(
      where: where(StoreOrder.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<StoreOrderTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<StoreOrder>(
      where: where?.call(StoreOrder.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StoreOrder] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<StoreOrderTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StoreOrder>(
      where: where(StoreOrder.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
