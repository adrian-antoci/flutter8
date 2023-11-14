import 'package:flutter/material.dart';
import 'package:flutter8/screens/profile/profile_bloc.dart';
import 'package:flutter8/services/flutter8_api_impl.dart';
import 'package:flutter8/services/models.dart';
import 'package:flutter8/theme/code_highlighter.dart';
import 'package:flutter8/theme/colors.dart';
import 'package:flutter8/theme/spacers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreenWidget extends StatefulWidget {
  const ProfileScreenWidget(this.id, this.name, this.avatar, {super.key});

  final String id;
  final String name;
  final String avatar;

  @override
  State<ProfileScreenWidget> createState() => _ProfileScreenWidgetState();
}

class _ProfileScreenWidgetState extends State<ProfileScreenWidget> {
  late final ProfilePageBloc _bloc = ProfilePageBloc(
    widget.id,
    Flutter8APIImpl(),
  );

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        centerTitle: false,
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const SizedBox(width: double.infinity),
              _avatarSection(),
              const Spacer1(),
              Text(widget.name, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w500)),
              const Spacer2(),
              TabBar(
                unselectedLabelColor: Colors.white,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: "Code copies"),
                  Tab(text: "My posts"),
                ],
                onTap: (index) => _bloc.add(ProfilePageEventTabSelected(index)),
              ),
              Expanded(
                child: TabBarView(children: [
                  _postsSection(),
                  _postsSection(),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _postsSection() => BlocBuilder(
        bloc: _bloc,
        buildWhen: (previous, current) =>
            current is ProfilePageStateDataAvailable || current is ProfilePageStateDataLoading,
        builder: (context, state) {
          if (state is ProfilePageStateDataAvailable) {
            return _PostsGridWidget(_bloc.posts);
          }
          return const SizedBox.shrink();
        },
      );

  Widget _avatarSection() => Container(
      width: 100,
      height: 100,
      decoration: widget.name.isEmpty
          ? const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)
          : BoxDecoration(
              color: Colors.orange,
              image: DecorationImage(image: NetworkImage(widget.avatar), fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(50),
            ),
      child: widget.avatar.isEmpty
          ? Center(
              child: Text(widget.name.substring(0, 1), style: const TextStyle(fontSize: 32)),
            )
          : const SizedBox.shrink());
}

class _PostsGridWidget extends StatefulWidget {
  const _PostsGridWidget(this.posts);

  final List<Post> posts;

  @override
  State<StatefulWidget> createState() => _PostsGridWidgetState();
}

class _PostsGridWidgetState extends State<_PostsGridWidget> {
  @override
  Widget build(BuildContext context) => widget.posts.isEmpty
      ? const Padding(
          padding: EdgeInsets.all(25),
          child: Text("No posts"),
        )
      : MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: widget.posts.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: lightBackgroundColor,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: Text.rich(
                    CodeHighlighter().highlight(widget.posts[index].code),
                    style: GoogleFonts.roboto(height: 1.5, fontSize: 10),
                  ),
                );
              }),
        );
}
