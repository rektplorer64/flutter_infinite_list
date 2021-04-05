import 'package:equatable/equatable.dart';

import '../post.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object> get props {
    return [];
  }

}

class PostInitial extends PostState {}

class PostFailure extends PostState {}

class PostSuccess extends PostState {

  final List<Post> posts;
  final bool hasReachedMax;

  PostSuccess({this.posts, this.hasReachedMax});

  PostSuccess copyWith({List<Post> posts, bool hasReachedMax}) {
    return PostSuccess(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax
    );
  }

  @override
  List<Object> get props {
    return [posts, hasReachedMax];
  }

  @override
  String toString() {
    return 'PostSuccess { posts: ${posts.length}, hasReachedMax: $hasReachedMax }';
  }
}