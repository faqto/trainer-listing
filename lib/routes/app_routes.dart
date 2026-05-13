import 'package:flutter/material.dart';
import 'package:trainer_listing/pages/auth/welcome_page.dart';

import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/clients/add_client_page.dart';
import '../pages/clients/client_information_page.dart';
import '../pages/clients/edit_fitness_regime_page.dart';
import '../pages/clients/clients_list_page.dart';
import '../pages/clients/edit_client_page.dart';
import '../pages/clients/update_body_details_page.dart';
import '../pages/home/home_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String clients = '/clients';
  static const String addClient = '/clients/add';
  static const String clientInfo = '/clients/info';
  static const String editClient = '/clients/edit';
  static const String editRegime = '/clients/edit-regime';
  static const String bodyDetails = '/clients/body-details';
  static const String welcome = '/welcome';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder == null) {
      return _premiumRoute(
        const _InvalidRoutePage(title: 'Page Not Found'),
        settings,
      );
    }

    return _premiumRoute(
      Builder(builder: (context) => builder(context)),
      settings,
    );
  }

  static PageRouteBuilder<dynamic> _premiumRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0.02),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    home: (context) => const HomePage(),
    clients: (context) => const ClientsListPage(),
    addClient: (context) => const AddClientPage(),
    clientInfo: (context) {
      final clientId = _clientIdFromRoute(context);
      if (clientId == null) {
        return const _InvalidRoutePage(title: 'Client Profile');
      }
      return ClientInformationPage(clientId: clientId);
    },
    editClient: (context) {
      final clientId = _clientIdFromRoute(context);
      if (clientId == null) {
        return const _InvalidRoutePage(title: 'Edit Client');
      }
      return EditClientPage(clientId: clientId);
    },
    editRegime: (context) {
      final clientId = _clientIdFromRoute(context);
      if (clientId == null) {
        return const _InvalidRoutePage(title: 'Fitness Regime');
      }
      return EditFitnessRegimePage(clientId: clientId);
    },
    bodyDetails: (context) {
      final clientId = _clientIdFromRoute(context);
      if (clientId == null) {
        return const _InvalidRoutePage(title: 'Body Details');
      }
      return UpdateBodyDetailsPage(clientId: clientId);
    },
    welcome: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final type = args == WelcomeType.newUser
          ? WelcomeType.newUser
          : WelcomeType.returningUser;
      return WelcomePage(type: type);
    },
  };

  static String? _clientIdFromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return arguments is String && arguments.isNotEmpty ? arguments : null;
  }
}

class _InvalidRoutePage extends StatelessWidget {
  final String title;

  const _InvalidRoutePage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text('Missing client information.')),
    );
  }
}
