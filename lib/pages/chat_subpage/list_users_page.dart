import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:chatdan_frontend/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../model/user.dart';

class ListUsersWidget extends StatefulWidget {
  final bool isPage;
  final bool isSearch;
  final String search;

  const ListUsersWidget({
    super.key,
    this.isPage = false,
    this.isSearch = false,
    this.search = '',
  });

  @override
  State<ListUsersWidget> createState() => _ListUsersWidgetState();
}

class _ListUsersWidgetState extends State<ListUsersWidget> {
  static const _pageSize = 10;
  static const _pageNum = 1;

  final PagingController<int, User> _pagingController = PagingController(firstPageKey: _pageNum);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) => _fetchPage(pageKey));
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      List<User>? newUsers;
      if (widget.isSearch) {
        newUsers = await ChatDanRepository().searchUsers(
          pageNum: 1,
          pageSize: _pageSize,
          search: widget.search,
        );
      }
      newUsers ??= [];

      final isLastPage = newUsers.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newUsers);
      } else {
        _pagingController.appendPage(newUsers, pageKey + 1);
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  Widget _buildListView(BuildContext context) => RefreshIndicator(
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: PagedListView(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<User>(
              itemBuilder: (context, item, index) => UserWidget(item),
              noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('暂无数据')),
              noMoreItemsIndicatorBuilder: (context) => const Center(child: Text('没有更多了')),
              firstPageErrorIndicatorBuilder: (context) => const Center(child: Text('加载失败')),
              newPageErrorIndicatorBuilder: (context) => const Center(child: Text('加载失败')),
            )),
      );

  @override
  Widget build(BuildContext context) {
    return _buildListView(context);
  }
}
