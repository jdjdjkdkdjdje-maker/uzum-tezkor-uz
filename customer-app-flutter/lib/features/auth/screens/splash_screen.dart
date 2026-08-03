import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../state/auth_provider.dart';
import '../../home/screens/main_shell.dart';
import 'phone_login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    await auth.bootstrap();
    if (!mounted) return;

    final target = auth.status == AuthStatus.authenticated
        ? const MainShell()
        : const PhoneLoginScreen();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => target),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tomato,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.bolt_rounded, color: AppColors.tomato, size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              'Uzum Tezkor',
              style: AppTextStyles.display.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              "Tezkor yetkazib berish",
              style: AppTextStyles.body.copyWith(color: Colors.white.withOpacity(0.85)),
            ),
          ],
        ),
      ),
    );
  }
}
