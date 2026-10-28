import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/book_provider.dart';
import '../utils/constants.dart';
import '../widgets/add_book_form.dart';
import '../widgets/book_card.dart';
import '../widgets/filter_section.dart';
import '../widgets/summary_section.dart';
import 'auth_gate.dart';
import 'detail_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  bool _isAddBookExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final bookProvider = Provider.of<BookProvider>(context, listen: false);
        final uid = authProvider.user?.uid ?? FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          bookProvider.setUserId(uid);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookProvider = Provider.of<BookProvider>(context);
    final user = authProvider.user;

    // PopScope prevents phone's Back button from returning to Login or Register
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false, // No back arrow to login/register
          backgroundColor: AppConstants.primaryColor,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (user != null && user.email != null)
                Text(
                  user.email!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFFE2E8F0),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          actions: [
            // Logout Button
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text(
                AppConstants.logout,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              onPressed: () async {
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthGate()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
        body: SafeArea(
          child: bookProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppConstants.primaryColor),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Section A: Add a Book toggle/accordion
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'My Bookshelf',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textPrimary,
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isAddBookExpanded
                                  ? const Color(0xFF64748B)
                                  : AppConstants.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            icon: Icon(
                              _isAddBookExpanded ? Icons.close : Icons.add,
                              size: 18,
                            ),
                            label: Text(
                              _isAddBookExpanded ? 'Close Form' : 'Add Book',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _isAddBookExpanded = !_isAddBookExpanded;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Add Book Form
                      if (_isAddBookExpanded) ...[
                        AddBookForm(
                          onBookAdded: () {
                            // Keep form open or leave it as preferred; user can add multiple books
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Section C: Filter, Search & Summary
                      const FilterSection(),
                      const SizedBox(height: 12),
                      const SummarySection(),
                      const SizedBox(height: 16),

                      // Section B: The List
                      const Text(
                        'Book Collection',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Books List or Empty State
                      if (bookProvider.filteredBooks.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: Color(0xFF9CA3AF),
                              ),
                              SizedBox(height: 12),
                              Text(
                                AppConstants.noBooksFound,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppConstants.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: bookProvider.filteredBooks.length,
                          itemBuilder: (context, index) {
                            final book = bookProvider.filteredBooks[index];
                            return BookCard(
                              book: book,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DetailScreen(book: book),
                                  ),
                                );
                              },
                              onToggleFavorite: () {
                                bookProvider.toggleFavorite(book.id, book.favorite);
                              },
                            );
                          },
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
