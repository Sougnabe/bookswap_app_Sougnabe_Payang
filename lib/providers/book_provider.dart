import 'package:flutter/foundation.dart';
import 'package:bookswap_app/models/book_listing.dart';
import 'package:bookswap_app/services/firestore_service.dart';
import 'package:bookswap_app/services/storage_service.dart';

class BookProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  
  List<BookListing> _allBooks = [];
  List<BookListing> _userBooks = [];
  bool _isLoading = false;
  String? _error;

  BookProvider(this._firestoreService, this._storageService);

  List<BookListing> get allBooks => _allBooks;
  List<BookListing> get userBooks => _userBooks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  StorageService get storageService => _storageService;

  void initialize(String userId) {
    _firestoreService.getBookListings().listen((books) {
      _allBooks = books;
      notifyListeners();
    });

    _firestoreService.getUserBookListings(userId).listen((books) {
      _userBooks = books;
      notifyListeners();
    });
  }

  Future<bool> addBook({
    required String title,
    required String author,
    required BookCondition condition,
    required String imageUrl,
    required String ownerId,
    required String ownerName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final book = BookListing(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        author: author,
        condition: condition,
        imageUrl: imageUrl,
        ownerId: ownerId,
        ownerName: ownerName,
        createdAt: DateTime.now(),
      );

      await _firestoreService.addBookListing(book);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBook(BookListing book) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.updateBookListing(book);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBook(String bookId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.deleteBookListing(bookId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}