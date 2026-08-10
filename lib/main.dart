import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/provider_detail_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/tracking_screen.dart';
import 'models/models.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init — descomente quando configurar o Firebase
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await NotificationService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider()..init(),
      child: const ZeloApp(),
    ),
  );
}

class ZeloApp extends StatelessWidget {
  const ZeloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zelo',
      theme: ZeloTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/search':
            return MaterialPageRoute(builder: (_) => const SearchScreen());
          case '/provider':
            return MaterialPageRoute(builder: (_) => const ProviderDetailScreen(), settings: settings);
          case '/schedule':
            return MaterialPageRoute(builder: (_) => const ScheduleScreen(), settings: settings);
          case '/orders':
            return MaterialPageRoute(builder: (_) => const OrdersScreen());
          case '/map':
            return MaterialPageRoute(builder: (_) => const MapScreen());
          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfileScreen());
          case '/tracking':
            final order = settings.arguments as ServiceOrder;
            return MaterialPageRoute(
              builder: (_) => TrackingScreen(order: order),
              settings: settings,
            );
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}
