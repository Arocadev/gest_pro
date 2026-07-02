import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/cobro.dart';
import 'models/material_obra.dart';
import 'models/obra.dart';
import 'models/pago.dart';
import 'models/recordatorio.dart';
import 'models/tarea.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Hive.initFlutter();

  Hive.registerAdapter(TareaAdapter());
  Hive.registerAdapter(MaterialObraAdapter());
  Hive.registerAdapter(ObraAdapter());
  Hive.registerAdapter(PagoAdapter());
  Hive.registerAdapter(CobroAdapter());
  Hive.registerAdapter(
    RecordatorioAdapter(),
  );

  await Hive.openBox<Obra>(
    StorageService.obrasBox,
  );

  await Hive.openBox<Pago>(
    StorageService.pagosBox,
  );

  await Hive.openBox<Cobro>(
    StorageService.cobrosBox,
  );

  await Hive.openBox<Recordatorio>(
    StorageService.recordatoriosBox,
  );

  await NotificationService.init();

  runApp(
    const ObraControlApp(),
  );
}

class ObraControlApp
    extends StatelessWidget {
  const ObraControlApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false,
      title: 'ObraControl',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(
          seedColor: Colors.orange,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates:
          const [
        GlobalMaterialLocalizations
            .delegate,
        GlobalWidgetsLocalizations
            .delegate,
        GlobalCupertinoLocalizations
            .delegate,
      ],
      supportedLocales: const [
        Locale('es'),
      ],
      locale: const Locale('es'),
      home: const HomeScreen(),
    );
  }
}