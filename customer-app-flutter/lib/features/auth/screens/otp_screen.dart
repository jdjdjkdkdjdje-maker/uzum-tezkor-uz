import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../state/auth_provider.dart';
import '../../home/screens/main_shell.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _codeController = TextEditingController();
  Timer? _resendTimer;
  int _secondsLeft = 60;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _secondsLeft = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify(String code) async {
    final auth = context.read<AuthProvider>();
    final success = await auth.verifyOtp(phoneNumber: widget.phoneNumber, code: code);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } else if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.errorMessage!)));
      _codeController.clear();
    }
  }

  Future<void> _resend() async {
    final auth = context.read<AuthProvider>();
    await auth.sendOtp(widget.phoneNumber);
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tasdiqlash kodi', style: AppTextStyles.display),
            const SizedBox(height: 8),
            Text(
              '${widget.phoneNumber} raqamiga yuborilgan 4 xonali kodni kiriting',
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 32),
            PinCodeTextField(
              appContext: context,
              length: 4,
              controller: _codeController,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              enableActiveFill: true,
              onCompleted: _verify,
              onChanged: (_) {},
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(14),
                fieldHeight: 56,
                fieldWidth: 52,
                activeColor: AppColors.tomato,
                selectedColor: AppColors.tomato,
                inactiveColor: AppColors.line,
                activeFillColor: AppColors.surface,
                selectedFillColor: AppColors.surface,
                inactiveFillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: 24),
            if (auth.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Center(
                child: _secondsLeft > 0
                    ? Text(
                        'Qayta yuborish: 0:${_secondsLeft.toString().padLeft(2, '0')}',
                        style: AppTextStyles.caption,
                      )
                    : TextButton(
                        onPressed: _resend,
                        child: const Text("Kodni qayta yuborish"),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
