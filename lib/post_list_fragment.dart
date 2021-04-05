import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/post_bloc.dart';
import 'bloc/post_event.dart';
import 'bloc/post_state.dart';
import 'component/BottomLoader.dart';
import 'component/PostWidget.dart';
import 'main.dart';

class PostListFragment extends StatefulWidget {
  @override
  _PostListFragmentState createState() => _PostListFragmentState();
}

class _PostListFragmentState extends State<PostListFragment> {

  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;

  PostBloc _postBloc;


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _postBloc = BlocProvider.of<PostBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        if (state is PostInitial) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is PostFailure) {
          return Center(
            child: Text("Failed to fetch posts"),
          );
        }

        if (state is PostSuccess) {
          if (state.posts.isEmpty) {
            return Center(child: Text('No posts'),);
          }

          return ListView.builder(
            itemBuilder: (context, index) {
              return index >= state.posts.length ? BottomLoader() : PostWidget(
                  post: state.posts[index]);
            },
            itemCount: state.hasReachedMax ? state.posts.length : state.posts
                .length + 1,
            controller: _scrollController,
          );
        }
        return Center(child: Text('No posts'),);
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= _scrollThreshold) {
      _postBloc.add(PostFetched());
    }
  }
}