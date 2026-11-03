import 'package:flutter/material.dart';
import 'app/di/injection.dart' as di;
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/stores/auth_store.dart';
import 'features/pos/presentation/screens/pos_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initInjections();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authStore = di.sl<AuthStore>();

    return MaterialApp(
      title: 'POS Cross Platform CV & ABC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: authStore.checkAuthStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Jika token masih valid di SharedPreferences -> Langsung ke Dashboard
          if (authStore.isAuthenticated) {
            return const PosDashboardScreen();
          }

          // Jika belum login -> Ke LoginScreen
          return const LoginScreen();
        },
      ),
    );
  }
}