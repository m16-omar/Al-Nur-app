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

abstract class UserAccountInfo
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  UserAccountInfo._({
    this.id,
    required this.userEmail,
    required this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    this.preferredCurrency,
    this.bio,
  });

  factory UserAccountInfo({
    int? id,
    required String userEmail,
    required String fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? preferredCurrency,
    String? bio,
  }) = _UserAccountInfoImpl;

  factory UserAccountInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserAccountInfo(
      id: jsonSerialization['id'] as int?,
      userEmail: jsonSerialization['userEmail'] as String,
      fullName: jsonSerialization['fullName'] as String,
      phoneNumber: jsonSerialization['phoneNumber'] as String?,
      avatarUrl: jsonSerialization['avatarUrl'] as String?,
      preferredCurrency: jsonSerialization['preferredCurrency'] as String?,
      bio: jsonSerialization['bio'] as String?,
    );
  }

  static final t = UserAccountInfoTable();

  static const db = UserAccountInfoRepository._();

  @override
  int? id;

  String userEmail;

  String fullName;

  String? phoneNumber;

  String? avatarUrl;

  String? preferredCurrency;

  String? bio;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [UserAccountInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserAccountInfo copyWith({
    int? id,
    String? userEmail,
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? preferredCurrency,
    String? bio,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserAccountInfo',
      if (id != null) 'id': id,
      'userEmail': userEmail,
      'fullName': fullName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (preferredCurrency != null) 'preferredCurrency': preferredCurrency,
      if (bio != null) 'bio': bio,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserAccountInfo',
      if (id != null) 'id': id,
      'userEmail': userEmail,
      'fullName': fullName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (preferredCurrency != null) 'preferredCurrency': preferredCurrency,
      if (bio != null) 'bio': bio,
    };
  }

  static UserAccountInfoInclude include() {
    return UserAccountInfoInclude._();
  }

  static UserAccountInfoIncludeList includeList({
    _i1.WhereExpressionBuilder<UserAccountInfoTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserAccountInfoTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserAccountInfoTable>? orderByList,
    UserAccountInfoInclude? include,
  }) {
    return UserAccountInfoIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserAccountInfo.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(UserAccountInfo.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserAccountInfoImpl extends UserAccountInfo {
  _UserAccountInfoImpl({
    int? id,
    required String userEmail,
    required String fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? preferredCurrency,
    String? bio,
  }) : super._(
         id: id,
         userEmail: userEmail,
         fullName: fullName,
         phoneNumber: phoneNumber,
         avatarUrl: avatarUrl,
         preferredCurrency: preferredCurrency,
         bio: bio,
       );

  /// Returns a shallow copy of this [UserAccountInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserAccountInfo copyWith({
    Object? id = _Undefined,
    String? userEmail,
    String? fullName,
    Object? phoneNumber = _Undefined,
    Object? avatarUrl = _Undefined,
    Object? preferredCurrency = _Undefined,
    Object? bio = _Undefined,
  }) {
    return UserAccountInfo(
      id: id is int? ? id : this.id,
      userEmail: userEmail ?? this.userEmail,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber is String? ? phoneNumber : this.phoneNumber,
      avatarUrl: avatarUrl is String? ? avatarUrl : this.avatarUrl,
      preferredCurrency: preferredCurrency is String?
          ? preferredCurrency
          : this.preferredCurrency,
      bio: bio is String? ? bio : this.bio,
    );
  }
}

class UserAccountInfoUpdateTable extends _i1.UpdateTable<UserAccountInfoTable> {
  UserAccountInfoUpdateTable(super.table);

  _i1.ColumnValue<String, String> userEmail(String value) => _i1.ColumnValue(
    table.userEmail,
    value,
  );

  _i1.ColumnValue<String, String> fullName(String value) => _i1.ColumnValue(
    table.fullName,
    value,
  );

  _i1.ColumnValue<String, String> phoneNumber(String? value) => _i1.ColumnValue(
    table.phoneNumber,
    value,
  );

  _i1.ColumnValue<String, String> avatarUrl(String? value) => _i1.ColumnValue(
    table.avatarUrl,
    value,
  );

  _i1.ColumnValue<String, String> preferredCurrency(String? value) =>
      _i1.ColumnValue(
        table.preferredCurrency,
        value,
      );

  _i1.ColumnValue<String, String> bio(String? value) => _i1.ColumnValue(
    table.bio,
    value,
  );
}

class UserAccountInfoTable extends _i1.Table<int?> {
  UserAccountInfoTable({super.tableRelation})
    : super(tableName: 'user_account_info') {
    updateTable = UserAccountInfoUpdateTable(this);
    userEmail = _i1.ColumnString(
      'userEmail',
      this,
    );
    fullName = _i1.ColumnString(
      'fullName',
      this,
    );
    phoneNumber = _i1.ColumnString(
      'phoneNumber',
      this,
    );
    avatarUrl = _i1.ColumnString(
      'avatarUrl',
      this,
    );
    preferredCurrency = _i1.ColumnString(
      'preferredCurrency',
      this,
    );
    bio = _i1.ColumnString(
      'bio',
      this,
    );
  }

  late final UserAccountInfoUpdateTable updateTable;

  late final _i1.ColumnString userEmail;

  late final _i1.ColumnString fullName;

  late final _i1.ColumnString phoneNumber;

  late final _i1.ColumnString avatarUrl;

  late final _i1.ColumnString preferredCurrency;

  late final _i1.ColumnString bio;

  @override
  List<_i1.Column> get columns => [
    id,
    userEmail,
    fullName,
    phoneNumber,
    avatarUrl,
    preferredCurrency,
    bio,
  ];
}

class UserAccountInfoInclude extends _i1.IncludeObject {
  UserAccountInfoInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => UserAccountInfo.t;
}

class UserAccountInfoIncludeList extends _i1.IncludeList {
  UserAccountInfoIncludeList._({
    _i1.WhereExpressionBuilder<UserAccountInfoTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UserAccountInfo.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => UserAccountInfo.t;
}

class UserAccountInfoRepository {
  const UserAccountInfoRepository._();

  /// Returns a list of [UserAccountInfo]s matching the given query parameters.
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
  Future<List<UserAccountInfo>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserAccountInfoTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserAccountInfoTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserAccountInfoTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<UserAccountInfo>(
      where: where?.call(UserAccountInfo.t),
      orderBy: orderBy?.call(UserAccountInfo.t),
      orderByList: orderByList?.call(UserAccountInfo.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [UserAccountInfo] matching the given query parameters.
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
  Future<UserAccountInfo?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserAccountInfoTable>? where,
    int? offset,
    _i1.OrderByBuilder<UserAccountInfoTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserAccountInfoTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<UserAccountInfo>(
      where: where?.call(UserAccountInfo.t),
      orderBy: orderBy?.call(UserAccountInfo.t),
      orderByList: orderByList?.call(UserAccountInfo.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [UserAccountInfo] by its [id] or null if no such row exists.
  Future<UserAccountInfo?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<UserAccountInfo>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [UserAccountInfo]s in the list and returns the inserted rows.
  ///
  /// The returned [UserAccountInfo]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<UserAccountInfo>> insert(
    _i1.DatabaseSession session,
    List<UserAccountInfo> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<UserAccountInfo>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [UserAccountInfo] and returns the inserted row.
  ///
  /// The returned [UserAccountInfo] will have its `id` field set.
  Future<UserAccountInfo> insertRow(
    _i1.DatabaseSession session,
    UserAccountInfo row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserAccountInfo>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [UserAccountInfo]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<UserAccountInfo>> update(
    _i1.DatabaseSession session,
    List<UserAccountInfo> rows, {
    _i1.ColumnSelections<UserAccountInfoTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<UserAccountInfo>(
      rows,
      columns: columns?.call(UserAccountInfo.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserAccountInfo]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UserAccountInfo> updateRow(
    _i1.DatabaseSession session,
    UserAccountInfo row, {
    _i1.ColumnSelections<UserAccountInfoTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<UserAccountInfo>(
      row,
      columns: columns?.call(UserAccountInfo.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserAccountInfo] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UserAccountInfo?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<UserAccountInfoUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<UserAccountInfo>(
      id,
      columnValues: columnValues(UserAccountInfo.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UserAccountInfo]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<UserAccountInfo>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<UserAccountInfoUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<UserAccountInfoTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserAccountInfoTable>? orderBy,
    _i1.OrderByListBuilder<UserAccountInfoTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<UserAccountInfo>(
      columnValues: columnValues(UserAccountInfo.t.updateTable),
      where: where(UserAccountInfo.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserAccountInfo.t),
      orderByList: orderByList?.call(UserAccountInfo.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [UserAccountInfo]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<UserAccountInfo>> delete(
    _i1.DatabaseSession session,
    List<UserAccountInfo> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<UserAccountInfo>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [UserAccountInfo].
  Future<UserAccountInfo> deleteRow(
    _i1.DatabaseSession session,
    UserAccountInfo row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserAccountInfo>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<UserAccountInfo>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<UserAccountInfoTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<UserAccountInfo>(
      where: where(UserAccountInfo.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserAccountInfoTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<UserAccountInfo>(
      where: where?.call(UserAccountInfo.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [UserAccountInfo] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<UserAccountInfoTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<UserAccountInfo>(
      where: where(UserAccountInfo.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
