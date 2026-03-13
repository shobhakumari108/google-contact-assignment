import 'package:flutter/material.dart';
import '../controllers/contact_controller.dart';

class ContactProvider extends ChangeNotifier {
  final ContactController _contactController = ContactController();
  
  ContactController get contactController => _contactController;
  
  // Navigation state
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  
  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
  
  // Search state
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
  
  // Loading overlay state
  bool _showLoadingOverlay = false;
  bool get showLoadingOverlay => _showLoadingOverlay;
  
  void setLoadingOverlay(bool show) {
    _showLoadingOverlay = show;
    notifyListeners();
  }
  
  // Initial loading state
  bool _isInitialLoading = true;
  bool get isInitialLoading => _isInitialLoading;
  
  void setInitialLoading(bool loading) {
    _isInitialLoading = loading;
    notifyListeners();
  }
  
  // Error handling
  void handleError(String error) {
    ScaffoldMessenger.of(getCurrentContext()).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  void showSuccessMessage(String message) {
    ScaffoldMessenger.of(getCurrentContext()).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  BuildContext? _context;
  BuildContext getCurrentContext() {
    return _context ??= navigatorKey.currentContext!;
  }
  
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  void setContext(BuildContext context) {
    _context = context;
  }
}
