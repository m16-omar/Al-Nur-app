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

/// A listener account for the Nupe Songs app (separate from Al-Nur Store customers).
abstract class NupeListener
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  NupeListener._({
    this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    required this.passwordHash,
    required this.createdAt,
    this.lastSeenAt,
    this.lastActivity,
    this.platform,
    bool? isDisabled,
  }) : isDisabled = isDisabled ?? false;

  factory NupeListener({
    int? id,
    required String username,
    required String email,
    String? firstName,
    String? lastName,
    required String passwordHash,
    required DateTime createdAt,
    DateTime? lastSeenAt,
    String? lastActivity,
    String? platform,
    bool? isDisabled,
  }) = _NupeListenerImpl;

  factory NupeListener.fromJson(Map<String, dynamic> jsonSerialization) {
    return NupeListener(
      id: jsonSerialization['id'] as int?,
      username: jsonSerialization['username'] as String,
      email: jsonSerialization['email'] as String,
      firstName: jsonSerialization['firstName'] as String?,
      lastName: jsonSerialization['lastName'] as String?,
      passwordHash: jsonSerialization['passwordHash'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      lastSeenAt: jsonSerialization['lastSeenAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastSeenAt']),
      lastActivity: jsonSerialization['lastActivity'] as String?,
      platform: jsonSerialization['platform'] as String?,
      isDisabled: jsonSerialization['isDisabled'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isDisabled']),
    );
  }

  static final t = NupeListenerTable();

  static const db = NupeListenerRepository._();

  @override
  int? id;

  /// Lower-cased, unique login name.
  String username;

  /// Lower-cased, unique email address.
  String email;

  String? firstName;

  String? lastName;

  /// PBKDF2-HMAC-SHA256 hash, encoded as "iterations$saltB64$hashB64".
  String passwordHash;

  DateTime createdAt;

  /// Updated (throttled) on every authenticated request; drives "online now".
  DateTime? lastSeenAt;

  /// Short human-readable description, e.g. "Listening to Dabe Dabe".
  String? lastActivity;

  /// Client platform reported by the app, e.g. "android" / "ios".
  String? platform;

  bool isDisabled;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [NupeListener]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  NupeListener copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? passwordHash,
    DateTime? createdAt,
    DateTime? lastSeenAt,
    String? lastActivity,
    String? platform,
    bool? isDisabled,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NupeListener',
      if (id != null) 'id': id,
      'username': username,
      'email': email,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toJson(),
      if (lastSeenAt != null) 'lastSeenAt': lastSeenAt?.toJson(),
      if (lastActivity != null) 'lastActivity': lastActivity,
      if (platform != null) 'platform': platform,
      'isDisabled': isDisabled,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static NupeListenerInclude include() {
    return NupeListenerInclude._();
  }

  static NupeListenerIncludeList includeList({
    _i1.WhereExpressionBuilder<NupeListenerTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<NupeListenerTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<NupeListenerTable>? orderByList,
    NupeListenerInclude? include,
  }) {
    return NupeListenerIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(NupeListener.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(NupeListener.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _NupeListenerImpl extends NupeListener {
  _NupeListenerImpl({
    int? id,
    required String username,
    required String email,
    String? firstName,
    String? lastName,
    required String passwordHash,
    required DateTime createdAt,
    DateTime? lastSeenAt,
    String? lastActivity,
    String? platform,
    bool? isDisabled,
  }) : super._(
         id: id,
         username: username,
         email: email,
         firstName: firstName,
         lastName: lastName,
         passwordHash: passwordHash,
         createdAt: createdAt,
         lastSeenAt: lastSeenAt,
         lastActivity: lastActivity,
         platform: platform,
         isDisabled: isDisabled,
       );

  /// Returns a shallow copy of this [NupeListener]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  NupeListener copyWith({
    Object? id = _Undefined,
    String? username,
    String? email,
    Object? firstName = _Undefined,
    Object? lastName = _Undefined,
    String? passwordHash,
    DateTime? createdAt,
    Object? lastSeenAt = _Undefined,
    Object? lastActivity = _Undefined,
    Object? platform = _Undefined,
    bool? isDisabled,
  }) {
    return NupeListener(
      id: id is int? ? id : this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName is String? ? firstName : this.firstName,
      lastName: lastName is String? ? lastName : this.lastName,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      lastSeenAt: lastSeenAt is DateTime? ? lastSeenAt : this.lastSeenAt,
      lastActivity: lastActivity is String? ? lastActivity : this.lastActivity,
      platform: platform is String? ? platform : this.platform,
      isDisabled: isDisabled ?? this.isDisabled,
    );
  }
}

class NupeListenerUpdateTable extends _i1.UpdateTable<NupeListenerTable> {
  NupeListenerUpdateTable(super.table);

  _i1.ColumnValue<String, String> username(String value) => _i1.ColumnValue(
    table.username,
    value,
  );

  _i1.ColumnValue<String, String> email(String value) => _i1.ColumnValue(
    table.email,
    value,
  );

  _i1.ColumnValue<String, String> firstName(String? value) => _i1.ColumnValue(
    table.firstName,
    value,
  );

  _i1.ColumnValue<String, String> lastName(String? value) => _i1.ColumnValue(
    table.lastName,
    value,
  );

  _i1.ColumnValue<String, String> passwordHash(String value) => _i1.ColumnValue(
    table.passwordHash,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> lastSeenAt(DateTime? value) =>
      _i1.ColumnValue(
        table.lastSeenAt,
        value,
      );

  _i1.ColumnValue<String, String> lastActivity(String? value) =>
      _i1.ColumnValue(
        table.lastActivity,
        value,
      );

  _i1.ColumnValue<String, String> platform(String? value) => _i1.ColumnValue(
    table.platform,
    value,
  );

  _i1.ColumnValue<bool, bool> isDisabled(bool value) => _i1.ColumnValue(
    table.isDisabled,
    value,
  );
}

class NupeListenerTable extends _i1.Table<int?> {
  NupeListenerTable({super.tableRelation}) : super(tableName: 'nupe_listener') {
    updateTable = NupeListenerUpdateTable(this);
    username = _i1.ColumnString(
      'username',
      this,
    );
    email = _i1.ColumnString(
      'email',
      this,
    );
    firstName = _i1.ColumnString(
      'firstName',
      this,
    );
    lastName = _i1.ColumnString(
      'lastName',
      this,
    );
    passwordHash = _i1.ColumnString(
      'passwordHash',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    lastSeenAt = _i1.ColumnDateTime(
      'lastSeenAt',
      this,
    );
    lastActivity = _i1.ColumnString(
      'lastActivity',
      this,
    );
    platform = _i1.ColumnString(
      'platform',
      this,
    );
    isDisabled = _i1.ColumnBool(
      'isDisabled',
      this,
      hasDefault: true,
    );
  }

  late final NupeListenerUpdateTable updateTable;

  /// Lower-cased, unique login name.
  late final _i1.ColumnString username;

  /// Lower-cased, unique email address.
  late final _i1.ColumnString email;

  late final _i1.ColumnString firstName;

  late final _i1.ColumnString lastName;

  /// PBKDF2-HMAC-SHA256 hash, encoded as "iterations$saltB64$hashB64".
  late final _i1.ColumnString passwordHash;

  late final _i1.ColumnDateTime createdAt;

  /// Updated (throttled) on every authenticated request; drives "online now".
  late final _i1.ColumnDateTime lastSeenAt;

  /// Short human-readable description, e.g. "Listening to Dabe Dabe".
  late final _i1.ColumnString lastActivity;

  /// Client platform reported by the app, e.g. "android" / "ios".
  late final _i1.ColumnString platform;

  late final _i1.ColumnBool isDisabled;

  @override
  List<_i1.Column> get columns => [
    id,
    username,
    email,
    firstName,
    lastName,
    passwordHash,
    createdAt,
    lastSeenAt,
    lastActivity,
    platform,
    isDisabled,
  ];
}

class NupeListenerInclude extends _i1.IncludeObject {
  NupeListenerInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => NupeListener.t;
}

class NupeListenerIncludeList extends _i1.IncludeList {
  NupeListenerIncludeList._({
    _i1.WhereExpressionBuilder<NupeListenerTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(NupeListener.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => NupeListener.t;
}

class NupeListenerRepository {
  const NupeListenerRepository._();

  /// Returns a list of [NupeListener]s matching the given query parameters.
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
  Future<List<NupeListener>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<NupeListenerTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<NupeListenerTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<NupeListenerTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<NupeListener>(
      where: where?.call(NupeListener.t),
      orderBy: orderBy?.call(NupeListener.t),
      orderByList: orderByList?.call(NupeListener.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [NupeListener] matching the given query parameters.
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
  Future<NupeListener?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<NupeListenerTable>? where,
    int? offset,
    _i1.OrderByBuilder<NupeListenerTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<NupeListenerTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<NupeListener>(
      where: where?.call(NupeListener.t),
      orderBy: orderBy?.call(NupeListener.t),
      orderByList: orderByList?.call(NupeListener.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [NupeListener] by its [id] or null if no such row exists.
  Future<NupeListener?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<NupeListener>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [NupeListener]s in the list and returns the inserted rows.
  ///
  /// The returned [NupeListener]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<NupeListener>> insert(
    _i1.DatabaseSession session,
    List<NupeListener> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<NupeListener>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [NupeListener] and returns the inserted row.
  ///
  /// The returned [NupeListener] will have its `id` field set.
  Future<NupeListener> insertRow(
    _i1.DatabaseSession session,
    NupeListener row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<NupeListener>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [NupeListener]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<NupeListener>> update(
    _i1.DatabaseSession session,
    List<NupeListener> rows, {
    _i1.ColumnSelections<NupeListenerTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<NupeListener>(
      rows,
      columns: columns?.call(NupeListener.t),
      transaction: transaction,
    );
  }

  /// Updates a single [NupeListener]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<NupeListener> updateRow(
    _i1.DatabaseSession session,
    NupeListener row, {
    _i1.ColumnSelections<NupeListenerTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<NupeListener>(
      row,
      columns: columns?.call(NupeListener.t),
      transaction: transaction,
    );
  }

  /// Updates a single [NupeListener] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<NupeListener?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<NupeListenerUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<NupeListener>(
      id,
      columnValues: columnValues(NupeListener.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [NupeListener]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<NupeListener>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<NupeListenerUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<NupeListenerTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<NupeListenerTable>? orderBy,
    _i1.OrderByListBuilder<NupeListenerTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<NupeListener>(
      columnValues: columnValues(NupeListener.t.updateTable),
      where: where(NupeListener.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(NupeListener.t),
      orderByList: orderByList?.call(NupeListener.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [NupeListener]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<NupeListener>> delete(
    _i1.DatabaseSession session,
    List<NupeListener> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<NupeListener>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [NupeListener].
  Future<NupeListener> deleteRow(
    _i1.DatabaseSession session,
    NupeListener row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<NupeListener>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<NupeListener>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<NupeListenerTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<NupeListener>(
      where: where(NupeListener.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<NupeListenerTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<NupeListener>(
      where: where?.call(NupeListener.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [NupeListener] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<NupeListenerTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<NupeListener>(
      where: where(NupeListener.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
