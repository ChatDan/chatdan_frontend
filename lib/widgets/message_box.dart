import 'package:flutter/material.dart';

class MessageBoxListWidget extends StatefulWidget {
  const MessageBoxListWidget({Key? key}) : super(key: key);

  @override
  State<MessageBoxListWidget> createState() => _MessageBoxListWidgetState();
}

class _MessageBoxListWidgetState extends State<MessageBoxListWidget> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('MessageBoxList'),
    );
  }
}