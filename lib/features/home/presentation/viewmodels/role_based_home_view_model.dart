part of fixmate_app;

class RoleBasedHomeViewModel extends ChangeNotifier {
  RoleBasedHomeViewModel({required this.mode, int initialIndex = 0})
      : index = initialIndex;

  final String mode;
  int index;

  bool get providerMode => mode == 'provider';
  String get appName => providerMode ? 'FixSeva Provider' : 'FixSeva Customer';

  void selectIndex(int value) {
    index = value;
    notifyListeners();
  }
}

