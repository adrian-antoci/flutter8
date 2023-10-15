import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@CopyWith()
@JsonSerializable()
@FirestoreDateConverter()
class Post {
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String id;
  final String createdByName;
  final String createdByAvatar;
  final String createdById;
  final String code;
  final int copyCodeCount;
  final DateTime createdAt;
  final bool isSeen;

  Post(
      {this.id = '',
      required this.code,
      required this.copyCodeCount,
      required this.createdById,
      required this.createdByName,
      required this.createdByAvatar,
      required this.createdAt,
      this.isSeen = false});

  static Post fromJSON(Map<String, dynamic> json) => _$PostFromJson(json);

  static Post fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Post.fromJSON(snapshot.data()!).copyWith(id: snapshot.id);
  }

  Map<String, dynamic> toJSON() => _$PostToJson(this);
}

class APIError {
  APIError(this.code);

  final int code;
}

class FirestoreDateConverter implements JsonConverter<DateTime, Timestamp> {
  const FirestoreDateConverter();

  @override
  DateTime fromJson(Timestamp json) => json.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}
