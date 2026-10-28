import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _booksCollection => _firestore.collection('books');

  // Stream of books for a specific user
  Stream<List<BookModel>> getBooksStream(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    return _booksCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final books = snapshot.docs
          .map((doc) => BookModel.fromFirestore(doc))
          .toList();

      // Sort alphabetically by title (case-insensitive), equal titles ordered by author
      books.sort((a, b) {
        final titleCompare =
            a.title.toLowerCase().compareTo(b.title.toLowerCase());
        if (titleCompare != 0) {
          return titleCompare;
        }
        return a.author.toLowerCase().compareTo(b.author.toLowerCase());
      });

      return books;
    });
  }

  // Add a new book
  Future<void> addBook({
    required String userId,
    required String title,
    required String author,
    required String genre,
    required String status,
    int? rating,
    String? notes,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedAuthor = author.trim();
    final trimmedNotes = (notes != null && notes.trim().isNotEmpty) ? notes.trim() : null;

    // Check if any existing book with the same title and author exists for this user (case-insensitive check)
    final existingSnapshot = await _booksCollection
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in existingSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final existingTitle = (data['title'] as String? ?? '').trim().toLowerCase();
      final existingAuthor = (data['author'] as String? ?? '').trim().toLowerCase();

      if (existingTitle == trimmedTitle.toLowerCase() &&
          existingAuthor == trimmedAuthor.toLowerCase()) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'already-exists',
          message: 'The book "$trimmedTitle" by "$trimmedAuthor" has already been saved.',
        );
      }
    }

    // Generate deterministic document ID based on userId, lowercase title and author
    final docId = BookModel.generateDocId(userId, trimmedTitle, trimmedAuthor);
    final docRef = _booksCollection.doc(docId);

    final newBook = BookModel(
      id: docId,
      userId: userId,
      title: trimmedTitle,
      author: trimmedAuthor,
      genre: genre,
      status: status,
      rating: rating,
      favorite: false,
      notes: trimmedNotes,
      createdAt: DateTime.now(),
    );

    await docRef.set(newBook.toFirestore());
  }

  // Toggle favorite flag
  Future<void> toggleFavorite(String bookId, bool currentFavorite) async {
    await _booksCollection.doc(bookId).update({
      'favorite': !currentFavorite,
    });
  }

  // Update existing book
  Future<void> updateBook({
    required String bookId,
    required String userId,
    required String title,
    required String author,
    required String genre,
    required String status,
    int? rating,
    String? notes,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedAuthor = author.trim();
    final trimmedNotes = (notes != null && notes.trim().isNotEmpty) ? notes.trim() : null;

    // Check duplicate check excluding current book
    final existingSnapshot = await _booksCollection
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in existingSnapshot.docs) {
      if (doc.id == bookId) continue;
      final data = doc.data() as Map<String, dynamic>;
      final existingTitle = (data['title'] as String? ?? '').trim().toLowerCase();
      final existingAuthor = (data['author'] as String? ?? '').trim().toLowerCase();

      if (existingTitle == trimmedTitle.toLowerCase() &&
          existingAuthor == trimmedAuthor.toLowerCase()) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'already-exists',
          message: 'Another book with title "$trimmedTitle" and author "$trimmedAuthor" already exists.',
        );
      }
    }

    await _booksCollection.doc(bookId).update({
      'title': trimmedTitle,
      'author': trimmedAuthor,
      'genre': genre,
      'status': status,
      'rating': rating,
      'notes': trimmedNotes,
    });
  }

  // Delete book
  Future<void> deleteBook(String bookId) async {
    await _booksCollection.doc(bookId).delete();
  }
}
