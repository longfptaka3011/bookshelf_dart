import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/utils/constants.dart';
import 'package:bookshelf/utils/validators.dart';

void main() {
  group('Auth FormValidators Tests', () {
    test('Email validation tests', () {
      expect(FormValidators.validateEmail(''), AppConstants.errEmailRequired);
      expect(FormValidators.validateEmail('   '), AppConstants.errEmailRequired);
      expect(FormValidators.validateEmail('notanemail'), AppConstants.errEmailInvalid);
      expect(FormValidators.validateEmail('user@domain.com'), isNull);
    });

    test('Password validation tests', () {
      expect(FormValidators.validateLoginPassword(''), AppConstants.errPasswordRequired);
      expect(FormValidators.validateLoginPassword('123'), isNull);

      expect(FormValidators.validateRegisterPassword(''), AppConstants.errPasswordRequired);
      expect(FormValidators.validateRegisterPassword('12345'), AppConstants.errPasswordMinLength);
      expect(FormValidators.validateRegisterPassword('123456'), isNull);
    });

    test('Confirm password validation tests', () {
      expect(FormValidators.validateConfirmPassword('', '123456'), AppConstants.errConfirmPasswordRequired);
      expect(FormValidators.validateConfirmPassword('12345', '123456'), AppConstants.errPasswordsDoNotMatch);
      expect(FormValidators.validateConfirmPassword('123456', '123456'), isNull);
    });
  });

  group('Book FormValidators Tests', () {
    test('Title validation tests', () {
      expect(FormValidators.validateTitle(''), AppConstants.errTitleRequired);
      expect(FormValidators.validateTitle('    '), AppConstants.errTitleRequired);
      expect(FormValidators.validateTitle('a' * 101), AppConstants.errTitleMaxLength);
      expect(FormValidators.validateTitle('Valid Title'), isNull);
    });

    test('Author validation tests', () {
      expect(FormValidators.validateAuthor(''), AppConstants.errAuthorRequired);
      expect(FormValidators.validateAuthor('   '), AppConstants.errAuthorRequired);
      expect(FormValidators.validateAuthor('a' * 61), AppConstants.errAuthorMaxLength);
      expect(FormValidators.validateAuthor('Valid Author'), isNull);
    });

    test('Genre validation tests', () {
      expect(FormValidators.validateGenre(AppConstants.genreChoose), AppConstants.errGenreRequired);
      expect(FormValidators.validateGenre('InvalidGenre'), AppConstants.errGenreRequired);
      expect(FormValidators.validateGenre(AppConstants.genreFiction), isNull);
      expect(FormValidators.validateGenre(AppConstants.genreAcademic), isNull);
    });

    test('Status validation tests', () {
      expect(FormValidators.validateStatus(AppConstants.statusChoose), AppConstants.errStatusRequired);
      expect(FormValidators.validateStatus('InvalidStatus'), AppConstants.errStatusRequired);
      expect(FormValidators.validateStatus(AppConstants.statusToRead), isNull);
      expect(FormValidators.validateStatus(AppConstants.statusFinished), isNull);
    });

    test('Rating validation tests', () {
      expect(FormValidators.validateRating(null), isNull);
      expect(FormValidators.validateRating(''), isNull);
      expect(FormValidators.validateRating('-1'), AppConstants.errRatingInvalid);
      expect(FormValidators.validateRating('6'), AppConstants.errRatingInvalid);
      expect(FormValidators.validateRating('abc'), AppConstants.errRatingInvalid);
      expect(FormValidators.validateRating('5'), isNull);
      expect(FormValidators.validateRating('0'), isNull);
    });

    test('Notes validation tests', () {
      expect(FormValidators.validateNotes(null), isNull);
      expect(FormValidators.validateNotes(''), isNull);
      expect(FormValidators.validateNotes('a' * 301), AppConstants.errNotesMaxLength);
      expect(FormValidators.validateNotes('a' * 300), isNull);
    });
  });
}
