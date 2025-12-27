import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'config/routes/app_router.dart';
import 'config/theme/app_theme.dart';
import 'config/theme/theme_provider.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configura Google Fonts - permette fetching runtime per evitare crash
  GoogleFonts.config.allowRuntimeFetching = true;

  // Imposta l'orientamento preferito
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Stile della barra di stato
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: CorpoSostenibileApp(),
    ),
  );
}

/// Widget principale dell'applicazione Corpo Sostenibile.
/// Configura il tema, il routing e i provider Riverpod.
class CorpoSostenibileApp extends ConsumerWidget {
  const CorpoSostenibileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Configurazione tema
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode.toThemeMode(),

      // Configurazione routing
      routerConfig: router,
    );
  }
}
