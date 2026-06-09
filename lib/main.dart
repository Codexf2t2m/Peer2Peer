import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_state.dart';
import 'app_routes.dart';
import 'data/providers/session_provider.dart';
import 'ui/ask_kutlo/ask_kutlo_screen.dart';
import 'ui/auth/reset_password/widgets/reset_password_screen.dart';
import 'ui/auth/sign_in/widgets/sign_in_screen.dart';
import 'ui/auth/sign_up/widgets/sign_up_screen.dart';
import 'ui/community/browse/community_screen.dart';
import 'ui/community/fund/community_fund_screen.dart';
import 'ui/home/widgets/home_screen.dart';
import 'ui/lend/widgets/lend_screen.dart';
import 'ui/loans/widget/active_loans_screen.dart';
import 'ui/onboarding/bank_connect_screen.dart';
import 'ui/onboarding/credit_assessment_screen.dart';
import 'ui/onboarding/email_verification_screen.dart';
import 'ui/onboarding/kyc_upload_screen.dart';
import 'ui/complaints/complaint_screen.dart';
import 'ui/profile/widgets/profile_screen.dart';
import 'ui/request/widgets/request_screen.dart';
import 'ui/splash/widget/splash_screen.dart';
import 'ui/wallet/widgets/wallet_screen.dart';
import 'ui/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  await container.read(sessionProvider.notifier).bootstrap();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pula Pay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) {
        // Routes that require arguments
        if (settings.name == AppRoutes.communityFund) {
          return MaterialPageRoute<void>(
            builder: (_) => CommunityFundScreen(
              memberId: settings.arguments as String?,
            ),
            settings: settings,
          );
        }
        return null;
      },
      routes: {
        // Core
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.createAccount: (_) => const CreateAccountScreen(),
        AppRoutes.resetPassword: (_) => const ResetPasswordScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),

        // Main features
        AppRoutes.community: (_) => const CommunityScreen(),
        AppRoutes.lend: (_) => const LendScreen(),
        AppRoutes.wallet: (_) => const WalletScreen(),
        AppRoutes.request: (_) => const RequestScreen(),
        AppRoutes.askKutlo: (_) => const AskKutloScreen(),

        // Onboarding flow
        AppRoutes.emailVerification: (_) => const EmailVerificationScreen(),
        AppRoutes.bankConnect: (_) => const BankConnectScreen(),
        AppRoutes.kycUpload: (_) => const KycUploadScreen(),
        AppRoutes.creditAssessment: (_) => const CreditAssessmentScreen(),

        // Additional feature screens
        AppRoutes.activeLoans: (_) => const ActiveLoansScreen(),
        AppRoutes.complaint: (_) => const ComplaintScreen(),
      },
    );
  }
}
