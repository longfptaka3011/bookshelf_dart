import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import 'app_text_field.dart';

class AddBookForm extends StatefulWidget {
  final VoidCallback? onBookAdded;

  const AddBookForm({super.key, this.onBookAdded});

  @override
  State<AddBookForm> createState() => _AddBookFormState();
}

class _AddBookFormState extends State<AddBookForm> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _ratingController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedGenre = AppConstants.genreChoose;
  String _selectedStatus = AppConstants.statusChoose;

  bool _submitted = false;
  bool _isSubmitting = false;
  String? _firestoreError;
  String? _successMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _ratingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    setState(() {
      _submitted = true;
      _firestoreError = null;
      _successMessage = null;
    });

    final titleErr = FormValidators.validateTitle(_titleController.text);
    final authorErr = FormValidators.validateAuthor(_authorController.text);
    final genreErr = FormValidators.validateGenre(_selectedGenre);
    final statusErr = FormValidators.validateStatus(_selectedStatus);
    final ratingErr = FormValidators.validateRating(_ratingController.text);
    final notesErr = FormValidators.validateNotes(_notesController.text);

    if (titleErr != null ||
        authorErr != null ||
        genreErr != null ||
        statusErr != null ||
        ratingErr != null ||
        notesErr != null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      final int? parsedRating = _ratingController.text.trim().isNotEmpty
          ? int.tryParse(_ratingController.text.trim())
          : null;

      await bookProvider.addBook(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        genre: _selectedGenre,
        status: _selectedStatus,
        rating: parsedRating,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      // Form cleared on success
      _titleController.clear();
      _authorController.clear();
      _ratingController.clear();
      _notesController.clear();
      setState(() {
        _selectedGenre = AppConstants.genreChoose;
        _selectedStatus = AppConstants.statusChoose;
        _submitted = false;
        _isSubmitting = false;
        _successMessage = AppConstants.msgBookAdded;
        _firestoreError = null;
      });

      widget.onBookAdded?.call();
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        // Show Firestore error on the form
        _firestoreError = e.toString().replaceFirst(RegExp(r'^\[.*?\]\s*'), '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic validation errors shown only after first submit
    final titleError = _submitted ? FormValidators.validateTitle(_titleController.text) : null;
    final authorError = _submitted ? FormValidators.validateAuthor(_authorController.text) : null;
    final genreError = _submitted ? FormValidators.validateGenre(_selectedGenre) : null;
    final statusError = _submitted ? FormValidators.validateStatus(_selectedStatus) : null;
    final ratingError = _submitted ? FormValidators.validateRating(_ratingController.text) : null;
    final notesError = _submitted ? FormValidators.validateNotes(_notesController.text) : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Add a Book',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Title
          AppTextField(
            controller: _titleController,
            label: 'Title',
            hintText: 'Enter book title',
            errorText: titleError,
            onChanged: (_) {
              if (_submitted) setState(() {});
            },
          ),
          const SizedBox(height: 12),

          // Author
          AppTextField(
            controller: _authorController,
            label: 'Author',
            hintText: 'Enter author name',
            errorText: authorError,
            onChanged: (_) {
              if (_submitted) setState(() {});
            },
          ),
          const SizedBox(height: 12),

          // Genre Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Genre',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                key: ValueKey('genre_$_selectedGenre'),
                initialValue: _selectedGenre,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: genreError != null ? AppConstants.errorColor : const Color(0xFFD1D5DB),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: genreError != null ? AppConstants.errorColor : const Color(0xFFD1D5DB),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppConstants.primaryColor,
                      width: 1.8,
                    ),
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                    value: AppConstants.genreChoose,
                    child: Text(
                      AppConstants.genreChoose,
                      style: TextStyle(color: AppConstants.textSecondary),
                    ),
                  ),
                  ...AppConstants.genres.map(
                    (g) => DropdownMenuItem(value: g, child: Text(g)),
                  ),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedGenre = val ?? AppConstants.genreChoose;
                  });
                },
              ),
              if (genreError != null) ...[
                const SizedBox(height: 4),
                Text(
                  genreError,
                  style: const TextStyle(
                    color: AppConstants.errorColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Status Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                key: ValueKey('status_$_selectedStatus'),
                initialValue: _selectedStatus,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: statusError != null ? AppConstants.errorColor : const Color(0xFFD1D5DB),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: statusError != null ? AppConstants.errorColor : const Color(0xFFD1D5DB),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppConstants.primaryColor,
                      width: 1.8,
                    ),
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                    value: AppConstants.statusChoose,
                    child: Text(
                      AppConstants.statusChoose,
                      style: TextStyle(color: AppConstants.textSecondary),
                    ),
                  ),
                  ...AppConstants.statuses.map(
                    (s) => DropdownMenuItem(value: s, child: Text(s)),
                  ),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedStatus = val ?? AppConstants.statusChoose;
                  });
                },
              ),
              if (statusError != null) ...[
                const SizedBox(height: 4),
                Text(
                  statusError,
                  style: const TextStyle(
                    color: AppConstants.errorColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Rating (Optional: 0 to 5)
          AppTextField(
            controller: _ratingController,
            label: 'Rating (optional, 0 to 5)',
            hintText: 'e.g. 5',
            keyboardType: TextInputType.number,
            errorText: ratingError,
            onChanged: (_) {
              if (_submitted) setState(() {});
            },
          ),
          const SizedBox(height: 12),

          // Notes (Optional: up to 300 characters)
          AppTextField(
            controller: _notesController,
            label: 'Notes (optional)',
            hintText: 'Add personal notes about this book...',
            maxLines: 3,
            errorText: notesError,
            onChanged: (_) {
              if (_submitted) setState(() {});
            },
          ),
          const SizedBox(height: 16),

          // Submit Button
          SizedBox(
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: _isSubmitting ? null : _submitForm,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Add Book',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
            ),
          ),

          // Success Message
          if (_successMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppConstants.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppConstants.successColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppConstants.successColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    _successMessage!,
                    style: const TextStyle(
                      color: AppConstants.successColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Firestore Error Message
          if (_firestoreError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppConstants.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppConstants.errorColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, color: AppConstants.errorColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _firestoreError!,
                      style: const TextStyle(
                        color: AppConstants.errorColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
