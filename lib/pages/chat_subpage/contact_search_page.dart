import 'package:chatdan_frontend/pages/chat_subpage/list_users_page.dart';
import 'package:flutter/material.dart';

class ContactSearchDelegate extends SearchDelegate<String> {
  late bool flag = false;

  @override
  List<Widget> buildActions(BuildContext context) {
    Widget RIButton = IconButton(
      icon: Icon(Icons.clear),
      onPressed: () {
        query = '';
        showSuggestions(context);
      },
    );
    List<Widget> WList = [];
    WList.add(RIButton);
    return WList;
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () => close(context, 'error'));
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListUsersWidget(
      isSearch: true,
      search: query,
    );
  }

  //设置推荐
  @override
  Widget buildSuggestions(BuildContext context) {
    return Text('历史搜索记录');
  }
}
