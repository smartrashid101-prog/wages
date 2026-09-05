import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wages/shared/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'package:wages/features/auth/screens/register_screen.dart';
import 'package:wages/features/auth/screens/splash_screen.dart';
import 'package:wages/features/main_screen.dart';
import 'package:wages/features/auth/screens/otp_reset_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  const String supabaseUrl = 'https://uddrxunlrrhhzflugmtw.supabase.co';
  const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkZHJ4dW5scnJoaHpmbHVnbXR3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgyNTg5MTgsImV4cCI6MjEwMzgzNDkxOH0.EqmneiT24lCisXdXTW_POPaClEr97YZw7aOg95rZKHc';
  
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseAnonKey,
  );
  
  runApp(const ProviderScope(child: WagesApp()));
}

class WagesApp extends ConsumerWidget {
  const WagesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return MaterialApp(
      title: 'WAGES',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF081b4b),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF081b4b),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const MainScreen();
          }
          return const LoginScreen();
        },
        loading: () => const SplashScreen(),
        error: (_, __) => const LoginScreen(),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/otp-reset-password': (context) => const OTPResetPasswordScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}