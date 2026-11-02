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
      pageBuilder: (context, state) => PageTransitions.slideRight(
        context: context,
        state: state,
        child: OtpScreen(mobile: state.extra as String?),
      ),
    ),

    // Bottom Navigation Shell (Home, Buy RP, Sell RP, Mine)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) => PageTransitions.fade(
                context: context,
                state: state,
                child: const HomeScreen(),
              ),
            ),
          ],
        ),

        // Tab 2: Buy RP
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/buy-rp',
              pageBuilder: (context, state) => PageTransitions.fade(
                context: context,
                state: state,
                child: const BuyRpScreen(),
              ),
            ),
          ],
        ),

        // Tab 3: Sell RP
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/sell-rp',
              pageBuilder: (context, state) => PageTransitions.fade(
                context: context,
                state: state,
                child: const SellRpScreen(),
              ),
            ),
          ],
        ),

        // Tab 4: Mine (Profile)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => PageTransitions.fade(
                context: context,
                state: state,
                child: const ProfileScreen(),
              ),
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
