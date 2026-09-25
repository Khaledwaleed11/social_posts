import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/comment_model.dart';

abstract class CommentsRemoteDataSource {
  Future<List<CommentModel>> getComments({required String postId});

  Future<CommentModel> addComment({
    required String postId,
    required String content,
  });

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  });
}

class CommentsRemoteDataSourceImpl implements CommentsRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  CommentsRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  CollectionReference<Map<String, dynamic>> _commentsCollection(String postId) {
    return firestore.collection('posts').doc(postId).collection('comments');
  }

  DocumentReference<Map<String, dynamic>> _postDocument(String postId) {
    return firestore.collection('posts').doc(postId);
  }

  @override
  Future<List<CommentModel>> getComments({required String postId}) async {
    final snapshot = await _commentsCollection(postId)
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs.map((document) {
      return CommentModel.fromMap(
        document.data(),
        documentId: document.id,
        postId: postId,
      );
    }).toList();
  }

  @override
  Future<CommentModel> addComment({
    required String postId,
    required String content,
  }) async {
    final currentUser = firebaseAuth.currentUser;

    if (currentUser == null) {
      throw Exception('User is not logged in.');
    }

    final trimmedContent = content.trim();

    if (trimmedContent.isEmpty) {
      throw Exception('Comment cannot be empty.');
    }

    final userDocument = await firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final userData = userDocument.data();

    final postDocument = await _postDocument(postId).get();

    if (!postDocument.exists) {
      throw Exception('Post not found.');
    }

    final commentDocument = _commentsCollection(postId).doc();

    final comment = CommentModel(
      id: commentDocument.id,
      postId: postId,
      userId: currentUser.uid,
      userName: userData?['name'] ?? 'User',
      userImage: userData?['imageUrl'],
      content: trimmedContent,
      createdAt: DateTime.now(),
    );

    final batch = firestore.batch();

    // Add the comment.
    batch.set(commentDocument, comment.toMap());

    // Increase comments counter atomically.
    batch.update(_postDocument(postId), {
      'commentsCount': FieldValue.increment(1),
    });

    await batch.commit();

    return comment;
  }

  @override
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final currentUser = firebaseAuth.currentUser;

    if (currentUser == null) {
      throw Exception('User is not logged in.');
    }

    final commentDocument = await _commentsCollection(postId)
        .doc(commentId)
        .get();

    if (!commentDocument.exists) {
      throw Exception('Comment not found.');
    }

    final data = commentDocument.data();

    if (data == null) {
      throw Exception('Comment data not found.');
    }

    final commentUserId = data['userId'] as String?;

    if (commentUserId != currentUser.uid) {
      throw Exception('You can only delete your own comments.');
    }

    final batch = firestore.batch();

    batch.delete(commentDocument.reference);

    batch.update(_postDocument(postId), {
      'commentsCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }
}
