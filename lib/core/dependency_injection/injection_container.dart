import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/comments/data/datasources/comments_remote_data_source.dart';
import '../../features/comments/data/repositories/comments_repository_impl.dart';
import '../../features/comments/domain/repositories/comments_repository.dart';
import '../../features/comments/domain/usecases/add_comment_usecase.dart';
import '../../features/comments/domain/usecases/delete_comment_usecase.dart';
import '../../features/comments/domain/usecases/get_comments_usecase.dart';
import '../../features/comments/presentation/cubit/comments_cubit.dart';
import '../../features/posts/data/datasources/posts_remote_data_source.dart';
import '../../features/posts/data/repositories/posts_repository_impl.dart';
import '../../features/posts/domain/repositories/posts_repository.dart';
import '../../features/posts/domain/usecases/create_post_usecase.dart';
import '../../features/posts/domain/usecases/delete_post_usecase.dart';
import '../../features/posts/domain/usecases/get_posts_usecase.dart';
import '../../features/posts/domain/usecases/toggle_like_usecase.dart';
import '../../features/posts/presentation/cubit/posts_cubit.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_image_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../storage/cloudinary_image_storage_data_source.dart';
import '../storage/image_storage_data_source.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ============================================================
  // Firebase
  // ============================================================

  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // ============================================================
  // Image Storage
  // Cloudinary instead of Firebase Storage
  // ============================================================

  sl.registerLazySingleton<ImageStorageDataSource>(
    () => CloudinaryImageStorageDataSource(),
  );

  // ============================================================
  // Auth - Data Source
  // ============================================================

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
  );

  // ============================================================
  // Auth - Repository
  // ============================================================

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // ============================================================
  // Auth - Use Cases
  // ============================================================

  sl.registerLazySingleton(() => RegisterUseCase(sl()));

  sl.registerLazySingleton(() => LoginUseCase(sl()));

  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // ============================================================
  // Posts - Data Source
  // ============================================================

  sl.registerLazySingleton<PostsRemoteDataSource>(
    () => PostsRemoteDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
      imageStorageDataSource: sl(),
    ),
  );

  // ============================================================
  // Posts - Repository
  // ============================================================

  sl.registerLazySingleton<PostsRepository>(
    () => PostsRepositoryImpl(remoteDataSource: sl()),
  );

  // ============================================================
  // Posts - Use Cases
  // ============================================================

  sl.registerLazySingleton(() => GetPostsUseCase(sl()));

  sl.registerLazySingleton(() => CreatePostUseCase(sl()));

  sl.registerLazySingleton(() => ToggleLikeUseCase(sl()));

  sl.registerLazySingleton(() => DeletePostUseCase(sl()));

  // ============================================================
  // Comments - Data Source
  // ============================================================

  sl.registerLazySingleton<CommentsRemoteDataSource>(
    () => CommentsRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()),
  );

  // ============================================================
  // Comments - Repository
  // ============================================================

  sl.registerLazySingleton<CommentsRepository>(
    () => CommentsRepositoryImpl(remoteDataSource: sl()),
  );

  // ============================================================
  // Comments - Use Cases
  // ============================================================

  sl.registerLazySingleton(() => GetCommentsUseCase(sl()));

  sl.registerLazySingleton(() => AddCommentUseCase(sl()));

  sl.registerLazySingleton(() => DeleteCommentUseCase(sl()));

  // ============================================================
  // Auth Cubit
  // ============================================================

  sl.registerFactory(
    () => AuthCubit(
      registerUseCase: sl(),
      loginUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  // ============================================================
  // Posts Cubit
  // ============================================================

  sl.registerFactory(
    () => PostsCubit(
      getPostsUseCase: sl(),
      createPostUseCase: sl(),
      toggleLikeUseCase: sl(),
      deletePostUseCase: sl(),
    ),
  );

  // ============================================================
  // Comments Cubit
  // ============================================================

  sl.registerFactory(
    () => CommentsCubit(
      getCommentsUseCase: sl(),
      addCommentUseCase: sl(),
      deleteCommentUseCase: sl(),
    ),
  );

  // ============================================================
  // Profile - Data Source
  // ============================================================

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
      imageStorageDataSource: sl(),
    ),
  );

  // ============================================================
  // Profile - Repository
  // ============================================================

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  // ============================================================
  // Profile - Use Cases
  // ============================================================

  sl.registerLazySingleton(() => GetProfileUseCase(sl()));

  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));

  sl.registerLazySingleton(() => UpdateProfileImageUseCase(sl()));

  // ============================================================
  // Profile Cubit
  // ============================================================

  sl.registerFactory(
    () => ProfileCubit(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      updateProfileImageUseCase: sl(),
    ),
  );
}
