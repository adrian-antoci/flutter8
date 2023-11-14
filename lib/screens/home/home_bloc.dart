import 'dart:async';
import 'package:flutter/services.dart';
import 'package:queue/queue.dart';
import 'package:flutter8/services/flutter8_api.dart';
import 'package:flutter8/services/flutter8_storage.dart';
import 'package:flutter8/services/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';

abstract class HomePageEvent {}

abstract class HomePageState {}

class HomePageEventDataAvailable extends HomePageEvent {}

class HomePageEventNewPost extends HomePageEvent {
  final Post post;

  HomePageEventNewPost(this.post);
}

class HomePageEventCopyCode extends HomePageEvent {
  final Post post;

  HomePageEventCopyCode(this.post);
}

class HomePageEventDataError extends HomePageEvent {}

class HomePageEventOnLogin extends HomePageEvent {}

class HomePageEventSelectedPost extends HomePageEvent {
  final int postIndex;

  HomePageEventSelectedPost(this.postIndex);
}

class HomePageStateDataLoading extends HomePageState {}

class HomePageStateDataError extends HomePageState {}

class HomePageStateDataAvailable extends HomePageState {}

class HomePageStateConfetti extends HomePageState {}

class HomePageStateSnackMessage extends HomePageState {
  final String message;

  HomePageStateSnackMessage(this.message);
}

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  HomePageBloc(Flutter8API api, Flutter8Storage storage) : super(HomePageStateDataLoading()) {
    on<HomePageEventDataAvailable>((event, emit) => emit(HomePageStateDataAvailable()));
    on<HomePageEventDataError>((event, emit) => emit(HomePageStateDataError()));
    on<HomePageEventNewPost>((event, emit) => _onNewPost(emit: emit, event: event));
    on<HomePageEventCopyCode>((event, emit) => _onCopyCode(emit: emit, event: event, api: api));
    on<HomePageEventSelectedPost>(
        (event, emit) => _queue.add(() => _onPostSelected(emit: emit, event: event, api: api, storage: storage)));
    on<HomePageEventOnLogin>((event, emit) => emit(HomePageStateSnackMessage("You are now logged in")));

    _queue.add(() => _onFirstPosts(api: api, storage: storage));
  }

  final List<Post> posts = [];
  final _queue = Queue();

  _onNewPost({required Emitter<HomePageState> emit, required HomePageEventNewPost event}) async {
    emit(HomePageStateDataLoading());
    await Future.delayed(const Duration(milliseconds: 250));

    posts.insert(0, event.post);

    emit(HomePageStateDataAvailable());
    emit(HomePageStateConfetti());
    emit(HomePageStateSnackMessage("Your post is now live!"));
  }

  _onCopyCode({
    required Emitter<HomePageState> emit,
    required HomePageEventCopyCode event,
    required Flutter8API api,
  }) async {
    Clipboard.setData(ClipboardData(text: event.post.code));
    emit(HomePageStateSnackMessage("Code copied to clipboard"));

    var results = await Future.wait([
      api.incrementCopyCount(event.post),
      api.addPostToProfile(event.post),
    ]);

    var allSuccessful = results.every((element) => element.isRight);

    if (!allSuccessful) {
      add(HomePageEventDataError());
    } else {
      event.post.copyWith(copyCodeCount: event.post.copyCodeCount + 1);
      for (var i = 0; i < posts.length; i++) {
        if (posts[i].id == event.post.id) {
          posts[i] = event.post.copyWith(copyCodeCount: event.post.copyCodeCount + 1);
        }
      }
      add(HomePageEventDataAvailable());
    }
  }

  Future<void> _onFirstPosts({required Flutter8API api, required Flutter8Storage storage}) async {
    var lastPostId = await _getLastPostId(storage: storage);
    var result = await api.listNextPosts(id: lastPostId);
    if (result.isLeft) {
      add(HomePageEventDataError());
    } else {
      if (result.right.isNotEmpty) {
        await _updateUIAndQueryMore(newPosts: result.right, api: api);
      } else {
        add(HomePageEventDataError());
        var result = await api.listNextPosts();
        if (result.isRight) {
          await _updateUIAndQueryMore(newPosts: result.right, api: api);
        }
      }
    }
  }

  Future<void> _updateUIAndQueryMore({required List<Post> newPosts, required Flutter8API api}) async {
    if (isClosed) return;
    posts.addAll(newPosts);
    add(HomePageEventDataAvailable());

    if (newPosts.length < 10) {
      var result = await api.listNextPosts();
      if (result.isRight && result.right.isNotEmpty) {
        posts.addAll(result.right);
        add(HomePageEventDataAvailable());
      }
    }
  }

  Future<String> _getLastPostId({required Flutter8Storage storage}) async {
    if (posts.isEmpty) {
      var lastPostId = await storage.getString("last_seen_post");
      return lastPostId ?? '';
    }
    return posts.last.id;
  }

  Future<void> _onPostSelected({
    required Emitter<HomePageState> emit,
    required HomePageEventSelectedPost event,
    required Flutter8API api,
    required Flutter8Storage storage,
  }) async {
    if (posts.isEmpty) return;
    var post = posts[event.postIndex];
    await storage.storeString("last_seen_post", post.id);

    if (posts.length - event.postIndex < 3) {
      var result = await api.listNextPosts(id: posts[posts.length - 1].id);
      if (result.isRight) {
        await _updateUIAndQueryMore(newPosts: result.right, api: api);
      }
    }
  }
}
