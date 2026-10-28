import 'constants.dart';

class FormValidators {
  // Regex for email validation
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.errEmailRequired;
    }
    if (!_emailRegExp.hasMatch(value.trim())) {
      return AppConstants.errEmailInvalid;
    }
    return null;
  }

  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.errPasswordRequired;
    }
    return null;
  }

  static String? validateRegisterPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.errPasswordRequired;
    }
    if (value.length < 6) {
      return AppConstants.errPasswordMinLength;
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return AppConstants.errConfirmPasswordRequired;
    }
    if (value != password) {
      return AppConstants.errPasswordsDoNotMatch;
    }
    return null;
  }

  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.errTitleRequired;
    }
    if (value.length > 100) {
      return AppConstants.errTitleMaxLength;
    }
    return null;
  }

  static String? validateAuthor(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.errAuthorRequired;
    }
    if (value.length > 60) {
      return AppConstants.errAuthorMaxLength;
    }
    return null;
  }

  static String? validateGenre(String? value) {
    if (value == null ||
        value.isEmpty ||
        value == AppConstants.genreChoose ||
        !AppConstants.genres.contains(value)) {
      return AppConstants.errGenreRequired;
    }
    return null;
  }

  static String? validateStatus(String? value) {
    if (value == null ||
        value.isEmpty ||
        value == AppConstants.statusChoose ||
        !AppConstants.statuses.contains(value)) {
      return AppConstants.errStatusRequired;
    }
    return null;
  }

  static String? validateRating(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Rating is optional
    }
    final int? parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 0 || parsed > 5) {
      return AppConstants.errRatingInvalid;
    }
    return null;
  }

  static String? validateNotes(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Notes is optional
    }
    if (value.length > 300) {
      return AppConstants.errNotesMaxLength;
    }
    return null;
  }
}

