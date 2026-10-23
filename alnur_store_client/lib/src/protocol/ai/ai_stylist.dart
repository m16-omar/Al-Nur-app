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

import 'package:serverpod_client/serverpod_client.dart' as _i1;
import '../products/store_product.dart' as _i2;
import 'package:alnur_store_client/src/protocol/protocol.dart' as _i3;

abstract class AiStylistResponse implements _i1.SerializableModel {
  AiStylistResponse._({
    required this.reply,
    this.occasion,
    this.modestyNote,
    this.recommendedProducts,
    this.suggestedPrompts,
    this.totalEstimatedCost,
  });

  factory AiStylistResponse({
    required String reply,
    String? occasion,
    String? modestyNote,
    List<_i2.StoreProduct>? recommendedProducts,
    List<String>? suggestedPrompts,
    double? totalEstimatedCost,
  }) = _AiStylistResponseImpl;

  factory AiStylistResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return AiStylistResponse(
      reply: jsonSerialization['reply'] as String,
      occasion: jsonSerialization['occasion'] as String?,
      modestyNote: jsonSerialization['modestyNote'] as String?,
      recommendedProducts: jsonSerialization['recommendedProducts'] == null
          ? null
          : _i3.Protocol().deserialize<List<_i2.StoreProduct>>(
              jsonSerialization['recommendedProducts'],
            ),
      suggestedPrompts: jsonSerialization['suggestedPrompts'] == null
          ? null
          : _i3.Protocol().deserialize<List<String>>(
              jsonSerialization['suggestedPrompts'],
            ),
      totalEstimatedCost: (jsonSerialization['totalEstimatedCost'] as num?)
          ?.toDouble(),
    );
  }

  String reply;

  String? occasion;

  String? modestyNote;

  List<_i2.StoreProduct>? recommendedProducts;

  List<String>? suggestedPrompts;

  double? totalEstimatedCost;

  /// Returns a shallow copy of this [AiStylistResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AiStylistResponse copyWith({
    String? reply,
    String? occasion,
    String? modestyNote,
    List<_i2.StoreProduct>? recommendedProducts,
    List<String>? suggestedPrompts,
    double? totalEstimatedCost,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AiStylistResponse',
      'reply': reply,
      if (occasion != null) 'occasion': occasion,
      if (modestyNote != null) 'modestyNote': modestyNote,
      if (recommendedProducts != null)
        'recommendedProducts': recommendedProducts?.toJson(
          valueToJson: (v) => v.toJson(),
        ),
      if (suggestedPrompts != null)
        'suggestedPrompts': suggestedPrompts?.toJson(),
      if (totalEstimatedCost != null) 'totalEstimatedCost': totalEstimatedCost,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AiStylistResponseImpl extends AiStylistResponse {
  _AiStylistResponseImpl({
    required String reply,
    String? occasion,
    String? modestyNote,
    List<_i2.StoreProduct>? recommendedProducts,
    List<String>? suggestedPrompts,
    double? totalEstimatedCost,
  }) : super._(
         reply: reply,
         occasion: occasion,
         modestyNote: modestyNote,
         recommendedProducts: recommendedProducts,
         suggestedPrompts: suggestedPrompts,
         totalEstimatedCost: totalEstimatedCost,
       );

  /// Returns a shallow copy of this [AiStylistResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AiStylistResponse copyWith({
    String? reply,
    Object? occasion = _Undefined,
    Object? modestyNote = _Undefined,
    Object? recommendedProducts = _Undefined,
    Object? suggestedPrompts = _Undefined,
    Object? totalEstimatedCost = _Undefined,
  }) {
    return AiStylistResponse(
      reply: reply ?? this.reply,
      occasion: occasion is String? ? occasion : this.occasion,
      modestyNote: modestyNote is String? ? modestyNote : this.modestyNote,
      recommendedProducts: recommendedProducts is List<_i2.StoreProduct>?
          ? recommendedProducts
          : this.recommendedProducts?.map((e0) => e0.copyWith()).toList(),
      suggestedPrompts: suggestedPrompts is List<String>?
          ? suggestedPrompts
          : this.suggestedPrompts?.map((e0) => e0).toList(),
      totalEstimatedCost: totalEstimatedCost is double?
          ? totalEstimatedCost
          : this.totalEstimatedCost,
    );
  }
}
