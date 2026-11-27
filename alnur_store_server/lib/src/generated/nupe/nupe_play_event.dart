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

/// One play or download of a Nupe Songs track. Drives per-day stats, charts,
/// listener history and devices.
abstract class NupePlayEvent
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  NupePlayEvent._({
    this.id,
    required this.songId,
    this.listenerId,
    required this.kind,
    this.platform,
    required this.createdAt,
  });

  factory NupePlayEvent({
    int? id,
    required int songId,
    int? listenerId,
    required String kind,
    String? platform,
    required DateTime createdAt,
  }) = _NupePlayEventImpl;

  factory NupePlayEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return NupePlayEvent(
      id: jsonSerialization['id'] as int?,
      songId: jsonSerialization['songId'] as int,
      listenerId: jsonSerialization['listenerId'] as int?,
      kind: jsonSerialization['kind'] as String,
      platform: jsonSerialization['platform'] as String?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = NupePlayEventTable();

  static const db = NupePlayEventRepository._();

  @override
  int? id;

  int songId;

  /// Null when the request carried no valid listener token.
  int? listenerId;

  /// "play" or "download".
  String kind;

  /// Client platform, e.g. "ios" / "android" / "web".
  String? platform;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [NupePlayEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  NupePlayEvent copyWith({
    int? id,
    int? songId,
    int? listenerId,
    String? kind,
    String? platform,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NupePlayEvent',
      if (id != null) 'id': id,
      'songId': songId,
      if (listenerId != null) 'listenerId': listenerId,
      'kind': kind,
      if (platform != null) 'platform': platform,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static NupePlayEventInclude include() {
    return NupePlayEventInclude._();
  }

  static NupePlayEventIncludeList includeList({
    _i1.WhereExpressionBuilder<NupePlayEventTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<NupePlayEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<NupePlayEventTable>? orderByList,
    NupePlayEventInclude? include,
  }) {
    return NupePlayEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(NupePlayEvent.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(NupePlayEvent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _NupePlayEventImpl extends NupePlayEvent {
  _NupePlayEventImpl({
    int? id,
    required int songId,
    int? listenerId,
    required String kind,
    String? platform,
    required DateTime createdAt,
  }) : super._(
         id: id,
         songId: songId,
         listenerId: listenerId,
         kind: kind,
         platform: platform,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [NupePlayEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  NupePlayEvent copyWith({
    Object? id = _Undefined,
    int? songId,
    Object? listenerId = _Undefined,
    String? kind,
    Object? platform = _Undefined,
    DateTime? createdAt,
  }) {
    return NupePlayEvent(
      id: id is int? ? id : this.id,
      songId: songId ?? this.songId,
      listenerId: listenerId is int? ? listenerId : this.listenerId,
      kind: kind ?? this.kind,
      platform: platform is String? ? platform : this.platform,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class NupePlayEventUpdateTable extends _i1.UpdateTable<NupePlayEventTable> {
  NupePlayEventUpdateTable(super.table);

  _i1.ColumnValue<int, int> songId(int value) => _i1.ColumnValue(
    table.songId,
    value,
  );

  _i1.ColumnValue<int, int> listenerId(int? value) => _i1.ColumnValue(
    table.listenerId,
    value,
  );

  _i1.ColumnValue<String, String> kind(String value) => _i1.ColumnValue(
    table.kind,
    value,
  );

  _i1.ColumnValue<String, String> platform(String? value) => _i1.ColumnValue(
    table.platform,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class NupePlayEventTable extends _i1.Table<int?> {
  NupePlayEventTable({super.tableRelation})
    : super(tableName: 'nupe_play_event') {
    updateTable = NupePlayEventUpdateTable(this);
    songId = _i1.ColumnInt(
      'songId',
      this,
    );
    listenerId = _i1.ColumnInt(
      'listenerId',
      this,
    );
    kind = _i1.ColumnString(
      'kind',
      this,
    );
    platform = _i1.ColumnString(
      'platform',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final NupePlayEventUpdateTable updateTable;

  late final _i1.ColumnInt songId;

  /// Null when the request carried no valid listener token.
  late final _i1.ColumnInt listenerId;

  /// "play" or "download".
  late final _i1.ColumnString kind;

  /// Client platform, e.g. "ios" / "android" / "web".
  late final _i1.ColumnString platform;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    songId,
    listenerId,
    kind,
    platform,
    createdAt,
  ];
}

class NupePlayEventInclude extends _i1.IncludeObject {
  NupePlayEventInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => NupePlayEvent.t;
}

class NupePlayEventIncludeList extends _i1.IncludeList {
  NupePlayEventIncludeList._({
    _i1.WhereExpressionBuilder<NupePlayEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(NupePlayEvent.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => NupePlayEvent.t;
}

class NupePlayEventRepository {
  const NupePlayEventRepository._();

  /// Returns a list of [NupePlayEvent]s matching the given query parameters.
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
  Future<List<NupePlayEvent>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<NupePlayEventTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<NupePlayEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<NupePlayEventTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<NupePlayEvent>(
      where: where?.call(NupePlayEvent.t),
      orderBy: orderBy?.call(NupePlayEvent.t),
      orderByList: orderByList?.call(NupePlayEvent.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [NupePlayEvent] matching the given query parameters.
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
  Future<NupePlayEvent?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<NupePlayEventTable>? where,
    int? offset,
    _i1.OrderByBuilder<NupePlayEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<NupePlayEventTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<NupePlayEvent>(
      where: where?.call(NupePlayEvent.t),
      orderBy: orderBy?.call(NupePlayEvent.t),
      orderByList: orderByList?.call(NupePlayEvent.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [NupePlayEvent] by its [id] or null if no such row exists.
  Future<NupePlayEvent?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<NupePlayEvent>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [NupePlayEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [NupePlayEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<NupePlayEvent>> insert(
    _i1.DatabaseSession session,
    List<NupePlayEvent> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<NupePlayEvent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [NupePlayEvent] and returns the inserted row.
  ///
  /// The returned [NupePlayEvent] will have its `id` field set.
  Future<NupePlayEvent> insertRow(
    _i1.DatabaseSession session,
    NupePlayEvent row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<NupePlayEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [NupePlayEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<NupePlayEvent>> update(
    _i1.DatabaseSession session,
    List<NupePlayEvent> rows, {
    _i1.ColumnSelections<NupePlayEventTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<NupePlayEvent>(
      rows,
      columns: columns?.call(NupePlayEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [NupePlayEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<NupePlayEvent> updateRow(
    _i1.DatabaseSession session,
    NupePlayEvent row, {
    _i1.ColumnSelections<NupePlayEventTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<NupePlayEvent>(
      row,
      columns: columns?.call(NupePlayEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [NupePlayEvent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<NupePlayEvent?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<NupePlayEventUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<NupePlayEvent>(
      id,
      columnValues: columnValues(NupePlayEvent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [NupePlayEvent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<NupePlayEvent>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<NupePlayEventUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<NupePlayEventTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<NupePlayEventTable>? orderBy,
    _i1.OrderByListBuilder<NupePlayEventTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<NupePlayEvent>(
      columnValues: columnValues(NupePlayEvent.t.updateTable),
      where: where(NupePlayEvent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(NupePlayEvent.t),
      orderByList: orderByList?.call(NupePlayEvent.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [NupePlayEvent]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<NupePlayEvent>> delete(
    _i1.DatabaseSession session,
    List<NupePlayEvent> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<NupePlayEvent>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [NupePlayEvent].
  Future<NupePlayEvent> deleteRow(
    _i1.DatabaseSession session,
    NupePlayEvent row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<NupePlayEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<NupePlayEvent>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<NupePlayEventTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<NupePlayEvent>(
      where: where(NupePlayEvent.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<NupePlayEventTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<NupePlayEvent>(
      where: where?.call(NupePlayEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [NupePlayEvent] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<NupePlayEventTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<NupePlayEvent>(
      where: where(NupePlayEvent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
