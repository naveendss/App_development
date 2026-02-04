import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/vendor_login_screen.dart';
import '../../features/auth/presentation/vendor_register_screen.dart';
import '../../features/auth/presentation/onboarding_success_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/scanner/presentation/qr_scanner_screen.dart';
import '../../features/scanner/presentation/check_in_success_screen.dart';
import '../../features/members/presentation/members_list_screen.dart';
import '../../features/members/presentation/member_detail_screen.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/community/presentation/community_feed_screen.dart';
import '../../features/community/presentation/create_post_screen.dart';
import '../../features/gym_management/presentation/slot_management_screen.dart';
import '../../features/gym_management/presentation/slot_management_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const VendorLoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const VendorRegisterScreen(),
      ),
      GoRoute(
        path: '/onboarding-success',
        name: 'onboarding-success',
        builder: (context, state) => const OnboardingSuccessScreen(),
      ),
      
      // Dashboard
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      
      // Scanner
      GoRoute(
        path: '/scanner',
        name: 'scanner',
        builder: (context, state) => const QRScannerScreen(),
      ),
      GoRoute(
        path: '/check-in-success',
        name: 'check-in-success',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return CheckInSuccessScreen(checkInData: data);
        },
      ),
      
      // Members
      GoRoute(
        path: '/members',
        name: 'members',
        builder: (context, state) => const MembersListScreen(),
      ),
      GoRoute(
        path: '/member-detail/:id',
        name: 'member-detail',
        builder: (context, state) {
          final memberId = state.pathParameters['id'] ?? '';
          return MemberDetailScreen(memberId: memberId);
        },
      ),
      
      // Analytics
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      
      // Community
      GoRoute(
        path: '/community',
        name: 'community',
        builder: (context, state) => const CommunityFeedScreen(),
      ),
      GoRoute(
        path: '/community/create-post',
        name: 'create-post',
        builder: (context, state) => const CreatePostScreen(),
      ),
      
      // Slot Management
      GoRoute(
        path: '/slot-management',
        name: 'slot-management',
        builder: (context, state) => const SlotManagementScreen(),
      ),
      GoRoute(
        path: '/slot-management-detail',
        name: 'slot-management-detail',
        builder: (context, state) {
          final equipmentName = state.extra as String? ?? 'Equipment';
          return SlotManagementDetailScreen(equipmentName: equipmentName);
        },
      ),
    ],
  );
});
