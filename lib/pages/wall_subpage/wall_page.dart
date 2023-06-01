import 'package:chatdan_frontend/bottom_bar.dart';
import 'package:chatdan_frontend/model/wall.dart';
import 'package:chatdan_frontend/pages/account_subpage/profile.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

import 'create_wall_page.dart';

class WallPage extends StatefulWidget {
  final bool isPage;

  const WallPage({this.isPage = true, Key? key}) : super(key: key);

  @override
  State<WallPage> createState() => _WallPageState();
}

class _WallPageState extends State<WallPage> {
  static const _pageSize = 10;

  final PagingController<int, Wall> _pagingController = PagingController(firstPageKey: 1);
  DateTime? _chosenDate;

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) => _fetchPage(pageKey));
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      List<Wall>? newWalls = await ChatDanRepository().loadWalls(
            date: _chosenDate,
            pageSize: _pageSize,
            pageNum: pageKey,
          ) ??
          [];

      final isLastPage = newWalls.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newWalls);
      } else {
        _pagingController.appendPage(newWalls, pageKey + 1);
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  Widget _buildListView(BuildContext context) => RefreshIndicator(
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: PagedListView(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<Wall>(
              itemBuilder: (context, item, index) => WallWidget(item),
              noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('暂无数据')),
              noMoreItemsIndicatorBuilder: (context) => const Center(child: Text('没有更多了')),
            )),
      );

  @override
  Widget build(BuildContext context) {
    String title;
    if (_chosenDate == null) {
      title = '今日表白墙';
    } else {
      title = '${_chosenDate!.year}年${_chosenDate!.month}月${_chosenDate!.day}日表白墙';
    }
    if (widget.isPage) {
      return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final DateTime? chosenDate = await showDatePicker(
                    context: context,
                    initialDate: _chosenDate ?? DateTime.now(),
                    firstDate: DateTime(2021),
                    lastDate: DateTime.now(),
                  );
                  if (chosenDate != null) {
                    setState(() {
                      _chosenDate = chosenDate.toLocal();
                      _pagingController.refresh();
                    });
                  }
                },
              ),
            ],
          ),
          body: _buildListView(context),
          bottomNavigationBar: BottomBar(index: 1),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateWallPage())).then((value) {
                _pagingController.refresh();
              });
            },
            child: const Icon(Icons.add),
          ));
    } else {
      return _buildListView(context);
    }
  }
}

class WallWidget extends StatelessWidget {
  final Wall wall;

  const WallWidget(this.wall, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final username = wall.isAnonymous ? '匿名用户' : wall.poster!.username;
    final avatar = wall.isAnonymous
        ? const CircleAvatar(child: Icon(Icons.person))
        : (wall.poster!.avatar == null
            ? CircleAvatar(child: Text(wall.poster!.username.substring(0, 1)))
            : CircleAvatar(backgroundImage: NetworkImage(wall.poster!.avatar!)));

    Widget header = ListTile(
      leading: avatar,
      title: Text(
        username,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: Text(DateFormat.jm().format(wall.createdAt.toLocal())),
      horizontalTitleGap: 16,
      minVerticalPadding: 8,
    );

    if (!wall.isAnonymous) {
      header = GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(user: wall.poster!)));
        },
        child: header,
      );
    }
    return Card(
      child: Column(
        children: [
          header,
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            alignment: Alignment.centerLeft,
            child: Text(wall.content),
          ),
        ],
      ),
    );
  }
}
