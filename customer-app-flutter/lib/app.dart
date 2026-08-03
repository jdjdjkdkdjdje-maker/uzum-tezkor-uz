import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'state/auth_provider.dart';
import 'state/cart_provider.dart';
import 'state/location_provider.dart';
import 'features/auth/screens/splash_screen.dart';

class UzumTezkorApp extends StatelessWidget {
  const UzumTezkorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MaterialApp(
        title: 'Uzum Tezkor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('uz'),
        supportedLocales: const [Locale('uz'), Locale('ru'), Locale('en')],
        home: const SplashScreen(),
      ),
    );
  }
}
