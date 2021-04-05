import 'package:equatable/equatable.dart';

abstract class PostEvent extends Equatable {

  @override
  List<Object> get props {
    return [];
  }

}

class PostFetched extends PostEvent {}

