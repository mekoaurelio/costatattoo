import 'package:costatattoo/users/usuario_lista.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'lang/translation_service.dart';
import 'service/imageUploadPage.dart';
import 'users/customerDialog.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAMrOeHeDAgOr0GkzmCtymtyoabOkLJ1Qw",//ok
      appId: "1:263500982448:android:705979c97cd46a5601b375",//ok
      messagingSenderId: "263500982448",
      projectId: "cashback-d3a89",//ok
      storageBucket: "cashback-d3a89.firebasestorage.app",
        authDomain: "cashback-d3a89.firebaseapp.com",
        measurementId: "G-VS1EV5013C"
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Costa Tattoo',
      debugShowCheckedModeBanner: false,
      locale: const Locale('en', 'AU'), // <-- Inglês (Austrália)
      fallbackLocale: const Locale('en', 'AU'), // <-- Fallback caso o idioma não seja suportado

      //locale: TranslationService.locale,
      //fallbackLocale: TranslationService.fallbackLocale,
      translations: TranslationService(),
      //supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,  ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:  CustomerList(),
    );
  }
}

