import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:flutter/material.dart';
import 'package:chatdan_frontend/model/post.dart';
import 'package:chatdan_frontend/model/channel.dart';

class QuestionAnswerDetailPage extends StatefulWidget {
  final Post post;

  QuestionAnswerDetailPage(this.post);

  @override
  _QuestionAnswerDetailPageState createState() =>
      _QuestionAnswerDetailPageState();
}

class _QuestionAnswerDetailPageState extends State<QuestionAnswerDetailPage> {
  List<Channel> channels = [];

  @override
  void initState() {
    super.initState();
    channels = widget.post.channels ?? [];
  }

  void _addChannel(Channel channel) {
    setState(() {
      channels.add(channel);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('问答详情'),
      ),
      body: Column(
        children: [
          // 提问和回答块
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('提问'),
                  subtitle: Text(widget.post.content),
                ),
                Divider(),
                ListTile(
                  title: const Text('回答'),
                  subtitle: Text(widget.post.channels?.first.content ?? ''),
                ),
              ],
            ),
          ),
          // 追问追答列表
          Expanded(
            child: ListView.builder(
              itemCount: channels.length,
              itemBuilder: (context, index) {
                final channel = channels[index];
                return ListTile(
                  title: const Text('追问'),
                  subtitle: Text(channel.content),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 判断当前用户是提问者还是回答者
          final bool isQuestioner = widget.post.posterId == ChatDanRepository().provider.userInfo!.id; // 替换为实际的判断逻辑
          // final bool isQuestioner = true; // 替换为实际的判断逻辑
          if (isQuestioner) {
            // 提问者追加提问
            _navigateToQuestionPage();
          } else {
            // 回答者追加回答
            _navigateToAnswerPage();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _navigateToQuestionPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuestionPage()),
    ).then((newChannelContent) {
      if (newChannelContent != null) {
        final newChannel = Channel(
          id: channels.length + 1, // 替换为实际的生成新 channel id 的逻辑
          postId: widget.post.id,
          content: newChannelContent,
          isOwner: false, // 替换为实际的判断逻辑
        );
        _addChannel(newChannel);
      }
    });
  }

  void _navigateToAnswerPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AnswerPage()),
    ).then((newChannelContent) {
      if (newChannelContent != null) {
        final newChannel = Channel(
          id: channels.length + 1, // 替换为实际的生成新 channel id 的逻辑
          postId: widget.post.id,
          content: newChannelContent,
          isOwner: true, // 替换为实际的判断逻辑
        );
        _addChannel(newChannel);
      }
    });
  }
}

class QuestionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('追加提问'),
      ),
      body: Center(
        child: Text('追加提问页面'),
      ),
    );
  }
}

class AnswerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('追加回答'),
      ),
      body: Center(
        child: Text('追加回答页面'),
      ),
    );
  }
}
