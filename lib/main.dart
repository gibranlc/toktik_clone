import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- IMPORTANTE
import 'package:provider/provider.dart';

import 'package:toktik_clone/providers/user_action_provider.dart';
import 'app.dart';
import 'providers/video_feed_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga los datos de formato de fecha para el locale deseado
  await initializeDateFormatting('es_MX', null);

  // Fija el locale por defecto para intl
  Intl.defaultLocale = 'es_MX';

  runApp(const Bootstrap());
}

class Bootstrap extends StatelessWidget {
  const Bootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              VideoFeedProvider()..loadMockData(), // <= usa => no &gt;
        ),
        ChangeNotifierProvider(create: (_) => UserActionsProvider()),
      ],
      child: const TikTokApp(),
    );
  }
}
