import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/book_service.dart';
import '../utils/constants.dart';

class BookProvider extends ChangeNotifier {
  final BookService _bookService = BookService();

  List<BookModel> _allBooks = [];
  StreamSubscription<List<BookModel>>? _booksSubscription;
  bool _isLoading = true;
  String? _userId;

  // Filter & Search states
  String _selectedGenre = 'All';
  String _selectedStatus = 'All';
  bool _favoritesOnly = false;
  String _searchQuery = '';

  // Getters
  bool get isLoading => _isLoading;
  String get selectedGenre => _selectedGenre;
  String get selectedStatus => _selectedStatus;
  bool get favoritesOnly => _favoritesOnly;
  String get searchQuery => _searchQuery;

  // Initialize and listen to books for user
  void setUserId(String? userId) {
    if (_userId == userId && !_isLoading) return;
    _userId = userId;
    _booksSubscription?.cancel();

    if (userId == null || userId.isEmpty) {
      _allBooks = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _booksSubscription = _bookService.getBooksStream(userId).listen(
      (books) {
        _allBooks = books;
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Filtered books list
  List<BookModel> get filteredBooks {
    return _allBooks.where((book) {
      // 1. Genre filter
      if (_selectedGenre != 'All' && book.genre != _selectedGenre) {
        return false;
      }

      // 2. Status filter
      if (_selectedStatus != 'All' && book.status != _selectedStatus) {
        return false;
      }

      // 3. Favorites only filter
      if (_favoritesOnly && !book.favorite) {
        return false;
      }

      // 4. Search query filter (title or author contains, not case-sensitive, spaces at both ends ignored)
      final trimmedQuery = _searchQuery.trim().toLowerCase();
      if (trimmedQuery.isNotEmpty) {
        final titleMatch = book.title.toLowerCase().contains(trimmedQuery);
        final authorMatch = book.author.toLowerCase().contains(trimmedQuery);
        if (!titleMatch && !authorMatch) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Summary breakdown item
  // Breakdown rules:
  // "one row per status that appears, the status with the most books first
  // (equal counts: To Read, then Reading, then Finished), each row showing the status name and how many books it has."
  List<MapEntry<String, int>> get statusBreakdown {
    final currentFiltered = filteredBooks;
    final Map<String, int> counts = {};

    for (var book in currentFiltered) {
      counts[book.status] = (counts[book.status] ?? 0) + 1;
    }

    // Convert to entries and sort:
    // Highest count first. If counts equal: To Read (0), Reading (1), Finished (2)
    final entries = counts.entries.toList();
    const statusPriority = {
      AppConstants.statusToRead: 0,
      AppConstants.statusReading: 1,
      AppConstants.statusFinished: 2,
    };

    entries.sort((a, b) {
      final countCompare = b.value.compareTo(a.value); // highest count first
      if (countCompare != 0) {
        return countCompare;
      }
      final prioA = statusPriority[a.key] ?? 99;
      final prioB = statusPriority[b.key] ?? 99;
      return prioA.compareTo(prioB);
    });

    return entries;
  }

  int get totalBooksCount => filteredBooks.length;
  int get favoritesCount => filteredBooks.where((b) => b.favorite).length;

  // Filter controls
  void setGenre(String genre) {
    _selectedGenre = genre;
    notifyListeners();
  }

  void setStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setFavoritesOnly(bool value) {
    _favoritesOnly = value;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _selectedGenre = 'All';
    _selectedStatus = 'All';
    _favoritesOnly = false;
    _searchQuery = '';
    notifyListeners();
  }

  // Actions
  Future<void> addBook({
    required String title,
    required String author,
    required String genre,
    required String status,
    int? rating,
    String? notes,
  }) async {
    final effectiveUserId = _userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (effectiveUserId == null) {
      throw Exception('User is not signed in.');
    }
    await _bookService.addBook(
      userId: effectiveUserId,
      title: title,
      author: author,
      genre: genre,
      status: status,
      rating: rating,
      notes: notes,
    );
  }

  Future<void> toggleFavorite(String bookId, bool currentFavorite) async {
    await _bookService.toggleFavorite(bookId, currentFavorite);
  }

  Future<void> updateBook({
    required String bookId,
    required String title,
    required String author,
    required String genre,
    required String status,
    int? rating,
    String? notes,
  }) async {
    final effectiveUserId = _userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (effectiveUserId == null) return;
    await _bookService.updateBook(
      bookId: bookId,
      userId: effectiveUserId,
      title: title,
      author: author,
      genre: genre,
      status: status,
      rating: rating,
      notes: notes,
    );
  }

  Future<void> deleteBook(String bookId) async {
    await _bookService.deleteBook(bookId);
  }

  @override
  void dispose() {
    _booksSubscription?.cancel();
    super.dispose();
  }
}

