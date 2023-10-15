import 'package:either_dart/either.dart';

import 'models.dart';

abstract class Flutter8API {
  Future<Either<APIError, List<Post>>> listNextPosts({String id = '', int limit = 10});

  Future<Either<APIError, Post>> getPost(String id);

  Future<Either<APIError, bool>> incrementCopyCount(Post post);
}
