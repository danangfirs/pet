import 'package:flutter/material.dart';

class ProfileService extends ChangeNotifier {
  String _name = 'Zidan Mirza';
  String _email = 'ZidanMirza27@email.com';
  String _imageUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=2680&auto=format&fit=crop';

  String get name => _name;
  String get email => _email;
  String get imageUrl => _imageUrl;

  void updateProfile(String name, String email, {String? imageUrl}) {
    _name = name;
    _email = email;
    if (imageUrl != null) {
      _imageUrl = imageUrl;
    }
    notifyListeners();
  }
}

