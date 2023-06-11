import 'package:chatdan_frontend/model/comment.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:chatdan_frontend/widgets/comment.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ListCommentPage extends StatefulWidget {
  final int? userId;
  final int? topicId;

  const ListCommentPage({
    this.userId,
    this.topicId,
    super.key,
  });

  @override
  State createState() => _ListCommentPageState();
}

class _ListCommentPageState extends State<ListCommentPage> {
  static const _pageSize = 10;

  final PagingController<int, Comment> _pagingController = PagingController(firstPageKey: 1);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) => _fetchPage(pageKey));
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      List<Comment>? newComments;
      if (widget.userId != null) {
        newComments = await ChatDanRepository().loadCommentsByUserId(
          pageSize: _pageSize,
          userId: widget.userId!,
          pageNum: 1,
        );
      }
      newComments ??= [];

      final isLastPage = newComments.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newComments);
      } else {
        _pagingController.appendPage(newComments, pageKey + 1);
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的评论'),
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(
          () => _pagingController.refresh(),
        ),
        child: PagedListView<int, Comment>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<Comment>(
            itemBuilder: (context, comment, index) => CommentWidget(
              comment: comment,
              deleteFunc: () => {
                setState(() {
                  _pagingController.itemList!.removeAt(index);
                })
              },
            ),
            noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('暂无数据')),
            noMoreItemsIndicatorBuilder: (context) => const Center(child: Text('没有更多了')),
            firstPageErrorIndicatorBuilder: (context) => const Center(child: Text('加载失败')),
            newPageErrorIndicatorBuilder: (context) => const Center(child: Text('加载失败')),
          ),
        ),
      ),
    );
  }
}
