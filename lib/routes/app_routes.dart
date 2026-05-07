import 'package:flutter/material.dart';

import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/clients/add_client_page.dart';
import '../pages/clients/client_information_page.dart';
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
  static const String bodyDetails = '/clients/body-details';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    home: (context) => const HomePage(),
    clients: (context) => const ClientsListPage(),
    addClient: (context) => const AddClientPage(),
    clientInfo: (context) {
      final clientId = ModalRoute.of(context)!.settings.arguments as String;
      return ClientInformationPage(clientId: clientId);
    },
    editClient: (context) {
      final clientId = ModalRoute.of(context)!.settings.arguments as String;
      return EditClientPage(clientId: clientId);
    },
    bodyDetails: (context) {
      final clientId = ModalRoute.of(context)!.settings.arguments as String;
      return UpdateBodyDetailsPage(clientId: clientId);
    },
  };
}
