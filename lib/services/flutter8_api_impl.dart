import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:flutter8/services/flutter8_api.dart';

import 'models.dart';

class Flutter8APIImpl implements Flutter8API {
  @override
  Future<Either<APIError, List<Post>>> listNextPosts({String id = '', int limit = 10}) async {
    try {
      DocumentSnapshot? lastPost = id.isNotEmpty ? (await FirebaseFirestore.instance.doc('posts/$id').get()) : null;
      if (lastPost == null && id.isNotEmpty) {
        return const Right([]);
      }
      var query = FirebaseFirestore.instance.collection('posts').orderBy("createdAt").limit(limit);
      if (lastPost != null) {
        query = query.startAfterDocument(lastPost);
      }
      var posts = await query.get();
      return Right(posts.docs.map((doc) => Post.fromSnapshot(doc)).toList());
    } catch (ex) {
      print(ex);
      return Left(APIError(500));
    }
  }

  @override
  Future<Either<APIError, Post>> getPost(String id) async {
    try {
      var document = await FirebaseFirestore.instance.doc('posts/$id').get();
      if (document.exists) {
        return Right(Post.fromSnapshot(document));
      }
    } catch (ex) {
      print(ex);
    }
    return Left(APIError(500));
  }

  @override
  Future<Either<APIError, bool>> incrementCopyCount(Post post) async {
    try {
      await FirebaseFirestore.instance.doc('posts/${post.id}').update({
        "copyCodeCount": FieldValue.increment(1),
      });
      return const Right(true);
    } catch (ex) {
      print(ex);
    }
    return Left(APIError(500));
  }
}
