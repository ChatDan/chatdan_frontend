import 'package:chatdan_frontend/model/tag.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

class CreateTopicPage extends StatefulWidget {
  const CreateTopicPage({super.key});

  @override
  State<CreateTopicPage> createState() => _CreateTopicPageState();
}

class _CreateTopicPageState extends State<CreateTopicPage> {
  late String _title, _topicContext, _tag;
  List<Tag>? _tags;
  final _titleController = TextEditingController();
  final _topicContextController = TextEditingController();
  final _tagController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  String _divisionId = '1';

  // String host = HostModel.ipHost;
  final String _responseBody = '';
  bool _is_anonymous = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildTopBar(),
      body: Form(
          // FIXME: how does key work
          // key: _fromkey,
          child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        children: [
          // 发帖界面设计：title，content，tag，分区
          buildTitle(),
          buildDivision(),
          buildAnonySwitch(),
          buildTopic(),
          buildTags(),
          // buildTopicImgField()
        ],
      )),
    );
  }

  // // 获取表单数据
  // Map<String, dynamic> getTopicData() {
  //   final topic = {
  //     'Belong': "非凡哥吧",
  //     'title': _titleController.text,
  //     'topic_context': _topicContextController.text,
  //     'ImgUrl': "adadsasd",
  //   };
  //   return topic;
  // }

  // 上传文章
  Future<void> _uploadTopic() async {
    try {
      SmartDialog.showLoading(msg: '发送中...');
      _getTags();
      final title = _titleController.text;
      final content = _topicContextController.text;
      await ChatDanRepository().createATopic(
        title: title,
        content: content,
        divisionId: int.parse(_divisionId),
        tags: _tags,
        isAnonymous: _is_anonymous,
      );
      if (mounted) {
        SmartDialog.showToast('发送成功', displayTime: const Duration(seconds: 3));
        Navigator.pop(context);
      }
    } catch (e) {
      // do nothing, toast in dio interceptor
    } finally {
      SmartDialog.dismiss(status: SmartStatus.loading);
    }
  }

  // 顶部导航栏
  // Widget buildTopBar() {
  //   return Container(
  //     margin: EdgeInsets.all(10),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         IconButton(
  //             onPressed: () {
  //               GoRouter.of(context).pop();
  //             },
  //             icon: Icon(Icons.arrow_back_ios_new)),
  //         Text("发布帖子"),
  //         IconButton(
  //             onPressed: () {
  //               if (_fromkey.currentState!.validate()) {
  //                 _uploadTopic();
  //               }
  //             },
  //             icon: Icon(Icons.send_outlined))
  //       ],
  //     ),
  //   );
  // }

  PreferredSizeWidget buildTopBar() {
    return AppBar(
      key: _formkey,
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 35,
      title: Center(
        child: Text(
          '发布帖子',
          style: TextStyle(height: 8),
        ),
      ),
      leading: IconButton(
          onPressed: () {
            GoRouter.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios_new)),
      actions: <Widget>[
        IconButton(
            onPressed: () {
              // if (_formkey.currentState!.validate()) {
              _uploadTopic();
              // }
            },
            icon: Icon(Icons.send_outlined))
      ],
    );
  }

  // 标题输入
  Widget buildTitle() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(labelText: '这里输入标题'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '标题不能为空';
        }
        return null;
      },
      onSaved: (v) => _title = v!,
    );
  }

  // 内容输入
  // TODO: 处理内容超长的bug
  Widget buildTopic() {
    return TextFormField(
      controller: _topicContextController,
      maxLines: 10,
      // decoration: const InputDecoration(labelText: '内容'),
      decoration: const InputDecoration.collapsed(hintText: '', border: OutlineInputBorder()),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '内容不能为空';
        }
        return null;
      },
      onSaved: (v) => _topicContext = v!,
    );
  }

  // Tag输入，用户自己决定
  Widget buildTags() {
    return TextFormField(
      controller: _tagController,
      decoration: const InputDecoration(labelText: '输入tag(不超过五个)，不同tag用英文分号\';\'隔开'),
      // validator: (value) {
      //   if (value == null || value.isEmpty) {
      //     return '标题不能为空';
      //   }
      //   return null;
      // },
      onSaved: (v) => _tag = v!,
    );
  }

  // 分区选择
  Widget buildDivision() {
    return DropdownButton(
      items: <DropdownMenuItem<String>>[
        DropdownMenuItem(
          child: Text(
            '分区1',
            style: TextStyle(color: _divisionId == '1' ? Colors.blue : Colors.grey),
          ),
          value: '1',
        ),
        DropdownMenuItem(
          child: Text(
            '分区2',
            style: TextStyle(color: _divisionId == '2' ? Colors.blue : Colors.grey),
          ),
          value: '2',
        ),
        DropdownMenuItem(
          child: Text(
            '分区3',
            style: TextStyle(color: _divisionId == '3' ? Colors.blue : Colors.grey),
          ),
          value: '3',
        ),
        DropdownMenuItem(
          child: Text(
            '分区4',
            style: TextStyle(color: _divisionId == '4' ? Colors.blue : Colors.grey),
          ),
          value: '4',
        ),
      ],
      onChanged: (selectValue) {
        setState(() {
          _divisionId = (selectValue) as String;
        });
      },
      value: '1',
      style: new TextStyle(
          //设置文本框里面文字的样式
          color: Colors.blue,
          fontSize: 15),
      iconSize: 30, //设置三角标icon的大小
    );
  }

  Widget buildAnonySwitch() {
    return SwitchListTile(
        title: Text('匿名'),
        value: _is_anonymous,
        onChanged: (value) {
          setState(() {
            _is_anonymous = value;
          });
        });
  }

  // // 上传图片列表
  // Widget buildTopicImgField() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [buildUploadImg(), buildUploadImg(), buildUploadImg()],
  //   );
  // }

//   // 上传组件
//   Widget buildUploadImg() {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(4),
//       child: Container(
//         margin: EdgeInsets.fromLTRB(5, 30, 5, 0),
//         width: 100,
//         height: 100,
//         color: Color.fromARGB(30, 0, 0, 0),
//         child: Center(
//           child: IconButton(onPressed: () {}, icon: Icon(Icons.add)),
//         ),
//       ),
//     );
//   }
  void _getTags() {
    final _raw_tags = _tagController.text;
    _tags = [];
    List<String> tag_names = _raw_tags.split(';');
    for (String tag_name in tag_names) {
      // print(tag_name);
      if (tag_name != '') {
        _tags!.add(Tag(name: tag_name));
      }
    }
  }
}
