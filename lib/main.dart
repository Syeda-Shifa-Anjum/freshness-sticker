import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';

// Core services
import 'core/services/notification_service.dart';
import 'core/services/color_detection_service.dart';

// Data layer
import 'data/datasources/hive_data_source.dart';
import 'data/repositories/fresh_item_repository_impl.dart';

// Domain layer
import 'domain/repositories/fresh_item_repository.dart';

// Presentation layer
import 'presentation/providers/camera_provider.dart';
import 'presentation/providers/items_provider.dart';
import 'presentation/pages/items_list_screen.dart';
import 'presentation/pages/camera_scan_screen.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize cameras
  try {
    cameras = await availableCameras();
  } catch (e) {
    cameras = [];
    debugPrint('Error initializing cameras: $e');
  }

  // Initialize notification service
  await NotificationService.init();

  // Initialize Hive data source
  final hiveDataSource = HiveDataSource();
  await hiveDataSource.init();

  runApp(SmartFreshnessApp(hiveDataSource: hiveDataSource));
}

class SmartFreshnessApp extends StatelessWidget {
  final HiveDataSource hiveDataSource;

  const SmartFreshnessApp({super.key, required this.hiveDataSource});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories
        Provider<FreshItemRepository>(
          create: (_) => FreshItemRepositoryImpl(hiveDataSource),
        ),

        // Services
        Provider<ColorDetectionService>(create: (_) => ColorDetectionService()),

        // Providers
        ChangeNotifierProvider<ItemsProvider>(
          create: (context) =>
              ItemsProvider(context.read<FreshItemRepository>()),
        ),

        ChangeNotifierProvider<CameraProvider>(
          create: (context) => CameraProvider(
            context.read<FreshItemRepository>(),
            context.read<ColorDetectionService>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Smart Freshness Sticker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const ItemsListScreen(),
    ),
    GoRoute(
      path: '/camera',
      name: 'camera',
      builder: (context, state) => const CameraScanScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Page not found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'The page you requested could not be found.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.go('/'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);
