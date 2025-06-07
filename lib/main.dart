import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uts2/pages/reminders_page.dart';
import 'pages/home.dart';
import 'pages/auth/login_page.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Supabase dengan variabel dari .env
  await Supabase.initialize(
    url: 'https://njgvjbcwudlzwtpnrqlv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5qZ3ZqYmN3dWRsend0cG5ycWx2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY3NDkyMDYsImV4cCI6MjA2MjMyNTIwNn0.Xb2DX2hV358HqfVlpAR7O9ILPJz1cy-ghFWa0sBw2Oo',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            title: 'Task Pop',
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
