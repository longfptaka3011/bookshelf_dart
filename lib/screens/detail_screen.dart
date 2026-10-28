import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../providers/book_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/app_text_field.dart';

class DetailScreen extends StatefulWidget {
  final BookModel book;

  const DetailScreen({super.key, required this.book});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late BookModel _currentBook;
  bool _isEditing = false;
  bool _submitted = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  String? _updateError;

  // Edit Controllers
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _ratingController;
  late TextEditingController _notesController;
  late String _selectedGenre;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _currentBook = widget.book;
    _initControllers();
  }

  void _initControllers() {
    _titleController = TextEditingController(text: _currentBook.title);
    _authorController = TextEditingController(text: _currentBook.author);
    _ratingController = TextEditingController(
      text: _currentBook.rating != null ? '${_currentBook.rating}' : '',
    );
    _notesController = TextEditingController(text: _currentBook.notes ?? '');
    _selectedGenre = _currentBook.genre;
    _selectedStatus = _currentBook.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _ratingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _toggleFavorite() async {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final newFavorite = !_currentBook.favorite;
    setState(() {
      _currentBook = _currentBook.copyWith(favorite: newFavorite);
    });
    await bookProvider.toggleFavorite(_currentBook.id, !newFavorite);
  }

  void _startEditing() {
    setState(() {
      _initControllers();
      _isEditing = true;
      _submitted = false;
      _updateError = null;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _submitted = false;
      _updateError = null;
    });
  }

  void _saveEdits() async {
    setState(() {
      _submitted = true;
      _updateError = null;
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
      _isSaving = true;
    });

    try {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      final int? parsedRating = _ratingController.text.trim().isNotEmpty
          ? int.tryParse(_ratingController.text.trim())
          : null;

      await bookProvider.updateBook(
        bookId: _currentBook.id,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        genre: _selectedGenre,
        status: _selectedStatus,
        rating: parsedRating,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      setState(() {
        _currentBook = _currentBook.copyWith(
          title: _titleController.text.trim(),
          author: _authorController.text.trim(),
          genre: _selectedGenre,
          status: _selectedStatus,
          rating: parsedRating,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );
        _isEditing = false;
        _isSaving = false;
        _submitted = false;
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
        _updateError = e.toString().replaceFirst(RegExp(r'^\[.*?\]\s*'), '');
      });
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Book'),
          content: Text(
            'Are you sure you want to delete "${_currentBook.title}" by ${_currentBook.author}?',
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.errorColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog
                _performDelete();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _performDelete() async {
    setState(() {
      _isDeleting = true;
    });

    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    await bookProvider.deleteBook(_currentBook.id);

    if (mounted) {
      Navigator.of(context).pop(); // Return to ListScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Book' : 'Book Details',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        actions: [
          // Favorite Star Toggle in AppBar
          IconButton(
            icon: Icon(
              _currentBook.favorite ? Icons.star : Icons.star_border,
              color: _currentBook.favorite ? AppConstants.favoriteGold : Colors.white,
              size: 26,
            ),
            tooltip: _currentBook.favorite ? 'Remove favorite' : 'Add favorite',
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SafeArea(
        child: _isDeleting
            ? const Center(
                child: CircularProgressIndicator(color: AppConstants.primaryColor),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: _isEditing ? _buildEditMode() : _buildViewMode(),
              ),
      ),
    );
  }

  // 1. VIEW MODE
  Widget _buildViewMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main Details Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Favorite
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _currentBook.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                  if (_currentBook.favorite)
                    const Icon(
                      Icons.star,
                      color: AppConstants.favoriteGold,
                      size: 28,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              // Author
              Text(
                'by ${_currentBook.author}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppConstants.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 14),

              // Key-Value Rows
              _buildDetailRow('Genre', _currentBook.genre, Icons.category_outlined),
              const SizedBox(height: 14),
              _buildDetailRow('Status', _currentBook.status, Icons.track_changes_outlined),
              const SizedBox(height: 14),
              _buildDetailRow(
                'Rating',
                _currentBook.rating != null ? '${_currentBook.rating} / 5' : 'Not rated',
                Icons.star_outline,
              ),
              const SizedBox(height: 14),
              _buildDetailRow(
                'Favorite',
                _currentBook.favorite ? 'Yes' : 'No',
                Icons.favorite_outline,
              ),

              if (_currentBook.notes != null && _currentBook.notes!.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 14),
                const Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _currentBook.notes!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppConstants.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Actions: Edit and Delete Buttons
        Row(
          children: [
            // Edit Button
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text(
                    'Edit',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _startEditing,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Delete Button
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.errorColor,
                    side: const BorderSide(color: AppConstants.errorColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text(
                    'Delete',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _confirmDelete,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppConstants.textSecondary),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppConstants.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  // 2. EDIT MODE
  Widget _buildEditMode() {
    final titleError = _submitted ? FormValidators.validateTitle(_titleController.text) : null;
    final authorError = _submitted ? FormValidators.validateAuthor(_authorController.text) : null;
    final genreError = _submitted ? FormValidators.validateGenre(_selectedGenre) : null;
    final statusError = _submitted ? FormValidators.validateStatus(_selectedStatus) : null;
    final ratingError = _submitted ? FormValidators.validateRating(_ratingController.text) : null;
    final notesError = _submitted ? FormValidators.validateNotes(_notesController.text) : null;

    return Container(
      padding: const EdgeInsets.all(18),
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
            'Edit Book Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          AppTextField(
            controller: _titleController,
            label: 'Title',
            hintText: 'Enter title',
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
            hintText: 'Enter author',
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
                key: ValueKey('edit_genre_$_selectedGenre'),
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
                key: ValueKey('edit_status_$_selectedStatus'),
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

          // Rating
          AppTextField(
            controller: _ratingController,
            label: 'Rating (optional, 0 to 5)',
            hintText: 'e.g. 4',
            keyboardType: TextInputType.number,
            errorText: ratingError,
            onChanged: (_) {
              if (_submitted) setState(() {});
            },
          ),
          const SizedBox(height: 12),

          // Notes
          AppTextField(
            controller: _notesController,
            label: 'Notes (optional)',
            hintText: 'Add notes...',
            maxLines: 3,
            errorText: notesError,
            onChanged: (_) {
              if (_submitted) setState(() {});
            },
          ),
          const SizedBox(height: 16),

          // Firestore Update Error
          if (_updateError != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppConstants.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppConstants.errorColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppConstants.errorColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _updateError!,
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

          // Action Buttons: Save and Cancel
          Row(
            children: [
              // Save Button
              Expanded(
                child: SizedBox(
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
                    onPressed: _isSaving ? null : _saveEdits,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Cancel Button
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.textSecondary,
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _cancelEditing,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
