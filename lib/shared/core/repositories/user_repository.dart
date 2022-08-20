import 'package:google_sign_in/google_sign_in.dart';
import 'package:qurantafsir_flutter/shared/core/apis/user_api.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/core/models/user.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/user_response.dart';
import 'package:retrofit/retrofit.dart';

class UserRepository {
  UserRepository({required this.userApi, required this.sharedPreferenceService});

  final UserApi userApi;
  final SharedPreferenceService sharedPreferenceService;
  late GoogleSignIn _googleSignIn;

  Future<void> initRepository() async {
    _googleSignIn = GoogleSignIn(scopes: [
      'email',
      'profile',
    ]);
  }

  Future<String> signInWithGoogle() async {
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

      var username = response.data.data?.name ?? '';
      if (username.isNotEmpty) {
        setUsername(username);
      }

      setToken(token);
      return token;
    } catch (error) {
      throw Exception('SignIn error: ' + error.toString());
    }
  }

  Future<void> signOut() async {
    _googleSignIn.signOut();
    removeToken();
    removeUsername();
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

      setUsername(data.name);
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

  Future<String> getToken() async {
    return await sharedPreferenceService.getApiToken();
  }

  Future<void> setToken(String token) async {
    await sharedPreferenceService.setApiToken(token);
  }

  Future<void> removeToken() async {
    await sharedPreferenceService.removeApiToken();
  }

  Future<String> getUsername() async {
    return await sharedPreferenceService.getUsername();
  }

  Future<void> setUsername(String name) async {
    await sharedPreferenceService.setUsername(name);
  }

  Future<void> removeUsername() async {
    await sharedPreferenceService.removeUsername();
  }
}
