import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  void setUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void clear() {
    _currentUser = null;
    notifyListeners();
  }
}
