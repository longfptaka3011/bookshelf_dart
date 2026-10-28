import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel {
  final String id;
  final String userId;
  final String title;
  final String author;
  final String genre;
  final String status;
  final int? rating;
  final bool favorite;
  final String? notes;
  final DateTime createdAt;

  BookModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.author,
    required this.genre,
    required this.status,
    this.rating,
    this.favorite = false,
    this.notes,
    required this.createdAt,
  });

  /// Generates a clean, deterministic, URL-safe document ID to enforce:
  /// "the same person cannot save the same title + author twice, even if the letter case differs;
  /// two different people may save the same book."
  static String generateDocId(String userId, String title, String author) {
    final rawKey = '${userId}_${title.trim().toLowerCase()}_${author.trim().toLowerCase()}';
    final base64Key = base64Url.encode(utf8.encode(rawKey)).replaceAll('=', '');
    return 'b_$base64Key';
  }

  factory BookModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime parsedCreatedAt;
    final rawCreatedAt = data['createdAt'];
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return BookModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      genre: data['genre'] ?? 'Other',
      status: data['status'] ?? 'To Read',
      rating: data['rating'] is int ? data['rating'] as int : (int.tryParse('${data['rating']}')),
      favorite: data['favorite'] == true,
      notes: data['notes'] as String?,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'author': author,
      'genre': genre,
      'status': status,
      'rating': rating,
      'favorite': favorite,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  BookModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? author,
    String? genre,
    String? status,
    int? rating,
    bool? favorite,
    String? notes,
    DateTime? createdAt,
  }) {
    return BookModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      favorite: favorite ?? this.favorite,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
