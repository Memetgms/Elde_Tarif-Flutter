import 'package:elde_tarif/Providers/tarif_detay_provider.dart';
import 'package:elde_tarif/Providers/home_provider.dart';
import 'package:elde_tarif/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elde_tarif/Providers/malzeme_provider.dart';
import 'package:elde_tarif/screens/HomePage.dart';

void main() {
  runApp(const EldeTarifApp());
}

class EldeTarifApp extends StatelessWidget {
  const EldeTarifApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider(ApiService())),
        ChangeNotifierProvider(create: (_) => MalzemeProvider(ApiService())),
        ChangeNotifierProvider(create: (_) => TarifDetayProvider(ApiService())),
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
        home: const Homepage(), // bottom nav burada
      ),
    );
  }
}
