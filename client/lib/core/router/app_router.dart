import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/onboarding/presentation/physical_details_screen.dart';
import '../../features/onboarding/presentation/complete_profile_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/gym/presentation/gym_listing_screen.dart';
import '../../features/gym/presentation/gym_detail_screen.dart';
import '../../features/gym/presentation/equipment_list_screen.dart';
import '../../features/booking/presentation/slot_selection_screen.dart';
import '../../features/booking/presentation/booking_summary_screen.dart';
import '../../features/booking/presentation/booking_success_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/my_bookings_screen.dart';
import '../../features/community/presentation/community_feed_screen.dart';
import '../../features/community/presentation/post_detail_screen.dart';
import '../../features/community/presentation/create_post_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) {
          final phoneNumber = state.extra as String? ?? '';
          return OtpScreen(phoneNumber: phoneNumber);
        },
      ),
      GoRoute(
        path: '/physical-details',
        name: 'physical-details',
        builder: (context, state) => const PhysicalDetailsScreen(),
      ),
      GoRoute(
        path: '/complete-profile',
        name: 'complete-profile',
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/gym-listing',
        name: 'gym-listing',
        builder: (context, state) {
          final category = state.extra as String? ?? 'All Equipment';
          return GymListingScreen(category: category);
        },
      ),
      GoRoute(
        path: '/gym-detail/:id',
        name: 'gym-detail',
        builder: (context, state) {
          final gymId = state.pathParameters['id'] ?? '';
          return GymDetailScreen(gymId: gymId);
        },
      ),
      GoRoute(
        path: '/equipment-list',
        name: 'equipment-list',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return EquipmentListScreen(
            gymId: data['gymId'] ?? '',
            equipmentType: data['equipmentType'] ?? 'All Gear',
          );
        },
      ),
      GoRoute(
        path: '/slot-selection',
        name: 'slot-selection',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return SlotSelectionScreen(
            gymId: data['gymId'] ?? '',
            equipmentType: data['equipmentType'] ?? '',
            extraData: data,
          );
        },
      ),
      GoRoute(
        path: '/booking-summary',
        name: 'booking-summary',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return BookingSummaryScreen(bookingData: data);
        },
      ),
      GoRoute(
        path: '/booking-success',
        name: 'booking-success',
        builder: (context, state) {
          final bookingId = state.extra as String? ?? '';
          return BookingSuccessScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/my-bookings',
        name: 'my-bookings',
        builder: (context, state) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: '/community',
        name: 'community',
        builder: (context, state) => const CommunityFeedScreen(),
      ),
      GoRoute(
        path: '/community/post/:id',
        name: 'post-detail',
        builder: (context, state) {
          final postId = state.pathParameters['id'] ?? '';
          return PostDetailScreen(postId: postId);
        },
      ),
      GoRoute(
        path: '/community/create-post',
        name: 'create-post',
        builder: (context, state) => const CreatePostScreen(),
      ),
    ],
  );
});
