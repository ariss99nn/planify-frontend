import 'package:flutter/material.dart';

/// Provider para manejar el estado de navegación del Home
/// Controla el índice actual y la visibilidad del drawer
class HomeNavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _drawerVisible = true;

  int get currentIndex => _currentIndex;
  bool get drawerVisible => _drawerVisible;

  /// Cambiar el índice de la pantalla actual
  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// Alternar la visibilidad del drawer
  void toggleDrawer() {
    _drawerVisible = !_drawerVisible;
    notifyListeners();
  }

  /// Mostrar el drawer
  void showDrawer() {
    if (!_drawerVisible) {
      _drawerVisible = true;
      notifyListeners();
    }
  }

  /// Ocultar el drawer
  void hideDrawer() {
    if (_drawerVisible) {
      _drawerVisible = false;
      notifyListeners();
    }
  }

  /// Resetear a valores por defecto
  void reset() {
    _currentIndex = 0;
    _drawerVisible = true;
    notifyListeners();
  }
}
