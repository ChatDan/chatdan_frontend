import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:chatdan_frontend/model/message_box.dart';
import 'package:chatdan_frontend/model/post.dart';
import 'package:chatdan_frontend/provider/chatdan_provider.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/channel.dart';
import '../model/chat.dart';
import '../model/comment.dart';
import '../model/division.dart';
import '../model/message.dart';
import '../model/tag.dart';
import '../model/topic.dart';
import '../model/user.dart';
import '../model/wall.dart';

class ChatDanRepository {
  static final ChatDanRepository _instance = ChatDanRepository._internal();

  factory ChatDanRepository() => _instance;

  static const String _baseUrl = 'https://chatdan.top/api';
  static const String _imageBaseUrl = 'https://image.chatdan.top';

  final ChatDanProvider _provider = ChatDanProvider();

  ChatDanProvider get provider => _provider;

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      receiveDataWhenStatusError: true,
      validateStatus: (int? status) => status != null && status >= 200 && status < 300,
    ),
  );

  ChatDanRepository._internal() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          if (_provider.accessToken != null) {
            options.headers['Authorization'] = 'Bearer ${_provider.accessToken}';
          }
          print('Request: ${options.method} ${options.uri}');
          print('Request headers: ${options.headers}');
          return handler.next(options);
        },
        onError: (DioError error, ErrorInterceptorHandler handler) async {
          print('Error: ${error.message}');
          print('Error response: ${error.response}');
          int statusCode = error.response?.statusCode ?? 0;
          String dialogMessage;
          switch (error.type) {
            case DioErrorType.cancel:
              dialogMessage = '请求被取消';
              break;
            case DioErrorType.connectionTimeout:
              dialogMessage = '连接超时';
              break;
            case DioErrorType.sendTimeout:
              dialogMessage = '请求超时';
              break;
            case DioErrorType.receiveTimeout:
              dialogMessage = '响应超时';
              break;
            case DioErrorType.badCertificate:
              dialogMessage = '证书验证失败';
              break;
            case DioErrorType.badResponse:
              dialogMessage = '响应异常';
              final data = error.response?.data;
              if (data is Map<String, dynamic>) {
                if (data['error_msg'] is String) {
                  dialogMessage = data['error_msg'] as String;
                } else if (data['message'] is String) {
                  dialogMessage = data['message'] as String;
                }
              } else if (data is String) {
                dialogMessage = data;
                try {
                  var dataMap = jsonDecode(data);
                  if (dataMap['error_msg'] is String) {
                    dialogMessage = dataMap['error_msg'] as String;
                  } else if (dataMap['message'] is String) {
                    dialogMessage = dataMap['message'] as String;
                  }
                } catch (_) {}
              }
              break;
            case DioErrorType.connectionError:
              dialogMessage = '网络连接异常';
              break;
            case DioErrorType.unknown:
              dialogMessage = '未知错误';
              print(error.error.toString());
              break;
          }
          if (statusCode == 401) {
            await _provider.clear();
          }
          try {
            Fluttertoast.showToast(
              msg: dialogMessage,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
            );
          } catch (e) {
            // do nothing
          }

          return handler.next(error);
        },
        onResponse: (Response response, ResponseInterceptorHandler handler) {
          print('Response: ${response.statusCode} ${response.requestOptions.uri}');
          print('Response headers: ${response.headers}');
          print('Response Body: ${response.data}');
          return handler.next(response);
        },
      ),
    );
    // 关闭证书验证
    (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  /* User 用户模块 */

  Future<void> loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    if (accessToken == null) {
      return;
    }
    _provider.accessToken = accessToken;

    try {
      _provider.userInfo = await loadUserMeInfo();
    } catch (e) {
      print(e);
    }
  }

  Future<void> register(
    String username,
    String password,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.post(
      '$_baseUrl/user/register',
      data: <String, String>{
        'username': username,
        'password': password,
      },
    );
    final Map<String, dynamic> data = response.data!['data'] as Map<String, dynamic>;
    provider.userInfo = User.fromJson(data);
    provider.accessToken = data['access_token'] as String;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', provider.accessToken!);
  }

  Future<void> login(
    String username,
    String password,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.post(
      '$_baseUrl/user/login',
      data: <String, String>{
        'username': username,
        'password': password,
      },
    );

    final Map<String, dynamic> data = response.data!['data'] as Map<String, dynamic>;
    provider.userInfo = User.fromJson(data);
    provider.accessToken = data['access_token'] as String;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', provider.accessToken!);
    return;
  }

  Future<void> logout() async {
    await _dio.post(
      '$_baseUrl/user/logout',
    );

    provider.clear();
  }

  Future<User> loadUserInfo({
    required int userId,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/user/$userId',
    );
    return User.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  Future<User?> loadUserMeInfo() async {
    try {
      final Response<Map<String, dynamic>> response = await _dio.get(
        '$_baseUrl/user/me',
      );
      return User.fromJson(response.data!['data'] as Map<String, dynamic>);
    } catch (e) {
      // do nothing
      return null;
    }
  }

  Future<User> modifyUserMe({
    String? email,
    String? avatar,
    String? introduction,
    String? username,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio.put(
      '$_baseUrl/user/me',
      data: <String, dynamic>{
        if (email != null) 'email': email,
        if (avatar != null) 'avatar': avatar,
        if (introduction != null) 'introduction': introduction,
        if (username != null) 'username': username,
      },
    );

    return User.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  Future<List<User>?> searchUsers({
    int pageNum = 1,
    int pageSize = 10,
    required String search,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/users/_search',
      queryParameters: <String, dynamic>{
        'page_num': pageNum,
        'page_size': pageSize,
        'search': search,
      },
    );

    return (response.data!['data']!['users'] as List<dynamic>?)
        ?.map((dynamic e) => User.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /* Message Box 提问箱 */

  Future<List<MessageBox>?> loadMessageBoxes({
    required int pageNum,
    required int pageSize,
    int? owner,
    String? title,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/messageBoxes',
      queryParameters: <String, dynamic>{
        'page_num': pageNum,
        'page_size': pageSize,
        if (owner != null) 'owner': owner,
        if (title != null) 'title': title,
      },
    );
    return (response.data!['data']!['messageBoxes'] as List<dynamic>?)
        ?.map((dynamic e) => MessageBox.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MessageBox> createAMessageBox(
    String title,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.post(
      '$_baseUrl/messageBox',
      data: <String, String>{
        'title': title,
      },
    );
    return MessageBox.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  Future<MessageBox> loadAMessageBox(
    int id,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/messageBox/$id',
    );
    return MessageBox.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  Future<MessageBox> updateAMessageBox(
    int id,
    String title,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.put(
      '$_baseUrl/messageBox/$id',
      data: <String, String>{
        'title': title,
      },
    );
    return MessageBox.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  Future<void> deleteAMessageBox(
    int id,
  ) async {
    await _dio.delete(
      '$_baseUrl/messageBox/$id',
    );
  }

  /* Post 帖子、回复 */

  Future<List<Post>?> loadPosts({
    required int pageNum,
    required int pageSize,
    required int messageBoxId,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/posts',
      queryParameters: <String, dynamic>{
        'page_num': pageNum,
        'page_size': pageSize,
        'message_box_id': messageBoxId,
      },
    );
    return (response.data!['data']!['posts'] as List<dynamic>?)
        ?.map((dynamic e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Post> createAPost({
    required int messageBoxId,
    required String content,
    required bool isAnonymous,
    required bool isPublic,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio.post(
      '$_baseUrl/post',
      data: <String, dynamic>{
        'message_box_id': messageBoxId,
        'content': content,
        'is_anonymous': isAnonymous,
        'visibility': isPublic ? 'public' : 'private',
      },
    );
    return Post.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  Future<Post> loadAPost(
    int id,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/post/$id',
    );
    return Post.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  Future<Post> updateAPost(
    int id,
    String content,
    bool isPublic,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.put(
      '$_baseUrl/post/$id',
      data: <String, dynamic>{
        'content': content,
        'visibility': isPublic ? 'public' : 'private',
      },
    );
    return Post.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  Future<void> deleteAPost(
    int id,
  ) async {
    await _dio.delete(
      '$_baseUrl/post/$id',
    );
  }

  /* Channel 回复 thread */
  Future<List<Channel>?> loadChannels(
    int pageNum,
    int pageSize,
    int postId,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/channels',
      queryParameters: <String, dynamic>{
        'page_num': pageNum,
        'page_size': pageSize,
        'post_id': postId,
      },
    );
    return (response.data!['data']!['channels'] as List<dynamic>?)
        ?.map((dynamic e) => Channel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Create a Channel
  Future<Channel> createAChannel(
    int postId,
    String content,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.post(
      '$_baseUrl/channel',
      data: <String, dynamic>{
        'post_id': postId,
        'content': content,
      },
    );
    return Channel.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  // Load a Channel
  Future<Channel> loadAChannel(
    int id,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/channel/$id',
    );
    return Channel.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  // Update a Channel
  Future<Channel> updateAChannel(
    int id,
    String content,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.put(
      '$_baseUrl/channel/$id',
      data: <String, dynamic>{
        'content': content,
      },
    );
    return Channel.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  // Delete a Channel
  Future<void> deleteAChannel(
    int id,
  ) async {
    await _dio.delete(
      '$_baseUrl/channel/$id',
    );
  }

  /* Wall 表白墙 */
  // Load walls 获取今日表白墙
  Future<List<Wall>?> loadWalls({
    DateTime? date,
    required int pageNum,
    required int pageSize,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/wall',
      queryParameters: <String, dynamic>{
        if (date != null) 'date': '${date.toIso8601String()}+08:00',
        'page_num': pageNum,
        'page_size': pageSize,
      },
    );
    return (response.data!['data']!['posts'] as List<dynamic>?)
        ?.map((dynamic e) => Wall.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Create a Wall
  Future<Wall> createAWall(
    String content,
    bool isAnonymous,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.post(
      '$_baseUrl/wall',
      data: <String, dynamic>{
        'content': content,
        'is_anonymous': isAnonymous,
      },
    );
    return Wall.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  // Load a Wall
  Future<Wall> loadAWall(
    int id,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/wall/$id',
    );
    return Wall.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  /* Chat 私聊 */
  // Load chats
  Future<List<Chat>?> loadChats() async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/chats',
    );
    return (response.data!['data']!['chats'] as List<dynamic>?)
        ?.map((dynamic e) => Chat.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Load Messages of a Chat
  Future<List<Message>?> loadMessagesOfAChat(
    int toUserId, [
    DateTime? startTime,
    int? pageSize,
  ]) async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/messages',
      queryParameters: <String, dynamic>{
        if (startTime != null) 'start_time': startTime.toIso8601String(),
        if (pageSize != null) 'page_size': pageSize,
        'to_user_id': toUserId,
      },
    );
    return (response.data!['data']!['messages'] as List<dynamic>?)
        ?.map((dynamic e) => Message.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Send a Message
  Future<Message> sendAMessage(
    int toUserId,
    String content,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.post(
      '$_baseUrl/messages',
      data: <String, dynamic>{
        'to_user_id': toUserId,
        'content': content,
      },
    );
    return Message.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  /* Square 广场 */

  /* Division 分区 */

  // Load Divisions
  Future<List<Division>?> loadDivisions() async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/divisions',
    );
    return (response.data!['data']!['divisions'] as List<dynamic>?)
        ?.map((dynamic e) => Division.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Load a Division
  Future<Division> loadADivision(
    int id,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/division/$id',
    );
    return Division.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  // Create a Division, admin only
  Future<Division> createADivision(
    String name,
    String description,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.post(
      '$_baseUrl/division',
      data: <String, dynamic>{
        'name': name,
        'description': description,
      },
    );
    return Division.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  // Update a Division, admin only
  Future<Division> updateADivision(
    int id,
    String name,
    String description,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.put(
      '$_baseUrl/division/$id',
      data: <String, dynamic>{
        'name': name,
        'description': description,
      },
    );
    return Division.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  // Delete a Division, admin only
  Future<void> deleteADivision(
    int id,
  ) async {
    await _dio.delete(
      '$_baseUrl/division/$id',
    );
  }

  /* Topic 主题帖 */
  // List Topics
  Future<List<Topic>?> loadTopics({
    required int pageSize,
    DateTime? startTime,
    int? divisionId,
    String orderBy = 'created_at',
    String commentOrderBy = 'id',
  }) async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/topics',
      queryParameters: <String, dynamic>{
        if (startTime != null) 'start_time': startTime.toIso8601String(),
        if (divisionId != null) 'division_id': divisionId,
        'order_by': orderBy,
        'comment_order_by': commentOrderBy,
        'page_size': pageSize,
      },
    );
    return (response.data!['data']!['topics'] as List<dynamic>?)
        ?.map((dynamic e) => Topic.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Create a Topic
  Future<Topic> createATopic({
    required String title,
    required String content,
    required int divisionId,
    bool isAnonymous = false,
    required List<Tag>? tags,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio.post(
      '$_baseUrl/topic',
      data: <String, dynamic>{
        'title': title,
        'content': content,
        'division_id': divisionId,
        'is_anonymous': isAnonymous,
        if (tags != null && tags.isNotEmpty) 'tags': tags,
      },
    );
    return Topic.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  // Load a Topic
  Future<Topic> loadATopic(
    int id,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/topic/$id',
    );
    return Topic.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  // Update a Topic
  Future<Topic> updateATopic(
    int id,
    String title,
    String content,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.put(
      '$_baseUrl/topic/$id',
      data: <String, dynamic>{
        'title': title,
        'content': content,
      },
    );
    return Topic.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  // Delete a Topic admin only
  Future<void> deleteATopic(
    int id,
  ) async {
    await _dio.delete(
      '$_baseUrl/topic/$id',
    );
  }

  // Favor a Topic
  Future<Topic> favorATopic(
    int id,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.put(
      '$_baseUrl/topic/$id/_favor',
    );
    return Topic.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  // Unfavor a Topic
  Future<Topic> unfavorATopic(
    int id,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.delete(
      '$_baseUrl/topic/$id/_favor',
    );
    return Topic.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  // Like a Topic
  Future<Topic> likeATopic(
    int id,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.put(
      '$_baseUrl/topic/$id/_like/1',
    );
    return Topic.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  // Unlike or Undislike a Topic
  Future<Topic> unlikeATopic(
    int id,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.put(
      '$_baseUrl/topic/$id/_like/0',
    );
    return Topic.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  // Dislike a Topic
  Future<Topic> dislikeATopic(
    int id,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.put(
      '$_baseUrl/topic/$id/_like/-1',
    );
    return Topic.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  // View a Topic
  Future<void> viewATopic(
    int id,
  ) async {
    await _dio.put(
      '$_baseUrl/topic/$id/_view',
    );
  }

  // Search Topics
  Future<List<Topic>?> searchTopics({
    required String search,
    required int pageNum,
    required int pageSize,
    String commentOrderBy = 'id',
    int? version, // 分页版本号
  }) async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/topics/_search',
      queryParameters: <String, dynamic>{
        'search': search,
        'page_num': pageNum,
        'page_size': pageSize,
        'comment_order_by': commentOrderBy,
        if (version != null) 'version': version,
      },
    );
    return (response.data!['data']!['topics'] as List<dynamic>?)
        ?.map((dynamic e) => Topic.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // List Favored Topics
  Future<List<Topic>?> loadFavoredTopics({
    required int pageSize,
    int? divisionId,
    String orderBy = 'created_at', // one of [created_at, updated_at]
    DateTime? startTime,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/topics/_favor',
      queryParameters: <String, dynamic>{
        'page_size': pageSize,
        if (divisionId != null) 'division_id': divisionId,
        'order_by': orderBy,
        if (startTime != null) 'start_time': startTime.toIso8601String(),
      },
    );
    return (response.data!['data']!['topics'] as List<dynamic>?)
        ?.map((dynamic e) => Topic.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // List Topics by Tags
  Future<List<Topic>?> loadTopicsByTag({
    required int pageSize,
    required int tagId,
    String orderBy = 'created_at', // one of [created_at, updated_at]
    DateTime? startTime,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/topics/_tag/$tagId',
      queryParameters: <String, dynamic>{
        'page_size': pageSize,
        'order_by': orderBy,
        if (startTime != null) 'start_time': startTime.toIso8601String(),
      },
    );
    return (response.data!['data']!['topics'] as List<dynamic>?)
        ?.map((dynamic e) => Topic.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // List Topics by userId
  Future<List<Topic>?> loadTopicsByUserId({
    required int pageSize,
    required int userId,
    String orderBy = 'created_at', // one of [created_at, updated_at]
    DateTime? startTime,
    int? divisionId,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/topics/_user/$userId',
      queryParameters: <String, dynamic>{
        'page_size': pageSize,
        'order_by': orderBy,
        if (startTime != null) 'start_time': startTime.toIso8601String(),
        if (divisionId != null) 'division_id': divisionId,
      },
    );
    return (response.data!['data']!['topics'] as List<dynamic>?)
        ?.map((dynamic e) => Topic.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /* Comment 评论 */
  // List Comments
  Future<List<Comment>?> loadComments({
    required int pageNum,
    required int pageSize,
    required int topicId,
    String orderBy = 'id', // one of [id, like]
    int? version, // 分页版本号
  }) async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/comments',
      queryParameters: <String, dynamic>{
        'page_num': pageNum,
        'page_size': pageSize,
        'topic_id': topicId,
        'order_by': orderBy,
        if (version != null) 'version': version,
      },
    );
    return (response.data!['data']!['comments'] as List<dynamic>?)
        ?.map((dynamic e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Create a Comment
  Future<Comment> createAComment({
    required String content,
    required int topicId,
    int? replyToId,
    bool isAnonymous = false,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio.post(
      '$_baseUrl/comment',
      data: <String, dynamic>{
        'content': content,
        'topic_id': topicId,
        'is_anonymous': isAnonymous,
        if (replyToId != null) 'reply_to_id': replyToId,
      },
    );
    return Comment.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  // Delete a Comment
  Future<void> deleteAComment(
    int id,
  ) async {
    await _dio.delete(
      '$_baseUrl/comment/$id',
    );
  }

  // Like a Comment
  Future<Comment> likeAComment(
    int id,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.put(
      '$_baseUrl/comment/$id/_like/1',
    );
    return Comment.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  // Dislike a Comment
  Future<Comment> dislikeAComment(
    int id,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.put(
      '$_baseUrl/comment/$id/_like/-1',
    );
    return Comment.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  // Unlike or Undislike a Comment
  Future<Comment> unlikeAComment(
    int id,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio.put(
      '$_baseUrl/comment/$id/_like/0',
    );
    return Comment.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  // Search comments
  Future<List<Comment>?> searchComments({
    required String search,
    required int pageNum,
    required int pageSize,
    int? version, // 分页版本号
  }) async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/comments/_search',
      queryParameters: <String, dynamic>{
        'search': search,
        'page_num': pageNum,
        'page_size': pageSize,
        if (version != null) 'version': version,
      },
    );
    return (response.data!['data']!['comments'] as List<dynamic>?)
        ?.map((dynamic e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // List Comment by UserId
  Future<List<Comment>?> loadCommentsByUserId({
    required int pageNum,
    required int pageSize,
    required int userId,
    String orderBy = 'id', // one of [id, like]
  }) async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/comments/_user/$userId',
      queryParameters: <String, dynamic>{
        'page_num': pageNum,
        'page_size': pageSize,
        'order_by': orderBy,
      },
    );
    return (response.data!['data']!['comments'] as List<dynamic>?)
        ?.map((dynamic e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /* Tag 标签 */
  // List Tags
  Future<List<Tag>?> loadTags({
    required int pageNum,
    required int pageSize,
    String orderBy = 'temperature', // one of [id, temperature]
    String? search,
    int? version, // 分页版本号
  }) async {
    final Response<Map<String, dynamic>> response = await _dio.get(
      '$_baseUrl/tags',
      queryParameters: <String, dynamic>{
        'page_num': pageNum,
        'page_size': pageSize,
        'order_by': orderBy,
        if (version != null) 'version': version,
        if (search != null) 'search': search,
      },
    );
    return (response.data!['data']!['tags'] as List<dynamic>?)
        ?.map((dynamic e) => Tag.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Create a tag
  Future<Tag> createATag({
    required String name,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio.post(
      '$_baseUrl/tag',
      data: <String, dynamic>{
        'name': name,
      },
    );
    return Tag.fromJson(response.data!['data'] as Map<String, dynamic>);
  }
}
