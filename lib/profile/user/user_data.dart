import 'dart:convert';
import 'user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  static late SharedPreferences _preferences;
  static const _keyUser = 'user';
  static const String _defaultLocalImagePath = 'asset/user.jpg'; // Define a default local image path

  static User myUser = User(
    image: 'assets/user.jpg', // Initialize with an empty string
    name: 'Test Test',
    email: 'test.test@gmail.com',
    phone: '(268) 205-509',
    aboutMeDescription:
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat...',
  );

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setUser(User user) async {
    final json = jsonEncode(user.toJson());
    await _preferences.setString(_keyUser, json);
  }

  static User getUser() {
    final json = _preferences.getString(_keyUser);
    if (json == null) {
      return myUser; // Return default if no saved data
    } else {
      User loadedUser = User.fromJson(jsonDecode(json));
      // If the loaded image path is empty, use the default local image path
      if (loadedUser.image.isEmpty) {
        return loadedUser.copy(imagePath: _defaultLocalImagePath);
      }
      return loadedUser;
    }
  }
}