import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_routes.dart';
import 'data/providers/session_provider.dart';
import 'ui/ask_kutlo/widgets/ask_kutlo_screen.dart';
import 'ui/auth/reset_password/widgets/reset_password_screen.dart';
import 'ui/auth/sign_in/widgets/sign_in_screen.dart';
import 'ui/auth/sign_up/widgets/sign_up_screen.dart';
import 'ui/community/browse/widgets/community_screen.dart';
import 'ui/community/fund/widgets/community_fund_screen.dart';
import 'ui/home/widgets/home_screen.dart';
import 'ui/lend/widgets/lend_screen.dart';
import 'ui/loans/widgets/active_loans_screen.dart';
import 'ui/onboarding/bank_connect/widgets/bank_connect_screen.dart';
import 'ui/onboarding/credit_assessment/widgets/credit_assessment_screen.dart';
import 'ui/onboarding/email_verification/widgets/email_verification_screen.dart';
import 'ui/onboarding/kyc_upload/widgets/kyc_upload_screen.dart';
import 'ui/complaints/widgets/complaint_screen.dart';
import 'ui/profile/widgets/profile_screen.dart';
import 'ui/request/widgets/request_screen.dart';
import 'ui/splash/widgets/splash_screen.dart';
import 'ui/wallet/widgets/wallet_screen.dart';
import 'ui/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Supabase must be initialized BEFORE any provider reads
  // Supabase.instance.client (supabaseClientProvider does exactly that).
  // SessionNotifier.bootstrap() only loads dotenv and checks
  // currentUser — it does NOT call Supabase.initialize() itself,
  // so that step has to happen here in main() first.
  bool supabaseEnabled = false;
  try {
    await dotenv.load(fileName: '.env');
    final url = dotenv.env['SUPABASE_URL']?.trim() ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';
    final hasValidUrl = Uri.tryParse(url)?.hasAbsolutePath ?? false;

    if (url.isNotEmpty && anonKey.isNotEmpty && hasValidUrl) {
      await Supabase.initialize(url: url, anonKey: anonKey);
      supabaseEnabled = true;
    }
  } catch (_) {
    // .env missing or malformed — fall through to demo mode.
    supabaseEnabled = false;
  }

  final container = ProviderContainer();

  // Only call bootstrap (which reads Supabase.instance.client via
  // supabaseClientProvider) once initialization above has actually run.
  // If Supabase was never enabled, bootstrap() will detect that itself
  // via its own dotenv checks and fall back to demo mode without
  // touching Supabase.instance.
  if (supabaseEnabled) {
    await container.read(sessionProvider.notifier).bootstrap();
  }

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
        if (settings.name == AppRoutes.communityFund) {
          // loanRequestId is passed as the route argument from the
          // community browse screen's Navigator.pushNamed call.
          final loanRequestId = settings.arguments as String? ?? '';
          return MaterialPageRoute<void>(
            builder: (_) => CommunityFundScreen(
              loanRequestId: loanRequestId,
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