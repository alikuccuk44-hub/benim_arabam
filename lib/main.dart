import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'services/notification_service.dart';
import 'screens/main_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await NotificationService().init();
  await initializeDateFormatting('tr_TR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()..loadData()),
      ],
      child: MaterialApp(
        title: 'Benim Arabam',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1E293B),
            selectedItemColor: Color(0xFF38BDF8),
            unselectedItemColor: Colors.grey,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E293B),
            elevation: 0,
            centerTitle: true,
          ),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF38BDF8),
            secondary: Color(0xFF818CF8),
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}
