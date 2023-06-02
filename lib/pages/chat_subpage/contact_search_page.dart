import 'package:chatdan_frontend/pages/account_subpage/mine_page.dart';
import 'package:flutter/material.dart';

class SearchPage extends SearchDelegate<String> {
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
    List<String> nameList = [
      'Tom',
    ];
    for (int i = 0; i < nameList.length; i++) {
      if (query == nameList[i]) {
        flag = true;
        break;
      } else {
        flag = false;
      }
    }

    return flag == true
        ? Padding(
            padding: EdgeInsets.all(16),
            child: InkWell(
              child: Text(query),
              onTap: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => MinePage(),
                  ),
                );
              },
            ))
        : Center(
            child: Text(
              '没有此选项！',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18,
              ),
            ),
          );
  }

  //设置推荐
  @override
  Widget buildSuggestions(BuildContext context) {
    return Text('历史搜索记录');
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return super.appBarTheme(context);
  }
}
