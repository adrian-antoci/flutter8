import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter8/routing.dart';
import 'package:flutter8/screens/home/widgets/post_widget.dart';
import 'package:flutter8/services/flutter8_api_impl.dart';
import 'package:flutter8/services/flutter8_storage_impl.dart';
import 'package:flutter8/services/models.dart';
import 'package:flutter8/theme/colors.dart';
import 'package:flutter8/theme/spacers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:syntax_highlight/syntax_highlight.dart';
import 'home_bloc.dart';

class HomeScreenWidget extends StatefulWidget {
  const HomeScreenWidget({
    super.key,
    required this.nextPageController,
  });

  final NextPageController nextPageController;

  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  final PageController _pageViewer = PageController();
  final HomePageBloc _bloc = HomePageBloc(Flutter8APIImpl(), Flutter8StorageImpl());
  final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 1));

  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  @override
  void initState() {
    widget.nextPageController.addListener(
      () => _pageViewer.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.linearToEaseOut),
    );
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _goToMyProfile() => context.push("/profile", extra: {
        'id': FirebaseAuth.instance.currentUser!.uid,
        'name': FirebaseAuth.instance.currentUser!.displayName,
        'avatar': FirebaseAuth.instance.currentUser!.photoURL,
      });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            elevation: 0,
            title: SvgPicture.asset('assets/logo.svg', height: 17),
            actions: [
              TextButton(
                onPressed: () {
                  try {
                    if (FirebaseAuth.instance.currentUser != null) {
                      context.push("/post").then(_handleNewPost);
                      return;
                    }
                  } catch (ex) {}
                  context.push("/login").then((_) {
                    if (isLoggedIn) {
                      context.push("/post").then(_handleNewPost);
                      _bloc.add(HomePageEventOnLogin());
                    }
                  });
                },
                child: const Row(
                  children: [
                    Icon(Icons.add),
                    Text(
                      "Post code",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  if (isLoggedIn) {
                    _goToMyProfile();
                  } else {
                    context.push("/login").then((_) {
                      if (isLoggedIn) {
                        _goToMyProfile();
                      }
                    });
                  }
                },
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    image: isLoggedIn && FirebaseAuth.instance.currentUser!.photoURL != null
                        ? DecorationImage(
                            image: NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!), fit: BoxFit.cover)
                        : null,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: isLoggedIn
                      ? null
                      : const Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                ),
              ),
              const Spacer0(),
            ],
            centerTitle: false,
          ),
          body: SafeArea(
            child: BlocConsumer<HomePageBloc, HomePageState>(
                listenWhen: (previous, current) =>
                    current is HomePageStateConfetti || current is HomePageStateSnackMessage,
                listener: (context, state) {
                  if (state is HomePageStateConfetti) {
                    _confettiController.play();
                  } else if (state is HomePageStateSnackMessage) {
                    _snackMessage(context, state.message);
                  }
                },
                bloc: _bloc,
                buildWhen: (previous, current) =>
                    current is HomePageStateDataAvailable ||
                    current is HomePageStateDataLoading ||
                    current is HomePageStateDataError,
                builder: (context, state) {
                  switch (state.runtimeType) {
                    case HomePageStateDataError:
                      return const Center(child: Text("Error, please refresh"));
                    case HomePageStateDataAvailable:
                      return PageView.builder(
                        itemCount: _bloc.posts.length,
                        pageSnapping: true,
                        onPageChanged: (value) => _bloc.add(HomePageEventSelectedPost(value)),
                        controller: _pageViewer,
                        physics: const _CustomPageViewScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, int index) {
                          var post = _bloc.posts[index];
                          return PostCardWidget(
                            post: post,
                            onCopyCode: () => _onCopyCode(context, post),
                            onProfile: _onProfile,
                          );
                        },
                      );
                    default:
                      return loadingWidget();
                  }
                }),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            emissionFrequency: 0.01,
            numberOfParticles: 20,
            maxBlastForce: 5,
            minBlastForce: 2,
            gravity: 0.1,
          ),
        ),
      ],
    );
  }

  FutureOr _handleNewPost(Object? post) {
    if (post != null) {
      _bloc.add(HomePageEventNewPost(post as Post));
    }
  }

  void _onCopyCode(BuildContext context, Post post) {
    Clipboard.setData(ClipboardData(text: post.code));
    _bloc.add(HomePageEventCopyCode(post));
  }

  void _onProfile(String id, String name, String avatar) => context.push("/profile", extra: {
        'id': id,
        'name': name,
        'avatar': avatar,
      });

  void _snackMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget loadingWidget() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    const Spacer0(),
                    const Spacer0(),
                  ],
                ),
                const Spacer0(),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(color: lightBackgroundColor),
            ),
          ),
        ],
      );
}

class _CustomPageViewScrollPhysics extends ScrollPhysics {
  const _CustomPageViewScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  _CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _CustomPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 1,
      );
}
