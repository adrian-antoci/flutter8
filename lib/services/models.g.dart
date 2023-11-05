// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PostCWProxy {
  Post id(String id);

  Post code(String code);

  Post copyCodeCount(int copyCodeCount);

  Post createdById(String createdById);

  Post createdByName(String createdByName);

  Post createdByAvatar(String createdByAvatar);

  Post createdAt(DateTime createdAt);

  Post isSeen(bool isSeen);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Post(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Post(...).copyWith(id: 12, name: "My name")
  /// ````
  Post call({
    String? id,
    String? code,
    int? copyCodeCount,
    String? createdById,
    String? createdByName,
    String? createdByAvatar,
    DateTime? createdAt,
    bool? isSeen,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPost.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPost.copyWith.fieldName(...)`
class _$PostCWProxyImpl implements _$PostCWProxy {
  const _$PostCWProxyImpl(this._value);

  final Post _value;

  @override
  Post id(String id) => this(id: id);

  @override
  Post code(String code) => this(code: code);

  @override
  Post copyCodeCount(int copyCodeCount) => this(copyCodeCount: copyCodeCount);

  @override
  Post createdById(String createdById) => this(createdById: createdById);

  @override
  Post createdByName(String createdByName) => this(createdByName: createdByName);

  @override
  Post createdByAvatar(String createdByAvatar) => this(createdByAvatar: createdByAvatar);

  @override
  Post createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  Post isSeen(bool isSeen) => this(isSeen: isSeen);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Post(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Post(...).copyWith(id: 12, name: "My name")
  /// ````
  Post call({
    Object? id = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? copyCodeCount = const $CopyWithPlaceholder(),
    Object? createdById = const $CopyWithPlaceholder(),
    Object? createdByName = const $CopyWithPlaceholder(),
    Object? createdByAvatar = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? isSeen = const $CopyWithPlaceholder(),
  }) {
    return Post(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      code: code == const $CopyWithPlaceholder() || code == null
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      copyCodeCount: copyCodeCount == const $CopyWithPlaceholder() || copyCodeCount == null
          ? _value.copyCodeCount
          // ignore: cast_nullable_to_non_nullable
          : copyCodeCount as int,
      createdById: createdById == const $CopyWithPlaceholder() || createdById == null
          ? _value.createdById
          // ignore: cast_nullable_to_non_nullable
          : createdById as String,
      createdByName: createdByName == const $CopyWithPlaceholder() || createdByName == null
          ? _value.createdByName
          // ignore: cast_nullable_to_non_nullable
          : createdByName as String,
      createdByAvatar: createdByAvatar == const $CopyWithPlaceholder() || createdByAvatar == null
          ? _value.createdByAvatar
          // ignore: cast_nullable_to_non_nullable
          : createdByAvatar as String,
      createdAt: createdAt == const $CopyWithPlaceholder() || createdAt == null
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $PostCopyWith on Post {
  /// Returns a callable class that can be used as follows: `instanceOfPost.copyWith(...)` or like so:`instanceOfPost.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PostCWProxy get copyWith => _$PostCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      code: json['code'] as String,
      copyCodeCount: json['copyCodeCount'] as int,
      createdById: json['createdById'] as String,
      createdByName: json['createdByName'] as String,
      createdByAvatar: json['createdByAvatar'] as String,
      createdAt: const FirestoreDateConverter().fromJson(json['createdAt'] as Timestamp),
    );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'createdByName': instance.createdByName,
      'createdByAvatar': instance.createdByAvatar,
      'createdById': instance.createdById,
      'code': instance.code,
      'copyCodeCount': instance.copyCodeCount,
      'createdAt': const FirestoreDateConverter().toJson(instance.createdAt),
    };
