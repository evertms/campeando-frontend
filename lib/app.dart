import 'package:campeando_frontend/core/data/api_client.dart';
import 'package:campeando_frontend/core/data/storage_service.dart';
import 'package:campeando_frontend/core/navigation/app_router.dart';
import 'package:campeando_frontend/features/auth/data/auth_repository_impl.dart';
import 'package:campeando_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:campeando_frontend/features/auth/presentation/auth_provider.dart';
import 'package:campeando_frontend/features/events/data/datasources/event_remote_datasource.dart';
import 'package:campeando_frontend/features/events/data/repositories/event_repository_impl.dart';
import 'package:campeando_frontend/features/events/domain/repositories/event_repository.dart';
import 'package:campeando_frontend/features/organizations/data/repositories/organization_repository_impl.dart';
import 'package:campeando_frontend/features/organizations/domain/repositories/organization_repository.dart';
import 'package:campeando_frontend/features/registration/data/datasources/registration_remote_datasource.dart';
import 'package:campeando_frontend/features/registration/data/repositories/registration_repository_impl.dart';
import 'package:campeando_frontend/features/registration/domain/repositories/registration_repository.dart';
import 'package:campeando_system_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class CampeandoApp extends StatefulWidget {
  final StorageService storageService;

  const CampeandoApp({super.key, required this.storageService});

  @override
  State<CampeandoApp> createState() => _CampeandoAppState();
}

class _CampeandoAppState extends State<CampeandoApp> {
  late final AppRouter _appRouter;
  bool _isRouterInitialized = false;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: _getProviders(),
      child: Builder(
        builder: (context) {
          if (!_isRouterInitialized) {
            _appRouter = AppRouter(context.read<AuthProvider>());
            _isRouterInitialized = true;
          }

          return MaterialApp.router(
            title: 'Campeando',
            debugShowCheckedModeBanner: false,
            routerConfig: _appRouter.router,
            theme: AppTheme.lightTheme,
          );
        },
      ),
    );
  }

  List<SingleChildWidget> _getProviders() {
    // Infrastructure
    final apiClient = ApiClient(storageService: widget.storageService);

    // Datasources
    final eventRemoteDatasource = EventRemoteDatasourceImpl(
      apiClient: apiClient,
    );
    final registrationRemoteDatasource = RegistrationRemoteDatasourceImpl(
      apiClient: apiClient,
    );

    // Repositories
    final eventRepository = EventRepositoryImpl(
      remoteDatasource: eventRemoteDatasource,
    );
    final registrationRepository = RegistrationRepositoryImpl(
      remoteDatasource: registrationRemoteDatasource,
    );
    final authRepository = AuthRepositoryImpl(apiClient: apiClient);
    final organizationRepository = OrganizationRepositoryImpl(
      apiClient: apiClient,
    );

    return [
      Provider<StorageService>.value(value: widget.storageService),
      Provider<EventRepository>.value(value: eventRepository),
      Provider<RegistrationRepository>.value(value: registrationRepository),
      Provider<AuthRepository>.value(value: authRepository),
      Provider<OrganizationRepository>.value(value: organizationRepository),
      ChangeNotifierProvider<AuthProvider>(
        create: (context) => AuthProvider(
          authRepository: authRepository,
          storageService: widget.storageService,
        ),
      ),
    ];
  }
}
