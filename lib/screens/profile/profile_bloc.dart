import 'dart:async';
import 'package:flutter/services.dart';
import 'package:queue/queue.dart';
import 'package:flutter8/services/flutter8_api.dart';
import 'package:flutter8/services/flutter8_storage.dart';
import 'package:flutter8/services/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';

abstract class ProfilePageEvent {}

abstract class ProfilePageState {}

class ProfilePageEventDataAvailable extends ProfilePageEvent {}

class ProfilePageEventLoading extends ProfilePageEvent {}

class ProfilePageEventTabSelected extends ProfilePageEvent {
  final int index;

  ProfilePageEventTabSelected(this.index);
}

class ProfilePageEventNewPost extends ProfilePageEvent {
  final Post post;

  ProfilePageEventNewPost(this.post);
}

class ProfilePageEventCopyCode extends ProfilePageEvent {
  final Post post;

  ProfilePageEventCopyCode(this.post);
}

class ProfilePageEventDataError extends ProfilePageEvent {}

class ProfilePageStateDataLoading extends ProfilePageState {}

class ProfilePageStateDataError extends ProfilePageState {}

class ProfilePageStateDataAvailable extends ProfilePageState {}

class ProfilePageStateSnackMessage extends ProfilePageState {
  final String message;

  ProfilePageStateSnackMessage(this.message);
}

class ProfilePageBloc extends Bloc<ProfilePageEvent, ProfilePageState> {
  ProfilePageBloc(String user, Flutter8API api) : super(ProfilePageStateDataLoading()) {
    on<ProfilePageEventDataAvailable>((event, emit) => emit(ProfilePageStateDataAvailable()));
    on<ProfilePageEventDataError>((event, emit) => emit(ProfilePageStateDataError()));
    on<ProfilePageEventTabSelected>(
      (event, emit) => _loadPosts(api: api, user: user, isCodeCopies: event.index == 0),
    );
    on<ProfilePageEventLoading>((event, emit) => emit(ProfilePageStateDataLoading()));
    _loadPosts(api: api, user: user, isCodeCopies: true);
  }

  List<Post> posts = [];

  Future<void> _loadPosts({required bool isCodeCopies, required Flutter8API api, required String user}) async {
    add(ProfilePageEventLoading());

    var result = isCodeCopies ? await api.listCodeCopies(user) : await api.listCreatedByUser(user);
    if (result.isRight) {
      posts = result.right;
      add(ProfilePageEventDataAvailable());
    } else {
      add(ProfilePageEventDataError());
      posts.clear();
    }
  }
}
