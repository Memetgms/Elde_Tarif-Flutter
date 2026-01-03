import 'package:elde_tarif/Providers/tarif_detay_provider.dart';
import 'package:elde_tarif/Providers/home_provider.dart';
import 'package:elde_tarif/Providers/ai_provider.dart';
import 'package:elde_tarif/Providers/favorites_provider.dart';
import 'package:elde_tarif/screens/HomePage.dart';
import 'package:elde_tarif/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elde_tarif/Providers/malzeme_provider.dart';
import 'package:elde_tarif/screens/AuthenticationPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EldeTarifApp());
}

class EldeTarifApp extends StatelessWidget {
  const EldeTarifApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => MalzemeProvider()),
        ChangeNotifierProvider(create: (_) => TarifDetayProvider()),
        ChangeNotifierProvider(create: (_) => AiProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Elde Tarif',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        home: const SplashScreen(),

        routes: {
          '/auth': (context) => const AuthenticationPage(),
        },
      ),
    );
  }
}