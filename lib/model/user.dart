import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class User{
  final int id;
  final String username;
  final String? email;
  final String? avatar;
  final String? introduction;
  final bool banned;

  int topicCount;
  int commentCount;
  int favoriteTopicsCount;
  int followersCount;
  int followingUsersCount;

  User({
    required this.id,
    required this.username,
    this.email,
    this.avatar,
    this.introduction,
    required this.banned,
    this.topicCount = 0,
    this.commentCount = 0,
    this.favoriteTopicsCount = 0,
    this.followersCount = 0,
    this.followingUsersCount = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  bool operator ==(Object other) =>
      (other is User) && id == other.id;

  @override
  int get hashCode => id;

  factory User.dummy() => User(
    id: 0,
    username: '匿名用户',
    banned: false,
  );
}