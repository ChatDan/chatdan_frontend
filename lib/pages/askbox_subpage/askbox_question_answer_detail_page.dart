import 'package:flutter/material.dart';
import 'package:chatdan_frontend/model/post.dart';
import 'package:chatdan_frontend/model/channel.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';

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

  void _deleteQuestion() {
    ChatDanRepository().deleteAPost(widget.post.id).then((_) {
      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    bool hasAnswer = widget.post.channels?.isNotEmpty ?? false;
    String answerContent = widget.post.channels?.first.content ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('问答详情'),
        actions: [
          if (widget.post.isOwner)
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
            child: ListTile(
              title: const Text('提问'),
              subtitle: Text(widget.post.content),
            ),
          ),
          if (hasAnswer && answerContent.isNotEmpty) ...[
            Divider(),
            // 回答块
            Card(
              child: ListTile(
                title: const Text('回答'),
                subtitle: Text(answerContent),
              ),
            ),
          ],
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
          final bool isQuestioner =
              widget.post.posterId == ChatDanRepository().provider.userInfo!.id;
          if (isQuestioner) {
            // 提问者追加提问
            _navigateToQuestionPage();
          } else if (widget.post.isOwner) {
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
          isOwner:
              widget.post.posterId == ChatDanRepository().provider.userInfo!.id,
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
          isOwner:
              widget.post.posterId == ChatDanRepository().provider.userInfo!.id,
        );
        _addChannel(newChannel);
      }
    });
  }
}

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
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: '输入追加的问题',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String newChannelContent = _textEditingController.text;
                Navigator.pop(context, newChannelContent);
              },
              child: Text('发送'),
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
        title: Text('追加回答'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: '输入追加的回答',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String newChannelContent = _textEditingController.text;
                Navigator.pop(context, newChannelContent);
              },
              child: Text('发送'),
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
