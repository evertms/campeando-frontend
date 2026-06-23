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

class CampeandoApp extends StatefulWidget {
  final StorageService storageService;

  const CampeandoApp({super.key, required this.storageService});

  @override
  State<CampeandoApp> createState() => _CampeandoAppState();
}

class _CampeandoAppState extends State<CampeandoApp> {
  late final AppRouter _appRouter;

  // Infrastructure & Repositories
  late final ApiClient _apiClient;
  late final EventRepository _eventRepository;
  late final RegistrationRepository _registrationRepository;
  late final AuthRepository _authRepository;
  late final OrganizationRepository _organizationRepository;
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(storageService: widget.storageService);

    final eventRemoteDatasource = EventRemoteDatasourceImpl(
      apiClient: _apiClient,
    );
    final registrationRemoteDatasource = RegistrationRemoteDatasourceImpl(
      apiClient: _apiClient,
    );

    _eventRepository = EventRepositoryImpl(
      remoteDatasource: eventRemoteDatasource,
    );
    _registrationRepository = RegistrationRepositoryImpl(
      remoteDatasource: registrationRemoteDatasource,
    );
    _authRepository = AuthRepositoryImpl(apiClient: _apiClient);
    _organizationRepository = OrganizationRepositoryImpl(apiClient: _apiClient);
    _authProvider = AuthProvider(
      authRepository: _authRepository,
      storageService: widget.storageService,
    );
    _appRouter = AppRouter(_authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: widget.storageService),
        Provider<EventRepository>.value(value: _eventRepository),
        Provider<RegistrationRepository>.value(value: _registrationRepository),
        Provider<AuthRepository>.value(value: _authRepository),
        Provider<OrganizationRepository>.value(value: _organizationRepository),
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
      ],
      child: MaterialApp.router(
        title: 'Campeando',
        debugShowCheckedModeBanner: false,
        routerConfig: _appRouter.router,
        theme: AppTheme.lightTheme,
      ),
    );
  }
}
