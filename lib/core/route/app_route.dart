import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../animations/page_transitions.dart';
import '../../features/authentication/screens/splash_screen.dart';
import '../../features/authentication/screens/onboarding_screen.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/authentication/screens/otp_screen.dart';
import '../../features/authentication/screens/forgot_password_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/buy_rp/screens/buy_rp_screen.dart';
import '../../features/sell_rp/screens/sell_rp_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/bind_payment_screen.dart';
import '../../features/profile/screens/faq_screen.dart';
import '../../features/profile/screens/account_security_screen.dart';
import '../../features/daily_details/screens/daily_details_screen.dart';
import '../../features/referral/screens/team_screen.dart';
import '../../features/referral/screens/invite_screen.dart';
import '../../features/rewards/screens/newbie_rewards_screen.dart';
import '../../features/transactions/screens/transaction_history_screen.dart';
import '../../features/notification/screens/notification_screen.dart';
import '../../shared/widgets/main_shell.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorHome = GlobalKey<NavigatorState>(
  debugLabel: 'shellHome',
);
final GlobalKey<NavigatorState> _shellNavigatorBuyRp =
    GlobalKey<NavigatorState>(debugLabel: 'shellBuyRp');
final GlobalKey<NavigatorState> _shellNavigatorSellRp =
    GlobalKey<NavigatorState>(debugLabel: 'shellSellRp');
final GlobalKey<NavigatorState> _shellNavigatorProfile =
    GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // Splash Route
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),

    // Onboarding Route
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => PageTransitions.fade(
        context: context,
        state: state,
        child: const OnboardingScreen(),
      ),
    ),

    // Authentication Routes
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => PageTransitions.fade(
        context: context,
        state: state,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/forgot-password',
      pageBuilder: (context, state) => PageTransitions.slideRight(
        context: context,
        state: state,
        child: const ForgotPasswordScreen(),
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => PageTransitions.slideRight(
        context: context,
        state: state,
        child: const RegisterScreen(),
      ),
    ),
    GoRoute(
      path: '/otp',
      pageBuilder: (context, state) {
        String? mobile;
        String? email;
        String? password;
        String? invite;
        if (state.extra is Map<String, dynamic>) {
          final map = state.extra as Map<String, dynamic>;
          mobile = map['mobile'] as String?;
          email = map['email'] as String?;
          password = map['password'] as String?;
          invite = map['invite'] as String?;
        } else if (state.extra is String) {
          mobile = state.extra as String;
        }
        return PageTransitions.slideRight(
          context: context,
          state: state,
          child: OtpScreen(
            mobile: mobile,
            email: email,
            password: password,
            invite: invite,
          ),
        );
      },
    ),

    // Bottom Navigation Shell (Home, Buy RP, Sell RP, Mine)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Home
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHome,
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: HomeScreen()),
            ),
          ],
        ),

        // Tab 2: Buy RP
        StatefulShellBranch(
          navigatorKey: _shellNavigatorBuyRp,
          routes: [
            GoRoute(
              path: '/buy-rp',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: BuyRpScreen()),
            ),
          ],
        ),

        // Tab 3: Sell RP
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSellRp,
          routes: [
            GoRoute(
              path: '/sell-rp',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: SellRpScreen()),
            ),
          ],
        ),

        // Tab 4: Mine (Profile)
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProfile,
          routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ProfileScreen()),
            ),
          ],
        ),
      ],
    ),

    // Nested Feature Screens (Full screen with back button)
    GoRoute(
      path: '/daily-details',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => PageTransitions.slideRight(
        context: context,
        state: state,
        child: const DailyDetailsScreen(),
      ),
    ),
    GoRoute(
      path: '/bind-payment',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => PageTransitions.slideRight(
        context: context,
        state: state,
        child: const BindPaymentScreen(),
      ),
    ),
    GoRoute(
      path: '/faq',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => PageTransitions.slideRight(
        context: context,
        state: state,
        child: const FaqScreen(),
      ),
    ),
    GoRoute(
      path: '/account-security',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => PageTransitions.slideRight(
        context: context,
        state: state,
        child: const AccountSecurityScreen(),
      ),
    ),
    GoRoute(
      path: '/team',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => PageTransitions.slideRight(
        context: context,
        state: state,
        child: const TeamScreen(),
      ),
    ),
    GoRoute(
      path: '/invite',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => PageTransitions.slideRight(
        context: context,
        state: state,
        child: const InviteScreen(),
      ),
    ),
    GoRoute(
      path: '/newbie-rewards',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => PageTransitions.slideRight(
        context: context,
        state: state,
        child: const NewbieRewardsScreen(),
      ),
    ),
    GoRoute(
      path: '/transactions',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => PageTransitions.slideRight(
        context: context,
        state: state,
        child: const TransactionHistoryScreen(),
      ),
    ),
    GoRoute(
      path: '/notifications',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => PageTransitions.slideRight(
        context: context,
        state: state,
        child: const NotificationScreen(),
      ),
    ),
  ],
);
