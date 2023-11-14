import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    } catch (ex) {}
    return Left(APIError(500));
  }

  @override
  Future<Either<APIError, bool>> incrementCopyCount(Post post) async {
    try {
      await FirebaseFirestore.instance.doc('posts/${post.id}').update({
        "copyCodeCount": FieldValue.increment(1),
      });
      return const Right(true);
    } catch (ex) {}
    return Left(APIError(500));
  }

  @override
  Future<Either<APIError, bool>> addPostToProfile(Post post) async {
    if (FirebaseAuth.instance.currentUser == null) {
      return const Right(true);
    }
    try {
      final CollectionReference posts = FirebaseFirestore.instance.collection('copies');
      await posts.add({
        'user': FirebaseAuth.instance.currentUser!.uid,
        'post': post.id,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
      return const Right(true);
    } catch (ex) {
      return Left(APIError(500));
    }
  }

  @override
  Future<Either<APIError, String>> createPost(Post post) async {
    try {
      final CollectionReference posts = FirebaseFirestore.instance.collection('posts');
      var result = await posts.add(post.toJSON());
      return Right(result.id);
    } catch (ex) {
      return Left(APIError(500));
    }
  }

  @override
  Future<Either<APIError, List<Post>>> listCodeCopies(String user) async {
    try {
      var query = FirebaseFirestore.instance
          .collection('copies')
          .where('user', isEqualTo: user)
          .orderBy("createdAt")
          .limit(500);
      var copies = await query.get();
      List<String> ids = copies.docs.map((e) => e.data()['post'].toString()).toList();
      if (ids.isEmpty) return const Right([]);

      var posts = await FirebaseFirestore.instance.collection('posts').where(FieldPath.documentId, whereIn: ids).get();
      return Right(posts.docs.map((doc) => Post.fromSnapshot(doc)).toList());
    } catch (ex) {
      return Left(APIError(500));
    }
  }

  @override
  Future<Either<APIError, List<Post>>> listCreatedByUser(String user) async {
    try {
      var query = FirebaseFirestore.instance
          .collection('posts')
          .where(
            'createdById',
            isEqualTo: user,
          )
          .orderBy("createdAt")
          .limit(500);
      var posts = await query.get();
      return Right(posts.docs.map((doc) => Post.fromSnapshot(doc)).toList());
    } catch (ex) {
      return Left(APIError(500));
    }
  }
}
