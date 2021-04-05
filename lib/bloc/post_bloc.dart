import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_infinite_list/bloc/post_event.dart';
import 'package:flutter_infinite_list/bloc/post_state.dart';

import '../post.dart';
import 'package:http/http.dart' as http;

class PostBloc extends Bloc<PostEvent, PostState> {
  final http.Client httpClient;

  PostBloc({@required this.httpClient}) : super(PostInitial());

  @override
  Stream<PostState> mapEventToState(PostEvent event) async* {
    final currentState = state;

    if (event is PostFetched && !_hasReachedMax(currentState)) {
      try {
        // If this is the initial state
        if (currentState is PostInitial) {
          // Fetch the first ones
          final posts = await _fetchPosts(0, 20);

          // Yields the first ones
          yield PostSuccess(posts: posts, hasReachedMax: false);
          return;
        }

        if (currentState is PostSuccess) {
          final posts = await _fetchPosts(currentState.posts.length, 20);

          // If there is no posts? => notify that we have reached the max.
          //                  else => concat the posts
          yield posts.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : PostSuccess(
                  posts: currentState.posts + posts, hasReachedMax: false);
        }
      } catch (_) {
        yield PostFailure();
      }
    }
  }

  bool _hasReachedMax(PostState state) =>
      state is PostSuccess && state.hasReachedMax;

  Future<List<Post>> _fetchPosts(int startIndex, int limit) async {
    final response = await httpClient.get(
        "https://jsonplaceholder.typicode.com/posts?_start=$startIndex&_limit=$limit");
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((rawPost) {
        return Post(
          id: rawPost['id'],
          title: rawPost['title'],
          body: rawPost['body'],
        );
      }).toList();
    } else {
      throw Exception('error fetching posts');
    }
  }

  @override
  Stream<Transition<PostEvent, PostState>> transformEvents(
      Stream<PostEvent> events,
      TransitionFunction<PostEvent, PostState> transitionFn) {
    return super.transformEvents(
        events.debounceTime(Duration(milliseconds: 400)), transitionFn);
  }
}

class SimpleBlocObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    print(transition);
    super.onTransition(bloc, transition);
  }
}
