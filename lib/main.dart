import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/reels_provider.dart';
import 'providers/connectivity_provider.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final authProvider = AuthProvider();
  final reelsProvider = ReelsProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: reelsProvider),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: const QicTokPro(),
    ),
  );
}

class QicTokPro extends StatelessWidget {
  const QicTokPro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QicTok Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigation(),
    );
  }
}
