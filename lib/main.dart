import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/cobro.dart';
import 'models/evento_calendario.dart';
import 'models/material_proyecto.dart';
import 'models/proyecto.dart';
import 'models/pago.dart';
import 'models/tarea.dart';
import 'screens/splash_screen.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Hive.initFlutter();

  Hive.registerAdapter(TareaAdapter());
  Hive.registerAdapter(MaterialProyectoAdapter());
  Hive.registerAdapter(ProyectoAdapter());
  Hive.registerAdapter(PagoAdapter());
  Hive.registerAdapter(CobroAdapter());
  Hive.registerAdapter(EventoCalendarioAdapter());

  await Hive.openBox<Proyecto>(StorageService.proyectosBox);
  await Hive.openBox<Pago>(StorageService.pagosBox);
  await Hive.openBox<Cobro>(StorageService.cobrosBox);
  await Hive.openBox<EventoCalendario>('eventos_libres');

  runApp(const GestProApp());
}

class GestProApp extends StatelessWidget {
  const GestProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GestPro',
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E86AB)),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es')],
      locale: const Locale('es'),
      home: const SplashScreen(),
    );
  }
}