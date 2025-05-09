import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostei/features/auth/data/firebase_auth_repo.dart';
import 'package:nostei/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:nostei/features/auth/presentation/cubits/auth_states.dart';
import 'package:nostei/features/home/presentation/pages/home_page.dart';
import 'package:nostei/features/post/data/firebase_post_repo.dart';
import 'package:nostei/features/post/presentation/cubits/post_cubit.dart';
import 'package:nostei/features/profile/data/firebase_profile_repo.dart';
import 'package:nostei/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:nostei/features/storage/data/firebase_storage_repo.dart';
import 'package:nostei/themes/light_mode.dart';
import 'features/auth/presentation/pages/auth_page.dart';
//import 'features/post/presentation/pages/home_page.dart';

/*

APP - Root level

Repositories: for the database
  - firebase

Bloc Providers: for state management
  - auth
  -profile
  -post
  -search
  -theme

Check Auth State
  - unauthenticated -> auth page (login/register)
  - authenticated -> home page



 */

class MyApp extends StatelessWidget {
  final firebaseAuthRepo = FirebaseAuthRepo();

  // profile repo

  final firebaseProfileRepo = FirebaseProfileRepo();

  // storage repo
  final firebaseStorageRepo = FirebaseStorageRepo();

  // post repo
  final firebasePostRepo = FirebasePostRepo();

   MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // provide cubits to app
    return MultiBlocProvider(
        providers: [
          // auth cubit
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(authrepo: firebaseAuthRepo)..checkAuth(),
          ),

          // profile cubit
          BlocProvider<ProfileCubit>(
              create: (context) => ProfileCubit(
                  profileRepo: firebaseProfileRepo,
                  storageRepo: firebaseStorageRepo,
              ),
          ),

          // post cubit
          BlocProvider<PostCubit>(create: (context) => PostCubit(
              postRepo: firebasePostRepo,
            storageRepo: firebaseStorageRepo,
          ),)
          
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightMode,
          home: BlocConsumer<AuthCubit, AuthState>(
            builder: (context, authState) {
              print(authState);

              // unauthenticated -> auth page (login/register)
              if (authState is Unauthenticated)  {
                return const AuthPage();
              }

              if (authState is Authenticated) {
                return const HomePage();
              }

              else {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

            },
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),
        ),
    );
  }
}