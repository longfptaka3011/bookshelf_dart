import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/feature_card.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          AppConstants.appName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        actions: [
          // Login button
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text(
              AppConstants.login,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          // Register button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text(
                AppConstants.register,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero section
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 64,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // App Title text
              const Center(
                child: Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppConstants.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Short description of the app
              const Center(
                child: Text(
                  AppConstants.appDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppConstants.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Feature Cards Section
              const Text(
                'Features',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

              // Card 1: Track your books
              const FeatureCard(
                icon: Icons.bookmark_added_rounded,
                title: AppConstants.featureTrackBooks,
                description:
                    'Maintain your private collection of books with author details, personal notes, and individual ratings.',
              ),

              // Card 2: Sort by status
              const FeatureCard(
                icon: Icons.filter_list_rounded,
                title: AppConstants.featureSortStatus,
                description:
                    'Organize reading flow smoothly across To Read, Reading, and Finished categories with instant breakdown.',
              ),

              // Card 3: Rate your favorites
              const FeatureCard(
                icon: Icons.star_rounded,
                title: AppConstants.featureRateFavorites,
                description:
                    'Star your top choices and filter favorites instantly anytime you want a quick review.',
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
