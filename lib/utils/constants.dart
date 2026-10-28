import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'BookShelf';
  static const String appDescription =
      'Keep your own private list of books you own or want to read, sorted into reading statuses and genres, with your favorite flags.';

  // Feature Cards
  static const String featureTrackBooks = 'Track your books';
  static const String featureSortStatus = 'Sort by status';
  static const String featureRateFavorites = 'Rate your favorites';

  // Navigation & Headers
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';

  // Genres
  static const String genreChoose = 'Choose genre';
  static const String genreFiction = 'Fiction';
  static const String genreNonFiction = 'Non-Fiction';
  static const String genreAcademic = 'Academic';
  static const String genreOther = 'Other';

  static const List<String> genres = [
    genreFiction,
    genreNonFiction,
    genreAcademic,
    genreOther,
  ];

  static const List<String> genreFilterOptions = [
    'All',
    genreFiction,
    genreNonFiction,
    genreAcademic,
    genreOther,
  ];

  // Statuses
  static const String statusChoose = 'Choose status';
  static const String statusToRead = 'To Read';
  static const String statusReading = 'Reading';
  static const String statusFinished = 'Finished';

  static const List<String> statuses = [
    statusToRead,
    statusReading,
    statusFinished,
  ];

  static const List<String> statusFilterOptions = [
    'All',
    statusToRead,
    statusReading,
    statusFinished,
  ];

  // Validation Error Messages - Auth
  static const String errEmailRequired = 'Email is required';
  static const String errEmailInvalid = 'Please enter a valid email address';
  static const String errPasswordRequired = 'Password is required';
  static const String errPasswordMinLength = 'Password must be at least 6 characters';
  static const String errConfirmPasswordRequired = 'Confirm password is required';
  static const String errPasswordsDoNotMatch = 'Passwords do not match';

  // Validation Error Messages - Book
  static const String errTitleRequired = 'Title is required';
  static const String errTitleMaxLength = 'Title must be at most 100 characters';
  static const String errAuthorRequired = 'Author is required';
  static const String errAuthorMaxLength = 'Author must be at most 60 characters';
  static const String errGenreRequired = 'Please choose a genre';
  static const String errStatusRequired = 'Please choose a status';
  static const String errRatingInvalid = 'Rating must be a whole number from 0 to 5';
  static const String errNotesMaxLength = 'Notes must be at most 300 characters';

  // Success Messages
  static const String msgRegistrationSuccessful = 'Registration successful';
  static const String msgBookAdded = 'Book added';

  // Empty States
  static const String noBooksFound = 'No books found';

  // UI Theme Colors
  static const Color primaryColor = Color(0xFF2E5B88);
  static const Color primaryDark = Color(0xFF1B365D);
  static const Color secondaryColor = Color(0xFFE08D3C);
  static const Color backgroundColor = Color(0xFFF7F9FC);
  static const Color surfaceColor = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color errorColor = Color(0xFFDC2626);
  static const Color successColor = Color(0xFF16A34A);
  static const Color favoriteGold = Color(0xFFF59E0B);
}

