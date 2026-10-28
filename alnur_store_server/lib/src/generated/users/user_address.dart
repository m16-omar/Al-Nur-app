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

abstract class UserAddress
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  UserAddress._({
    this.id,
    required this.userEmail,
    required this.title,
    required this.recipientName,
    required this.phoneNumber,
    required this.streetAddress,
    required this.city,
    required this.state,
    this.country,
    this.postalCode,
    required this.isDefault,
    this.additionalInstructions,
  });

  factory UserAddress({
    int? id,
    required String userEmail,
    required String title,
    required String recipientName,
    required String phoneNumber,
    required String streetAddress,
    required String city,
    required String state,
    String? country,
    String? postalCode,
    required bool isDefault,
    String? additionalInstructions,
  }) = _UserAddressImpl;

  factory UserAddress.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserAddress(
      id: jsonSerialization['id'] as int?,
      userEmail: jsonSerialization['userEmail'] as String,
      title: jsonSerialization['title'] as String,
      recipientName: jsonSerialization['recipientName'] as String,
      phoneNumber: jsonSerialization['phoneNumber'] as String,
      streetAddress: jsonSerialization['streetAddress'] as String,
      city: jsonSerialization['city'] as String,
      state: jsonSerialization['state'] as String,
      country: jsonSerialization['country'] as String?,
      postalCode: jsonSerialization['postalCode'] as String?,
      isDefault: _i1.BoolJsonExtension.fromJson(jsonSerialization['isDefault']),
      additionalInstructions:
          jsonSerialization['additionalInstructions'] as String?,
    );
  }

  static final t = UserAddressTable();

  static const db = UserAddressRepository._();

  @override
  int? id;

  String userEmail;

  String title;

  String recipientName;

  String phoneNumber;

  String streetAddress;

  String city;

  String state;

  String? country;

  String? postalCode;

  bool isDefault;

  String? additionalInstructions;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [UserAddress]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserAddress copyWith({
    int? id,
    String? userEmail,
    String? title,
    String? recipientName,
    String? phoneNumber,
    String? streetAddress,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    bool? isDefault,
    String? additionalInstructions,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserAddress',
      if (id != null) 'id': id,
      'userEmail': userEmail,
      'title': title,
      'recipientName': recipientName,
      'phoneNumber': phoneNumber,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      if (country != null) 'country': country,
      if (postalCode != null) 'postalCode': postalCode,
      'isDefault': isDefault,
      if (additionalInstructions != null)
        'additionalInstructions': additionalInstructions,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserAddress',
      if (id != null) 'id': id,
      'userEmail': userEmail,
      'title': title,
      'recipientName': recipientName,
      'phoneNumber': phoneNumber,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      if (country != null) 'country': country,
      if (postalCode != null) 'postalCode': postalCode,
      'isDefault': isDefault,
      if (additionalInstructions != null)
        'additionalInstructions': additionalInstructions,
    };
  }

  static UserAddressInclude include() {
    return UserAddressInclude._();
  }

  static UserAddressIncludeList includeList({
    _i1.WhereExpressionBuilder<UserAddressTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserAddressTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserAddressTable>? orderByList,
    UserAddressInclude? include,
  }) {
    return UserAddressIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserAddress.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(UserAddress.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserAddressImpl extends UserAddress {
  _UserAddressImpl({
    int? id,
    required String userEmail,
    required String title,
    required String recipientName,
    required String phoneNumber,
    required String streetAddress,
    required String city,
    required String state,
    String? country,
    String? postalCode,
    required bool isDefault,
    String? additionalInstructions,
  }) : super._(
         id: id,
         userEmail: userEmail,
         title: title,
         recipientName: recipientName,
         phoneNumber: phoneNumber,
         streetAddress: streetAddress,
         city: city,
         state: state,
         country: country,
         postalCode: postalCode,
         isDefault: isDefault,
         additionalInstructions: additionalInstructions,
       );

  /// Returns a shallow copy of this [UserAddress]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserAddress copyWith({
    Object? id = _Undefined,
    String? userEmail,
    String? title,
    String? recipientName,
    String? phoneNumber,
    String? streetAddress,
    String? city,
    String? state,
    Object? country = _Undefined,
    Object? postalCode = _Undefined,
    bool? isDefault,
    Object? additionalInstructions = _Undefined,
  }) {
    return UserAddress(
      id: id is int? ? id : this.id,
      userEmail: userEmail ?? this.userEmail,
      title: title ?? this.title,
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      streetAddress: streetAddress ?? this.streetAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country is String? ? country : this.country,
      postalCode: postalCode is String? ? postalCode : this.postalCode,
      isDefault: isDefault ?? this.isDefault,
      additionalInstructions: additionalInstructions is String?
          ? additionalInstructions
          : this.additionalInstructions,
    );
  }
}

class UserAddressUpdateTable extends _i1.UpdateTable<UserAddressTable> {
  UserAddressUpdateTable(super.table);

  _i1.ColumnValue<String, String> userEmail(String value) => _i1.ColumnValue(
    table.userEmail,
    value,
  );

  _i1.ColumnValue<String, String> title(String value) => _i1.ColumnValue(
    table.title,
    value,
  );

  _i1.ColumnValue<String, String> recipientName(String value) =>
      _i1.ColumnValue(
        table.recipientName,
        value,
      );

  _i1.ColumnValue<String, String> phoneNumber(String value) => _i1.ColumnValue(
    table.phoneNumber,
    value,
  );

  _i1.ColumnValue<String, String> streetAddress(String value) =>
      _i1.ColumnValue(
        table.streetAddress,
        value,
      );

  _i1.ColumnValue<String, String> city(String value) => _i1.ColumnValue(
    table.city,
    value,
  );

  _i1.ColumnValue<String, String> state(String value) => _i1.ColumnValue(
    table.state,
    value,
  );

  _i1.ColumnValue<String, String> country(String? value) => _i1.ColumnValue(
    table.country,
    value,
  );

  _i1.ColumnValue<String, String> postalCode(String? value) => _i1.ColumnValue(
    table.postalCode,
    value,
  );

  _i1.ColumnValue<bool, bool> isDefault(bool value) => _i1.ColumnValue(
    table.isDefault,
    value,
  );

  _i1.ColumnValue<String, String> additionalInstructions(String? value) =>
      _i1.ColumnValue(
        table.additionalInstructions,
        value,
      );
}

class UserAddressTable extends _i1.Table<int?> {
  UserAddressTable({super.tableRelation}) : super(tableName: 'user_address') {
    updateTable = UserAddressUpdateTable(this);
    userEmail = _i1.ColumnString(
      'userEmail',
      this,
    );
    title = _i1.ColumnString(
      'title',
      this,
    );
    recipientName = _i1.ColumnString(
      'recipientName',
      this,
    );
    phoneNumber = _i1.ColumnString(
      'phoneNumber',
      this,
    );
    streetAddress = _i1.ColumnString(
      'streetAddress',
      this,
    );
    city = _i1.ColumnString(
      'city',
      this,
    );
    state = _i1.ColumnString(
      'state',
      this,
    );
    country = _i1.ColumnString(
      'country',
      this,
    );
    postalCode = _i1.ColumnString(
      'postalCode',
      this,
    );
    isDefault = _i1.ColumnBool(
      'isDefault',
      this,
    );
    additionalInstructions = _i1.ColumnString(
      'additionalInstructions',
      this,
    );
  }

  late final UserAddressUpdateTable updateTable;

  late final _i1.ColumnString userEmail;

  late final _i1.ColumnString title;

  late final _i1.ColumnString recipientName;

  late final _i1.ColumnString phoneNumber;

  late final _i1.ColumnString streetAddress;

  late final _i1.ColumnString city;

  late final _i1.ColumnString state;

  late final _i1.ColumnString country;

  late final _i1.ColumnString postalCode;

  late final _i1.ColumnBool isDefault;

  late final _i1.ColumnString additionalInstructions;

  @override
  List<_i1.Column> get columns => [
    id,
    userEmail,
    title,
    recipientName,
    phoneNumber,
    streetAddress,
    city,
    state,
    country,
    postalCode,
    isDefault,
    additionalInstructions,
  ];
}

class UserAddressInclude extends _i1.IncludeObject {
  UserAddressInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => UserAddress.t;
}

class UserAddressIncludeList extends _i1.IncludeList {
  UserAddressIncludeList._({
    _i1.WhereExpressionBuilder<UserAddressTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UserAddress.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => UserAddress.t;
}

class UserAddressRepository {
  const UserAddressRepository._();

  /// Returns a list of [UserAddress]s matching the given query parameters.
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
  Future<List<UserAddress>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserAddressTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserAddressTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserAddressTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<UserAddress>(
      where: where?.call(UserAddress.t),
      orderBy: orderBy?.call(UserAddress.t),
      orderByList: orderByList?.call(UserAddress.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [UserAddress] matching the given query parameters.
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
  Future<UserAddress?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserAddressTable>? where,
    int? offset,
    _i1.OrderByBuilder<UserAddressTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserAddressTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<UserAddress>(
      where: where?.call(UserAddress.t),
      orderBy: orderBy?.call(UserAddress.t),
      orderByList: orderByList?.call(UserAddress.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [UserAddress] by its [id] or null if no such row exists.
  Future<UserAddress?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<UserAddress>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [UserAddress]s in the list and returns the inserted rows.
  ///
  /// The returned [UserAddress]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<UserAddress>> insert(
    _i1.DatabaseSession session,
    List<UserAddress> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<UserAddress>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [UserAddress] and returns the inserted row.
  ///
  /// The returned [UserAddress] will have its `id` field set.
  Future<UserAddress> insertRow(
    _i1.DatabaseSession session,
    UserAddress row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserAddress>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [UserAddress]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<UserAddress>> update(
    _i1.DatabaseSession session,
    List<UserAddress> rows, {
    _i1.ColumnSelections<UserAddressTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<UserAddress>(
      rows,
      columns: columns?.call(UserAddress.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserAddress]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UserAddress> updateRow(
    _i1.DatabaseSession session,
    UserAddress row, {
    _i1.ColumnSelections<UserAddressTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<UserAddress>(
      row,
      columns: columns?.call(UserAddress.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserAddress] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UserAddress?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<UserAddressUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<UserAddress>(
      id,
      columnValues: columnValues(UserAddress.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UserAddress]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<UserAddress>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<UserAddressUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<UserAddressTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserAddressTable>? orderBy,
    _i1.OrderByListBuilder<UserAddressTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<UserAddress>(
      columnValues: columnValues(UserAddress.t.updateTable),
      where: where(UserAddress.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserAddress.t),
      orderByList: orderByList?.call(UserAddress.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [UserAddress]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<UserAddress>> delete(
    _i1.DatabaseSession session,
    List<UserAddress> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<UserAddress>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [UserAddress].
  Future<UserAddress> deleteRow(
    _i1.DatabaseSession session,
    UserAddress row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserAddress>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<UserAddress>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<UserAddressTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<UserAddress>(
      where: where(UserAddress.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserAddressTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<UserAddress>(
      where: where?.call(UserAddress.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [UserAddress] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<UserAddressTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<UserAddress>(
      where: where(UserAddress.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
