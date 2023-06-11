import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:chatdan_frontend/model/post.dart';
import 'package:chatdan_frontend/model/channel.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

import 'package:chatdan_frontend/utils/errors.dart';

class QuestionAnswerDetailPage extends StatefulWidget {
  final Post post;
  final int ownerId;

  QuestionAnswerDetailPage(this.post, this.ownerId);

  @override
  _QuestionAnswerDetailPageState createState() =>
      _QuestionAnswerDetailPageState();
}

class _QuestionAnswerDetailPageState extends State<QuestionAnswerDetailPage> {
  List<Channel> channels = [];
  bool isLoading = false;

  Future<void> _fetchChannels() async {
    try {
      setState(() {
        isLoading = true;
      });
      final fetchedChannels =
      await ChatDanRepository().loadChannels(1, 10, widget.post.id);
      setState(() {
        channels = fetchedChannels ?? [];
      });
    } catch (e) {
      if (e is DioError && e.error is NotLoginError && mounted) {
        context.go('/login');
      } else {
        SmartDialog.showToast(e.toString(),
            displayTime: const Duration(seconds: 1));
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchChannels();
  }

  void _addChannel(Channel channel) {
    setState(() {
      channels.add(channel);
    });
  }

  void _deleteQuestion() {
    ChatDanRepository().deleteAPost(widget.post.id).then((_) {
      Navigator.pop(context);
      // Navigator.popAndPushNamed(context, '/askbox/${widget.post.messageBoxId}')
    }).catchError((error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('删除失败'),
          content: const Text('无法删除问题，请重试'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    });
  }

  void _deleteChannel(int channelId) async {
    try {
      await ChatDanRepository().deleteAChannel(channelId);
      SmartDialog.showToast('删除成功');
      setState(() {
        channels.removeWhere((channel) => channel.id == channelId);
      });
    } catch (e) {
      if (e is DioError && e.error is NotLoginError && mounted) {
        context.go('/login');
      } else {
        SmartDialog.showToast('删除失败');
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('问答详情'),
        actions: [
          if (widget.ownerId == ChatDanRepository().provider.userInfo!.id)
            IconButton(
              onPressed: _deleteQuestion,
              icon: const Icon(Icons.delete),
            ),
        ],
      ),
      body: Column(
        children: [
          // 提问块
          Card(
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.fromLTRB(10, 5, 10, 10),
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 3,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: ListTile(
                title: widget.post.poster?.username != null
                    ? Text('${widget.post.poster?.username}  提问',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold))
                    : const Text('匿名用户  提问',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                subtitle: Text(widget.post.content),
              ),
            ),
          ),

          // 追问追答列表
          Expanded(
            child: ListView.builder(
              itemCount: channels.length,
              itemBuilder: (context, index) {
                final channel = channels[index];
                final titleText = channel.isPostOwner ? '追问' : '回答';
                return ListTile(
                  title: Text(titleText),
                  subtitle: Text(channel.content),
                  trailing: widget.ownerId ==
                      ChatDanRepository().provider.userInfo!.id
                      ? IconButton(
                    onPressed: () => _deleteChannel(channel.id),
                    icon: const Icon(Icons.delete),
                  )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 判断当前用户是提问者还是回答者
          if (widget.post.posterId ==
              ChatDanRepository().provider.userInfo!.id) {
            _navigateToQuestionPage();
          } else if (widget.ownerId ==
              ChatDanRepository().provider.userInfo!.id) {
            _navigateToAnswerPage();
          } else {
            // 非提问者也非回答者，不允许追加
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('操作失败'),
                content: const Text(
                  '您不是提问者也不是回答者，无法追加提问或回答',
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('确定'),
                  ),
                ],
              ),
            );
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // 追问
  void _navigateToQuestionPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuestionPage()),
    ).then((newChannelContent) {
      if (newChannelContent != null) {
        ChatDanRepository()
            .createAChannel(widget.post.id, newChannelContent)
            .then((newChannel) {
          _addChannel(newChannel);
        }).catchError((error) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('操作失败'),
              content: const Text('无法追加提问，请重试'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('确定'),
                ),
              ],
            ),
          );
        });
      }
    });
  }
  // 回答
  void _navigateToAnswerPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AnswerPage()),
    ).then((newChannelContent) {
      if (newChannelContent != null) {
        ChatDanRepository()
            .createAChannel(widget.post.id, newChannelContent)
            .then((newChannel) {
          _addChannel(newChannel);
        }).catchError((error) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('操作失败'),
              content: const Text('无法追加回答，请重试'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('确定'),
                ),
              ],
            ),
          );
        });
      }
    });
  }
}

// additional queation page and answer page
class QuestionPage extends StatefulWidget {
  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('追加提问'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _textEditingController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: '追加问题',
                border: OutlineInputBorder(),
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return '请输入追加问题';
                }
                return null;
              },
            ),

            ElevatedButton(
              onPressed: () {
                String newChannelContent = _textEditingController.text;
                Navigator.pop(context, newChannelContent);
              },
              child: Text('提问'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}

class AnswerPage extends StatefulWidget {
  @override
  _AnswerPageState createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerPage> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('回答'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _textEditingController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: '回答',
                border: OutlineInputBorder(),
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return '请输入回答';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                String newChannelContent = _textEditingController.text;
                Navigator.pop(context, newChannelContent);
              },
              child: const Text('回答'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
