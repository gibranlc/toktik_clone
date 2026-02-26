import 'package:flutter/foundation.dart';

class UserActionsProvider extends ChangeNotifier {
  final Set<String> _favorites = <String>{};
  final Set<String> _muted = <String>{};

  bool isFavorite(String id) => _favorites.contains(id);
  void toggleFavorite(String id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    notifyListeners();
  }

  bool isMuted(String id) => _muted.contains(id);
  void toggleMute(String id) {
    if (_muted.contains(id)) {
      _muted.remove(id);
    } else {
      _muted.add(id);
    }
    notifyListeners();
  }
}
