import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Premium immersion: match system bar colors to app dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF070B18),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Ensure GoogleFonts runtime fetching is safely configured
  GoogleFonts.config.allowRuntimeFetching = true;

  runApp(
    const ProviderScope(
      child: QuickMoneyApp(),
    ),
  );
}

