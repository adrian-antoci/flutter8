import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter8/services/flutter8_api_impl.dart';
import 'package:flutter8/theme/code_highlighter.dart';
import 'package:flutter8/services/models.dart';
import 'package:flutter8/theme/colors.dart';
import 'package:go_router/go_router.dart';

class PostScreenWidget extends StatefulWidget {
  const PostScreenWidget({super.key});

  @override
  State<PostScreenWidget> createState() => _PostScreenWidgetState();
}

class _PostScreenWidgetState extends State<PostScreenWidget> {
  late final _textController = _CustomTextController();

  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
  }

  void _postNow() async {
    if (_isPosting || _textController.text.trim().length < 10) return;
    _isPosting = true;
    var user = FirebaseAuth.instance.currentUser!;
    setState(() {});

    Post post = Post(
        code: _textController.text.trim(),
        copyCodeCount: 0,
        createdById: user.uid,
        createdByAvatar: user.photoURL ?? "",
        createdByName: user.displayName ?? "No name",
        createdAt: DateTime.now());

    var result = await Flutter8APIImpl().createPost(post);
    if (result.isRight && mounted) {
      context.pop(post.copyWith(id: result.right));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () => _postNow(),
              child: Row(
                children: [
                  Text(
                    _isPosting ? ". . ." : "Post now",
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  )
                ],
              ))
        ],
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: lightBackgroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: TextFormField(
                  autofocus: true,
                  controller: _textController,
                  maxLines: null,
                  decoration: const InputDecoration.collapsed(
                      hintStyle: TextStyle(color: Color(0xff5d874c)),
                      hintText: "/// Paste your code here\n/// Don't forget to format it!"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTextController extends TextEditingController {
  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    return CodeHighlighter().highlight(text);
  }
}
