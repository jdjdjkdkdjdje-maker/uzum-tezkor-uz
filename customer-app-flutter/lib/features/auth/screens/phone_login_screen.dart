import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../state/auth_provider.dart';
import 'otp_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  bool get _isValid => _phoneController.text.replaceAll(' ', '').length == 9;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final auth = context.read<AuthProvider>();
    final fullPhone = '+998${_phoneController.text.replaceAll(' ', '')}';
    final sent = await auth.sendOtp(fullPhone);
    if (!mounted) return;
    if (sent) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OtpScreen(phoneNumber: fullPhone)),
      );
    } else if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.errorMessage!)));
    }
  }

  Future<void> _socialLogin(String provider) async {
    // MUHIM: Google/Apple SDK orqali idToken olingandan so'ng shu yerga uzatiladi.
    // google_sign_in / sign_in_with_apple paketlari native tomonni boshqaradi.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider orqali kirish uchun native SDK ulanishi kerak')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text('Xush kelibsiz 👋', style: AppTextStyles.display),
              const SizedBox(height: 8),
              Text(
                'Davom etish uchun telefon raqamingizni kiriting',
                style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                ],
                style: AppTextStyles.bodyMedium,
                decoration: const InputDecoration(
                  prefixText: '+998  ',
                  hintText: '90 123 45 67',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isValid && !auth.isLoading ? _continue : null,
                child: auth.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Davom etish'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('yoki', style: AppTextStyles.caption),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _socialLogin('google'),
                icon: const Icon(Icons.g_mobiledata_rounded, size: 26),
                label: const Text('Google orqali kirish'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _socialLogin('apple'),
                icon: const Icon(Icons.apple_rounded, size: 20),
                label: const Text('Apple orqali kirish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
