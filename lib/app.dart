import 'package:campeando_frontend/core/data/api_client.dart';
import 'package:campeando_frontend/core/data/storage_service.dart';
import 'package:campeando_frontend/core/navigation/app_router.dart';
import 'package:campeando_frontend/core/navigation/deep_link_handler.dart';
import 'package:campeando_frontend/features/access_control/data/datasources/access_control_remote_datasource.dart';
import 'package:campeando_frontend/features/access_control/data/repositories/access_control_repository_impl.dart';
import 'package:campeando_frontend/features/access_control/domain/repositories/access_control_repository.dart';
import 'package:campeando_frontend/features/auth/data/auth_repository_impl.dart';
import 'package:campeando_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:campeando_frontend/features/auth/presentation/auth_provider.dart';
import 'package:campeando_frontend/features/confirmed_participants/data/datasources/confirmed_participants_remote_datasource.dart';
import 'package:campeando_frontend/features/confirmed_participants/data/repositories/confirmed_participants_repository_impl.dart';
import 'package:campeando_frontend/features/confirmed_participants/domain/repositories/confirmed_participants_repository.dart';
import 'package:campeando_frontend/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:campeando_frontend/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:campeando_frontend/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:campeando_frontend/features/events/data/datasources/event_remote_datasource.dart';
import 'package:campeando_frontend/features/events/data/repositories/event_repository_impl.dart';
import 'package:campeando_frontend/features/events/domain/repositories/event_repository.dart';
import 'package:campeando_frontend/features/organizations/data/repositories/organization_repository_impl.dart';
import 'package:campeando_frontend/features/organizations/domain/repositories/organization_repository.dart';
import 'package:campeando_frontend/features/payment_links/application/payment_link_sharing_service.dart';
import 'package:campeando_frontend/features/payment_links/data/datasources/payment_links_remote_datasource.dart';
import 'package:campeando_frontend/features/payment_links/data/repositories/payment_links_repository_impl.dart';
import 'package:campeando_frontend/features/payment_links/domain/repositories/payment_links_repository.dart';
import 'package:campeando_frontend/features/payment_validation/application/share_deep_link_service.dart';
import 'package:campeando_frontend/features/payment_validation/data/datasources/payment_validation_remote_datasource.dart';
import 'package:campeando_frontend/features/payment_validation/data/repositories/payment_validation_repository_impl.dart';
import 'package:campeando_frontend/features/payment_validation/domain/repositories/payment_validation_repository.dart';
import 'package:campeando_frontend/features/pending_applications/data/datasources/applications_remote_datasource.dart';
import 'package:campeando_frontend/features/pending_applications/data/repositories/applications_repository_impl.dart';
import 'package:campeando_frontend/features/pending_applications/domain/repositories/applications_repository.dart';
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
  late final DeepLinkHandler _deepLinkHandler;

  // Infrastructure & Repositories
  late final ApiClient _apiClient;
  late final EventRepository _eventRepository;
  late final RegistrationRepository _registrationRepository;
  late final AuthRepository _authRepository;
  late final OrganizationRepository _organizationRepository;
  late final AuthProvider _authProvider;

  // MVP feature repositories & services
  late final AccessControlRepository _accessControlRepository;
  late final ApplicationsRepository _applicationsRepository;
  late final PaymentValidationRepository _paymentValidationRepository;
  late final PaymentLinksRepository _paymentLinksRepository;
  late final DashboardRepository _dashboardRepository;
  late final ConfirmedParticipantsRepository _confirmedParticipantsRepository;
  late final ShareDeepLinkService _shareDeepLinkService;
  late final PaymentLinkSharingService _paymentLinkSharingService;

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

    // MVP feature wiring (Access Control, Pending Applications, Payments)
    _accessControlRepository = AccessControlRepositoryImpl(
      remoteDatasource: AccessControlRemoteDatasourceImpl(
        apiClient: _apiClient,
      ),
    );
    _applicationsRepository = ApplicationsRepositoryImpl(
      remoteDatasource: ApplicationsRemoteDatasourceImpl(apiClient: _apiClient),
    );
    _paymentValidationRepository = PaymentValidationRepositoryImpl(
      remoteDatasource: PaymentValidationRemoteDatasourceImpl(
        apiClient: _apiClient,
      ),
    );
    _paymentLinksRepository = PaymentLinksRepositoryImpl(
      remoteDatasource: PaymentLinksRemoteDatasourceImpl(apiClient: _apiClient),
    );
    _dashboardRepository = DashboardRepositoryImpl(
      remoteDatasource: DashboardRemoteDatasourceImpl(apiClient: _apiClient),
    );
    _confirmedParticipantsRepository = ConfirmedParticipantsRepositoryImpl(
      remoteDatasource: ConfirmedParticipantsRemoteDatasourceImpl(
        apiClient: _apiClient,
      ),
    );
    _shareDeepLinkService = ShareDeepLinkService();
    _paymentLinkSharingService = PaymentLinkSharingService();

    _appRouter = AppRouter(_authProvider);

    // Escucha los deep links entrantes. Se inicializa tras el primer frame
    // para garantizar que el router ya esté montado antes del primer `go`.
    _deepLinkHandler = DeepLinkHandler(_appRouter.router, _authProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deepLinkHandler.init();
    });
  }

  @override
  void dispose() {
    _deepLinkHandler.dispose();
    super.dispose();
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
        Provider<AccessControlRepository>.value(
          value: _accessControlRepository,
        ),
        Provider<ApplicationsRepository>.value(value: _applicationsRepository),
        Provider<PaymentValidationRepository>.value(
          value: _paymentValidationRepository,
        ),
        Provider<PaymentLinksRepository>.value(value: _paymentLinksRepository),
        Provider<DashboardRepository>.value(value: _dashboardRepository),
        Provider<ConfirmedParticipantsRepository>.value(
          value: _confirmedParticipantsRepository,
        ),
        Provider<ShareDeepLinkService>.value(value: _shareDeepLinkService),
        Provider<PaymentLinkSharingService>.value(
          value: _paymentLinkSharingService,
        ),
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
