import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qurantafsir_flutter/pages/main_page.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';
import 'package:qurantafsir_flutter/shared/core/apis/bookmark_api.dart';
import 'package:qurantafsir_flutter/shared/core/apis/user_api.dart';
import 'package:qurantafsir_flutter/shared/core/models/force_login_param.dart';
import 'package:qurantafsir_flutter/shared/core/models/user.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/user_response.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:retrofit/retrofit.dart';

class AuthenticationService {
  AuthenticationService({
    required this.userApi,
    required SharedPreferenceService sharedPreferenceService,
  }) : _sharedPreferenceService = sharedPreferenceService;

  final UserApi userApi;
  final SharedPreferenceService _sharedPreferenceService;
  bool _isLoggedIn = false;
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
  }

  Future<UserResponse> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();

      var user = User(
        name: googleUser?.displayName ?? '',
        email: googleUser?.email ?? '',
      );

      HttpResponse<UserResponse> response = await userApi.createUser(user);

      if (response.response.statusCode != 200) {
        throw Exception('SignIn failed');
      }

      var token = response.data.token ?? '';
      if (token.isEmpty) {
        throw Exception('SignIn failed, token is empty');
      }

      setIsLoggedIn(true);

      return response.data;
    } catch (error) {
      throw Exception('SignIn error: ' + error.toString());
    }
  }

  Future<void> signOut() async {
    _googleSignIn.signOut();
    setIsLoggedIn(false);
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
            'getUserProfile error: ' + response.data.errorMessage.toString());
      }

      return data;
    } catch (error) {
      throw Exception('getUserProfile error: ' + error.toString());
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
    } catch (error) {
      throw Exception('updateUserProfile error: ' + error.toString());
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
        MainPage.globalKey.currentWidget as BottomNavigationBar;

    navbar.onTap!(3);
  }
}
