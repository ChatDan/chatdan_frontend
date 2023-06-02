import 'package:chatdan_frontend/model/topic.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:chatdan_frontend/widgets/topic.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../model/tag.dart';

class ListTopicsWidget extends StatefulWidget {
  final bool isFavorite;
  final bool isMe;
  final int? divisionId;
  final Tag? tag;
  final bool isPage;
  final bool isSearch;
  final String search;

  const ListTopicsWidget({
    super.key,
    this.isFavorite = false,
    this.isMe = false,
    this.divisionId,
    this.tag,
    this.isPage = false,
    this.isSearch = false,
    this.search = '',
  });

  @override
  State<ListTopicsWidget> createState() => _ListTopicsWidgetState();
}

class _ListTopicsWidgetState extends State<ListTopicsWidget> {
  static const _pageSize = 10;
  static const _pageNum = 1;

  final PagingController<DateTime?, Topic> _pagingController =
      PagingController(firstPageKey: null);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) => _fetchPage(pageKey));
    super.initState();
  }

  Future<void> _fetchPage(DateTime? pageKey) async {
    try {
      List<Topic>? newTopics;
      if (widget.tag != null) {
        newTopics = await ChatDanRepository().loadTopicsByTag(
          pageSize: _pageSize,
          startTime: pageKey,
          tagId: widget.tag!.id,
        );
      } else if (widget.isFavorite) {
        newTopics = await ChatDanRepository().loadFavoredTopics(
          pageSize: _pageSize,
          startTime: pageKey,
          divisionId: widget.divisionId,
        );
      } else if (widget.isMe) {
        newTopics = await ChatDanRepository().loadTopicsByUserId(
          pageSize: _pageSize,
          userId: ChatDanRepository().provider.userInfo!.id,
          startTime: pageKey,
          divisionId: widget.divisionId,
        );
      } else if (widget.isSearch) {
        newTopics = await ChatDanRepository().searchTopics(
          pageSize: _pageSize,
          pageNum: _pageNum,
          search: widget.search,
        );
      } else {
        newTopics = await ChatDanRepository().loadTopics(
          pageSize: _pageSize,
          startTime: pageKey,
          divisionId: widget.divisionId,
        );
      }
      newTopics ??= [];

      final isLastPage = newTopics.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newTopics);
      } else {
        _pagingController.appendPage(newTopics, newTopics.last.createdAt);
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  Widget _buildListView(BuildContext context) => RefreshIndicator(
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: PagedListView(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<Topic>(
              itemBuilder: (context, item, index) => TopicWidget(topic: item),
              noItemsFoundIndicatorBuilder: (context) =>
                  const Center(child: Text('暂无数据')),
              noMoreItemsIndicatorBuilder: (context) =>
                  const Center(child: Text('没有更多了')),
            )),
      );

  @override
  Widget build(BuildContext context) {
    String title;
    if (widget.isFavorite) {
      title = '我的发帖';
    } else if (widget.isMe) {
      title = '我的话题';
    } else {
      title = '话题列表';
    }
    if (widget.isPage) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: _buildListView(context),
      );
    } else {
      return _buildListView(context);
    }
  }
}
