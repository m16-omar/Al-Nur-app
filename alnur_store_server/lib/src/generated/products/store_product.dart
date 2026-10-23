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
import 'package:alnur_store_server/src/generated/protocol.dart' as _i2;

abstract class StoreProduct
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  StoreProduct._({
    this.id,
    required this.name,
    required this.slug,
    required this.categoryId,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.description,
    required this.isAvailable,
    this.isFavorite,
    this.colors,
    this.sizes,
  });

  factory StoreProduct({
    int? id,
    required String name,
    required String slug,
    required String categoryId,
    required double price,
    double? originalPrice,
    required double rating,
    required int reviewCount,
    required String imageUrl,
    required String description,
    required bool isAvailable,
    bool? isFavorite,
    List<String>? colors,
    List<String>? sizes,
  }) = _StoreProductImpl;

  factory StoreProduct.fromJson(Map<String, dynamic> jsonSerialization) {
    return StoreProduct(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      slug: jsonSerialization['slug'] as String,
      categoryId: jsonSerialization['categoryId'] as String,
      price: (jsonSerialization['price'] as num).toDouble(),
      originalPrice: (jsonSerialization['originalPrice'] as num?)?.toDouble(),
      rating: (jsonSerialization['rating'] as num).toDouble(),
      reviewCount: jsonSerialization['reviewCount'] as int,
      imageUrl: jsonSerialization['imageUrl'] as String,
      description: jsonSerialization['description'] as String,
      isAvailable: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['isAvailable'],
      ),
      isFavorite: jsonSerialization['isFavorite'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isFavorite']),
      colors: jsonSerialization['colors'] == null
          ? null
          : _i2.Protocol().deserialize<List<String>>(
              jsonSerialization['colors'],
            ),
      sizes: jsonSerialization['sizes'] == null
          ? null
          : _i2.Protocol().deserialize<List<String>>(
              jsonSerialization['sizes'],
            ),
    );
  }

  static final t = StoreProductTable();

  static const db = StoreProductRepository._();

  @override
  int? id;

  String name;

  String slug;

  String categoryId;

  double price;

  double? originalPrice;

  double rating;

  int reviewCount;

  String imageUrl;

  String description;

  bool isAvailable;

  bool? isFavorite;

  List<String>? colors;

  List<String>? sizes;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [StoreProduct]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  StoreProduct copyWith({
    int? id,
    String? name,
    String? slug,
    String? categoryId,
    double? price,
    double? originalPrice,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    String? description,
    bool? isAvailable,
    bool? isFavorite,
    List<String>? colors,
    List<String>? sizes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StoreProduct',
      if (id != null) 'id': id,
      'name': name,
      'slug': slug,
      'categoryId': categoryId,
      'price': price,
      if (originalPrice != null) 'originalPrice': originalPrice,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'description': description,
      'isAvailable': isAvailable,
      if (isFavorite != null) 'isFavorite': isFavorite,
      if (colors != null) 'colors': colors?.toJson(),
      if (sizes != null) 'sizes': sizes?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'StoreProduct',
      if (id != null) 'id': id,
      'name': name,
      'slug': slug,
      'categoryId': categoryId,
      'price': price,
      if (originalPrice != null) 'originalPrice': originalPrice,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'description': description,
      'isAvailable': isAvailable,
      if (isFavorite != null) 'isFavorite': isFavorite,
      if (colors != null) 'colors': colors?.toJson(),
      if (sizes != null) 'sizes': sizes?.toJson(),
    };
  }

  static StoreProductInclude include() {
    return StoreProductInclude._();
  }

  static StoreProductIncludeList includeList({
    _i1.WhereExpressionBuilder<StoreProductTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<StoreProductTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<StoreProductTable>? orderByList,
    StoreProductInclude? include,
  }) {
    return StoreProductIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StoreProduct.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(StoreProduct.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StoreProductImpl extends StoreProduct {
  _StoreProductImpl({
    int? id,
    required String name,
    required String slug,
    required String categoryId,
    required double price,
    double? originalPrice,
    required double rating,
    required int reviewCount,
    required String imageUrl,
    required String description,
    required bool isAvailable,
    bool? isFavorite,
    List<String>? colors,
    List<String>? sizes,
  }) : super._(
         id: id,
         name: name,
         slug: slug,
         categoryId: categoryId,
         price: price,
         originalPrice: originalPrice,
         rating: rating,
         reviewCount: reviewCount,
         imageUrl: imageUrl,
         description: description,
         isAvailable: isAvailable,
         isFavorite: isFavorite,
         colors: colors,
         sizes: sizes,
       );

  /// Returns a shallow copy of this [StoreProduct]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  StoreProduct copyWith({
    Object? id = _Undefined,
    String? name,
    String? slug,
    String? categoryId,
    double? price,
    Object? originalPrice = _Undefined,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    String? description,
    bool? isAvailable,
    Object? isFavorite = _Undefined,
    Object? colors = _Undefined,
    Object? sizes = _Undefined,
  }) {
    return StoreProduct(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      originalPrice: originalPrice is double?
          ? originalPrice
          : this.originalPrice,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      isFavorite: isFavorite is bool? ? isFavorite : this.isFavorite,
      colors: colors is List<String>?
          ? colors
          : this.colors?.map((e0) => e0).toList(),
      sizes: sizes is List<String>?
          ? sizes
          : this.sizes?.map((e0) => e0).toList(),
    );
  }
}

class StoreProductUpdateTable extends _i1.UpdateTable<StoreProductTable> {
  StoreProductUpdateTable(super.table);

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> slug(String value) => _i1.ColumnValue(
    table.slug,
    value,
  );

  _i1.ColumnValue<String, String> categoryId(String value) => _i1.ColumnValue(
    table.categoryId,
    value,
  );

  _i1.ColumnValue<double, double> price(double value) => _i1.ColumnValue(
    table.price,
    value,
  );

  _i1.ColumnValue<double, double> originalPrice(double? value) =>
      _i1.ColumnValue(
        table.originalPrice,
        value,
      );

  _i1.ColumnValue<double, double> rating(double value) => _i1.ColumnValue(
    table.rating,
    value,
  );

  _i1.ColumnValue<int, int> reviewCount(int value) => _i1.ColumnValue(
    table.reviewCount,
    value,
  );

  _i1.ColumnValue<String, String> imageUrl(String value) => _i1.ColumnValue(
    table.imageUrl,
    value,
  );

  _i1.ColumnValue<String, String> description(String value) => _i1.ColumnValue(
    table.description,
    value,
  );

  _i1.ColumnValue<bool, bool> isAvailable(bool value) => _i1.ColumnValue(
    table.isAvailable,
    value,
  );

  _i1.ColumnValue<bool, bool> isFavorite(bool? value) => _i1.ColumnValue(
    table.isFavorite,
    value,
  );

  _i1.ColumnValue<List<String>, List<String>> colors(List<String>? value) =>
      _i1.ColumnValue(
        table.colors,
        value,
      );

  _i1.ColumnValue<List<String>, List<String>> sizes(List<String>? value) =>
      _i1.ColumnValue(
        table.sizes,
        value,
      );
}

class StoreProductTable extends _i1.Table<int?> {
  StoreProductTable({super.tableRelation}) : super(tableName: 'store_product') {
    updateTable = StoreProductUpdateTable(this);
    name = _i1.ColumnString(
      'name',
      this,
    );
    slug = _i1.ColumnString(
      'slug',
      this,
    );
    categoryId = _i1.ColumnString(
      'categoryId',
      this,
    );
    price = _i1.ColumnDouble(
      'price',
      this,
    );
    originalPrice = _i1.ColumnDouble(
      'originalPrice',
      this,
    );
    rating = _i1.ColumnDouble(
      'rating',
      this,
    );
    reviewCount = _i1.ColumnInt(
      'reviewCount',
      this,
    );
    imageUrl = _i1.ColumnString(
      'imageUrl',
      this,
    );
    description = _i1.ColumnString(
      'description',
      this,
    );
    isAvailable = _i1.ColumnBool(
      'isAvailable',
      this,
    );
    isFavorite = _i1.ColumnBool(
      'isFavorite',
      this,
    );
    colors = _i1.ColumnSerializable<List<String>>(
      'colors',
      this,
    );
    sizes = _i1.ColumnSerializable<List<String>>(
      'sizes',
      this,
    );
  }

  late final StoreProductUpdateTable updateTable;

  late final _i1.ColumnString name;

  late final _i1.ColumnString slug;

  late final _i1.ColumnString categoryId;

  late final _i1.ColumnDouble price;

  late final _i1.ColumnDouble originalPrice;

  late final _i1.ColumnDouble rating;

  late final _i1.ColumnInt reviewCount;

  late final _i1.ColumnString imageUrl;

  late final _i1.ColumnString description;

  late final _i1.ColumnBool isAvailable;

  late final _i1.ColumnBool isFavorite;

  late final _i1.ColumnSerializable<List<String>> colors;

  late final _i1.ColumnSerializable<List<String>> sizes;

  @override
  List<_i1.Column> get columns => [
    id,
    name,
    slug,
    categoryId,
    price,
    originalPrice,
    rating,
    reviewCount,
    imageUrl,
    description,
    isAvailable,
    isFavorite,
    colors,
    sizes,
  ];
}

class StoreProductInclude extends _i1.IncludeObject {
  StoreProductInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => StoreProduct.t;
}

class StoreProductIncludeList extends _i1.IncludeList {
  StoreProductIncludeList._({
    _i1.WhereExpressionBuilder<StoreProductTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StoreProduct.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => StoreProduct.t;
}

class StoreProductRepository {
  const StoreProductRepository._();

  /// Returns a list of [StoreProduct]s matching the given query parameters.
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
  Future<List<StoreProduct>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<StoreProductTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<StoreProductTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<StoreProductTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StoreProduct>(
      where: where?.call(StoreProduct.t),
      orderBy: orderBy?.call(StoreProduct.t),
      orderByList: orderByList?.call(StoreProduct.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [StoreProduct] matching the given query parameters.
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
  Future<StoreProduct?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<StoreProductTable>? where,
    int? offset,
    _i1.OrderByBuilder<StoreProductTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<StoreProductTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StoreProduct>(
      where: where?.call(StoreProduct.t),
      orderBy: orderBy?.call(StoreProduct.t),
      orderByList: orderByList?.call(StoreProduct.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StoreProduct] by its [id] or null if no such row exists.
  Future<StoreProduct?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StoreProduct>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StoreProduct]s in the list and returns the inserted rows.
  ///
  /// The returned [StoreProduct]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<StoreProduct>> insert(
    _i1.DatabaseSession session,
    List<StoreProduct> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<StoreProduct>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [StoreProduct] and returns the inserted row.
  ///
  /// The returned [StoreProduct] will have its `id` field set.
  Future<StoreProduct> insertRow(
    _i1.DatabaseSession session,
    StoreProduct row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<StoreProduct>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [StoreProduct]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<StoreProduct>> update(
    _i1.DatabaseSession session,
    List<StoreProduct> rows, {
    _i1.ColumnSelections<StoreProductTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<StoreProduct>(
      rows,
      columns: columns?.call(StoreProduct.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StoreProduct]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StoreProduct> updateRow(
    _i1.DatabaseSession session,
    StoreProduct row, {
    _i1.ColumnSelections<StoreProductTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<StoreProduct>(
      row,
      columns: columns?.call(StoreProduct.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StoreProduct] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StoreProduct?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<StoreProductUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<StoreProduct>(
      id,
      columnValues: columnValues(StoreProduct.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StoreProduct]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<StoreProduct>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<StoreProductUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<StoreProductTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<StoreProductTable>? orderBy,
    _i1.OrderByListBuilder<StoreProductTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<StoreProduct>(
      columnValues: columnValues(StoreProduct.t.updateTable),
      where: where(StoreProduct.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StoreProduct.t),
      orderByList: orderByList?.call(StoreProduct.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [StoreProduct]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<StoreProduct>> delete(
    _i1.DatabaseSession session,
    List<StoreProduct> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<StoreProduct>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [StoreProduct].
  Future<StoreProduct> deleteRow(
    _i1.DatabaseSession session,
    StoreProduct row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StoreProduct>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<StoreProduct>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<StoreProductTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<StoreProduct>(
      where: where(StoreProduct.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<StoreProductTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<StoreProduct>(
      where: where?.call(StoreProduct.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StoreProduct] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<StoreProductTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StoreProduct>(
      where: where(StoreProduct.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
