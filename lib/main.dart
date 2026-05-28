import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'l10n/app_strings.dart';
import 'l10n/locale_notifier.dart';
import 'screens/home_screen.dart';
import 'services/database.dart';
import 'services/seed.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await Db.instance.database;
  await Seeder.seedIfEmpty();

  final localeNotifier = await LocaleNotifier.load();

  runApp(
    ChangeNotifierProvider.value(
      value: localeNotifier,
      child: const LingoCodeApp(),
    ),
  );
}

class LingoCodeApp extends StatelessWidget {
  const LingoCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<LocaleNotifier>();
    return MaterialApp(
      title: 'LingoCode',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      locale: notifier.locale,
      supportedLocales: AppStrings.supported,
      builder: (context, child) {
        return AppStrings(
          locale: notifier.locale,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomeScreen(),
    );
  }
}
