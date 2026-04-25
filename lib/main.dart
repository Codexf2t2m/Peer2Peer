import 'package:flutter/material.dart';

import 'app_state.dart';
import 'app_routes.dart';
import 'features/ask_kutlo/ask_kutlo_screen.dart';
import 'features/auth/reset_password/reset_password_screen.dart';
import 'features/auth/sign_in/sign_in_screen.dart';
import 'features/auth/sign_up/sign_up_screen.dart';
import 'features/community/browse/community_screen.dart';
import 'features/community/fund/community_fund_screen.dart';
import 'features/home/home_screen.dart';
import 'features/lend/lend_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/request/request_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/wallet/wallet_screen.dart';
import 'ui/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSession.instance.bootstrap();

  runApp(const MyApp());
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
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.createAccount: (_) => const CreateAccountScreen(),
        AppRoutes.resetPassword: (_) => const ResetPasswordScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.community: (_) => const CommunityScreen(),
        AppRoutes.lend: (_) => const LendScreen(),
        AppRoutes.wallet: (_) => const WalletScreen(),
        AppRoutes.request: (_) => const RequestScreen(),
        AppRoutes.askKutlo: (_) => const AskKutloScreen(),
      },
    );
  }
}
