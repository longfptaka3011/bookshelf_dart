import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../utils/constants.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onToggleFavorite,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusToRead:
        return const Color(0xFF3B82F6); // Blue
      case AppConstants.statusReading:
        return const Color(0xFFF59E0B); // Amber
      case AppConstants.statusFinished:
        return const Color(0xFF10B981); // Emerald
      default:
        return AppConstants.textSecondary;
    }
  }

  Color _getGenreColor(String genre) {
    switch (genre) {
      case AppConstants.genreFiction:
        return const Color(0xFF8B5CF6);
      case AppConstants.genreNonFiction:
        return const Color(0xFF06B6D4);
      case AppConstants.genreAcademic:
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      // Author
                      Text(
                        'by ${book.author}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppConstants.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Badges: Genre & Status
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _getGenreColor(book.genre).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              book.genre,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getGenreColor(book.genre),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(book.status).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              book.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(book.status),
                              ),
                            ),
                          ),
                          if (book.rating != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 12,
                                    color: AppConstants.favoriteGold,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${book.rating}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Favorite Toggle Star
                IconButton(
                  icon: Icon(
                    book.favorite ? Icons.star : Icons.star_border,
                    color: book.favorite
                        ? AppConstants.favoriteGold
                        : const Color(0xFF9CA3AF),
                    size: 26,
                  ),
                  tooltip: book.favorite ? 'Remove favorite' : 'Add favorite',
                  onPressed: onToggleFavorite,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
