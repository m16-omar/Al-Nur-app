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

/// A content report sent from the Nupe Songs app, reviewed in Nupe Studio.
abstract class NupeReport
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  NupeReport._({
    this.id,
    required this.itemType,
    required this.itemId,
    this.itemLabel,
    required this.reason,
    this.details,
    this.reporterId,
    this.targetListenerId,
    String? status,
    required this.createdAt,
    this.resolvedAt,
  }) : status = status ?? 'pending';

  factory NupeReport({
    int? id,
    required String itemType,
    required String itemId,
    String? itemLabel,
    required String reason,
    String? details,
    int? reporterId,
    int? targetListenerId,
    String? status,
    required DateTime createdAt,
    DateTime? resolvedAt,
  }) = _NupeReportImpl;

  factory NupeReport.fromJson(Map<String, dynamic> jsonSerialization) {
    return NupeReport(
      id: jsonSerialization['id'] as int?,
      itemType: jsonSerialization['itemType'] as String,
      itemId: jsonSerialization['itemId'] as String,
      itemLabel: jsonSerialization['itemLabel'] as String?,
      reason: jsonSerialization['reason'] as String,
      details: jsonSerialization['details'] as String?,
      reporterId: jsonSerialization['reporterId'] as int?,
      targetListenerId: jsonSerialization['targetListenerId'] as int?,
      status: jsonSerialization['status'] as String?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      resolvedAt: jsonSerialization['resolvedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['resolvedAt']),
    );
  }

  static final t = NupeReportTable();

  static const db = NupeReportRepository._();

  @override
  int? id;

  /// "song", "comment", "playlist", "artist" or "album".
  String itemType;

  String itemId;

  /// Human-readable name of the item at the time it was reported.
  String? itemLabel;

  String reason;

  String? details;

  /// Listener who sent the report (null if anonymous).
  int? reporterId;

  /// Listener responsible for the item, if any (used by "Ban user").
  int? targetListenerId;

  /// "pending", "approved", "removed", "banned" or "dismissed".
  String status;

  DateTime createdAt;

  DateTime? resolvedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [NupeReport]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  NupeReport copyWith({
    int? id,
    String? itemType,
    String? itemId,
    String? itemLabel,
    String? reason,
    String? details,
    int? reporterId,
    int? targetListenerId,
    String? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NupeReport',
      if (id != null) 'id': id,
      'itemType': itemType,
      'itemId': itemId,
      if (itemLabel != null) 'itemLabel': itemLabel,
      'reason': reason,
      if (details != null) 'details': details,
      if (reporterId != null) 'reporterId': reporterId,
      if (targetListenerId != null) 'targetListenerId': targetListenerId,
      'status': status,
      'createdAt': createdAt.toJson(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static NupeReportInclude include() {
    return NupeReportInclude._();
  }

  static NupeReportIncludeList includeList({
    _i1.WhereExpressionBuilder<NupeReportTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<NupeReportTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<NupeReportTable>? orderByList,
    NupeReportInclude? include,
  }) {
    return NupeReportIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(NupeReport.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(NupeReport.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _NupeReportImpl extends NupeReport {
  _NupeReportImpl({
    int? id,
    required String itemType,
    required String itemId,
    String? itemLabel,
    required String reason,
    String? details,
    int? reporterId,
    int? targetListenerId,
    String? status,
    required DateTime createdAt,
    DateTime? resolvedAt,
  }) : super._(
         id: id,
         itemType: itemType,
         itemId: itemId,
         itemLabel: itemLabel,
         reason: reason,
         details: details,
         reporterId: reporterId,
         targetListenerId: targetListenerId,
         status: status,
         createdAt: createdAt,
         resolvedAt: resolvedAt,
       );

  /// Returns a shallow copy of this [NupeReport]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  NupeReport copyWith({
    Object? id = _Undefined,
    String? itemType,
    String? itemId,
    Object? itemLabel = _Undefined,
    String? reason,
    Object? details = _Undefined,
    Object? reporterId = _Undefined,
    Object? targetListenerId = _Undefined,
    String? status,
    DateTime? createdAt,
    Object? resolvedAt = _Undefined,
  }) {
    return NupeReport(
      id: id is int? ? id : this.id,
      itemType: itemType ?? this.itemType,
      itemId: itemId ?? this.itemId,
      itemLabel: itemLabel is String? ? itemLabel : this.itemLabel,
      reason: reason ?? this.reason,
      details: details is String? ? details : this.details,
      reporterId: reporterId is int? ? reporterId : this.reporterId,
      targetListenerId: targetListenerId is int?
          ? targetListenerId
          : this.targetListenerId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt is DateTime? ? resolvedAt : this.resolvedAt,
    );
  }
}

class NupeReportUpdateTable extends _i1.UpdateTable<NupeReportTable> {
  NupeReportUpdateTable(super.table);

  _i1.ColumnValue<String, String> itemType(String value) => _i1.ColumnValue(
    table.itemType,
    value,
  );

  _i1.ColumnValue<String, String> itemId(String value) => _i1.ColumnValue(
    table.itemId,
    value,
  );

  _i1.ColumnValue<String, String> itemLabel(String? value) => _i1.ColumnValue(
    table.itemLabel,
    value,
  );

  _i1.ColumnValue<String, String> reason(String value) => _i1.ColumnValue(
    table.reason,
    value,
  );

  _i1.ColumnValue<String, String> details(String? value) => _i1.ColumnValue(
    table.details,
    value,
  );

  _i1.ColumnValue<int, int> reporterId(int? value) => _i1.ColumnValue(
    table.reporterId,
    value,
  );

  _i1.ColumnValue<int, int> targetListenerId(int? value) => _i1.ColumnValue(
    table.targetListenerId,
    value,
  );

  _i1.ColumnValue<String, String> status(String value) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> resolvedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.resolvedAt,
        value,
      );
}

class NupeReportTable extends _i1.Table<int?> {
  NupeReportTable({super.tableRelation}) : super(tableName: 'nupe_report') {
    updateTable = NupeReportUpdateTable(this);
    itemType = _i1.ColumnString(
      'itemType',
      this,
    );
    itemId = _i1.ColumnString(
      'itemId',
      this,
    );
    itemLabel = _i1.ColumnString(
      'itemLabel',
      this,
    );
    reason = _i1.ColumnString(
      'reason',
      this,
    );
    details = _i1.ColumnString(
      'details',
      this,
    );
    reporterId = _i1.ColumnInt(
      'reporterId',
      this,
    );
    targetListenerId = _i1.ColumnInt(
      'targetListenerId',
      this,
    );
    status = _i1.ColumnString(
      'status',
      this,
      hasDefault: true,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    resolvedAt = _i1.ColumnDateTime(
      'resolvedAt',
      this,
    );
  }

  late final NupeReportUpdateTable updateTable;

  /// "song", "comment", "playlist", "artist" or "album".
  late final _i1.ColumnString itemType;

  late final _i1.ColumnString itemId;

  /// Human-readable name of the item at the time it was reported.
  late final _i1.ColumnString itemLabel;

  late final _i1.ColumnString reason;

  late final _i1.ColumnString details;

  /// Listener who sent the report (null if anonymous).
  late final _i1.ColumnInt reporterId;

  /// Listener responsible for the item, if any (used by "Ban user").
  late final _i1.ColumnInt targetListenerId;

  /// "pending", "approved", "removed", "banned" or "dismissed".
  late final _i1.ColumnString status;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime resolvedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    itemType,
    itemId,
    itemLabel,
    reason,
    details,
    reporterId,
    targetListenerId,
    status,
    createdAt,
    resolvedAt,
  ];
}

class NupeReportInclude extends _i1.IncludeObject {
  NupeReportInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => NupeReport.t;
}

class NupeReportIncludeList extends _i1.IncludeList {
  NupeReportIncludeList._({
    _i1.WhereExpressionBuilder<NupeReportTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(NupeReport.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => NupeReport.t;
}

class NupeReportRepository {
  const NupeReportRepository._();

  /// Returns a list of [NupeReport]s matching the given query parameters.
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
  Future<List<NupeReport>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<NupeReportTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<NupeReportTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<NupeReportTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<NupeReport>(
      where: where?.call(NupeReport.t),
      orderBy: orderBy?.call(NupeReport.t),
      orderByList: orderByList?.call(NupeReport.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [NupeReport] matching the given query parameters.
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
  Future<NupeReport?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<NupeReportTable>? where,
    int? offset,
    _i1.OrderByBuilder<NupeReportTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<NupeReportTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<NupeReport>(
      where: where?.call(NupeReport.t),
      orderBy: orderBy?.call(NupeReport.t),
      orderByList: orderByList?.call(NupeReport.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [NupeReport] by its [id] or null if no such row exists.
  Future<NupeReport?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<NupeReport>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [NupeReport]s in the list and returns the inserted rows.
  ///
  /// The returned [NupeReport]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<NupeReport>> insert(
    _i1.DatabaseSession session,
    List<NupeReport> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<NupeReport>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [NupeReport] and returns the inserted row.
  ///
  /// The returned [NupeReport] will have its `id` field set.
  Future<NupeReport> insertRow(
    _i1.DatabaseSession session,
    NupeReport row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<NupeReport>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [NupeReport]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<NupeReport>> update(
    _i1.DatabaseSession session,
    List<NupeReport> rows, {
    _i1.ColumnSelections<NupeReportTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<NupeReport>(
      rows,
      columns: columns?.call(NupeReport.t),
      transaction: transaction,
    );
  }

  /// Updates a single [NupeReport]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<NupeReport> updateRow(
    _i1.DatabaseSession session,
    NupeReport row, {
    _i1.ColumnSelections<NupeReportTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<NupeReport>(
      row,
      columns: columns?.call(NupeReport.t),
      transaction: transaction,
    );
  }

  /// Updates a single [NupeReport] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<NupeReport?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<NupeReportUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<NupeReport>(
      id,
      columnValues: columnValues(NupeReport.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [NupeReport]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<NupeReport>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<NupeReportUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<NupeReportTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<NupeReportTable>? orderBy,
    _i1.OrderByListBuilder<NupeReportTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<NupeReport>(
      columnValues: columnValues(NupeReport.t.updateTable),
      where: where(NupeReport.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(NupeReport.t),
      orderByList: orderByList?.call(NupeReport.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [NupeReport]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<NupeReport>> delete(
    _i1.DatabaseSession session,
    List<NupeReport> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<NupeReport>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [NupeReport].
  Future<NupeReport> deleteRow(
    _i1.DatabaseSession session,
    NupeReport row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<NupeReport>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<NupeReport>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<NupeReportTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<NupeReport>(
      where: where(NupeReport.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<NupeReportTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<NupeReport>(
      where: where?.call(NupeReport.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [NupeReport] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<NupeReportTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<NupeReport>(
      where: where(NupeReport.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
