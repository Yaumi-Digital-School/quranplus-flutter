import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/core/apis/user_api.dart';
import 'package:qurantafsir_flutter/shared/core/env.dart';
import 'package:qurantafsir_flutter/shared/core/models/force_login_param.dart';
import 'package:qurantafsir_flutter/shared/core/models/user.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/user_response.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/dio_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:retrofit/retrofit.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

enum SignInResult {
  success,
  failedGeneral,
  failedAccountDeleted,
}

class AuthenticationService {
  AuthenticationService({
    required this.userApi,
    required SharedPreferenceService sharedPreferenceService,
  }) : _sharedPreferenceService = sharedPreferenceService;

  final UserApi userApi;
  final SharedPreferenceService _sharedPreferenceService;
  late bool _isLoggedIn;
  late GoogleSignIn _googleSignIn;

  bool get isLoggedIn => _isLoggedIn;

  void setIsLoggedIn(bool value) {
    _isLoggedIn = value;
  }

  Future<void> initRepository() async {
    _googleSignIn = GoogleSignIn(scopes: [
      'email',
      'profile',
    ]);

    _isLoggedIn = _sharedPreferenceService.getApiToken().isNotEmpty;
  }

  Future<SignInResult> signIn({
    required SignInType type,
    required WidgetRef ref,
  }) async {
    try {
      late RegisterOrLoginRequest request;

      switch (type) {
        case SignInType.google:
          final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

          if (googleUser == null) {
            return SignInResult.failedGeneral;
          }

          request = RegisterOrLoginRequest(
            name: googleUser.displayName,
            email: googleUser.email,
          );
          break;
        case SignInType.apple:
          final AuthorizationCredentialAppleID credential =
              await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
          );

          request = RegisterOrLoginRequest(
            name: credential.givenName != null
                ? '${credential.givenName} ${credential.familyName}'
                : null,
            email: credential.email ?? '',
            appleTokenID: credential.userIdentifier,
          );
          break;
      }

      HttpResponse<UserResponse> response = await userApi.createUser(request);

      if (response.response.statusCode != 200) {
        _googleSignIn.signOut();
        throw Exception('SignIn failed');
      }

      if (response.data.errorMessage == 'Account has been deleted') {
        _googleSignIn.signOut();

        return SignInResult.failedAccountDeleted;
      }

      var token = response.data.token ?? '';
      if (token.isEmpty) {
        _googleSignIn.signOut();
        throw Exception('SignIn failed, token is empty');
      }

      setIsLoggedIn(true);
      await _setToken(response.data.token!);
      await _setUsername(response.data.data!.name);

      ref.read(dioServiceProvider.notifier).state = DioService(
        baseUrl: EnvConstants.baseUrl!,
        accessToken: _sharedPreferenceService.getApiToken(),
        aliceService: ref.read(aliceServiceProvider),
      );

      ref.read(bookmarksService).clearBookmarkAndMergeFromServer();

      return SignInResult.success;
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on initRepository() method',
      );
      throw Exception('SignIn error: $error');
    }
  }

  Future<void> _setUsername(String name) async {
    await _sharedPreferenceService.setUsername(name);
  }

  Future<void> _setToken(String token) async {
    await _sharedPreferenceService.setApiToken(token);
  }

  Future<void> signOut() async {
    _googleSignIn.signOut();
    setIsLoggedIn(false);
    _sharedPreferenceService.clear();
  }

  Future<User> getUserProfile(String token) async {
    try {
      HttpResponse<UserResponse> response = await userApi.getUserProfile(token);

      if (response.response.statusCode != 200) {
        throw Exception('getUserProfile failed');
      }

      var data = response.data.data;
      if (data == null) {
        throw Exception(
          'getUserProfile error: ${response.data.errorMessage}',
        );
      }

      return data;
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on getUserProfile() method',
      );
      throw Exception('getUserProfile error: $error');
    }
  }

  Future<bool> updateUserProfile(String token, User user) async {
    try {
      HttpResponse<UserResponse> response =
          await userApi.updateUserProfile(token, user);

      if (response.response.statusCode != 200) {
        throw Exception('updateUserProfile failed');
      }

      var message = response.data.message;
      if (message == null) {
        return false;
      }

      return true;
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on updateUserProfile() method',
      );
      throw Exception('updateUserProfile error: $error');
    }
  }

  void forceLoginAndSaveRedirectTo({
    required BuildContext context,
    required String redirectTo,
    required Map<String, dynamic> arguments,
  }) {
    _sharedPreferenceService.setForceLoginParam(
      ForceLoginParam(
        nextPath: redirectTo,
        arguments: arguments,
      ),
    );

    Navigator.pop(
      context,
    );

    final BottomNavigationBar navbar =
        mainNavbarGlobalKey.currentWidget as BottomNavigationBar;

    navbar.onTap!(4);
  }
}
