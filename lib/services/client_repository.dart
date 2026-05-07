import '../models/client_model.dart';

class ClientRepository {
  ClientRepository._();

  static final ClientRepository instance = ClientRepository._();

  final List<Client> _clients = [
    Client(
      id: '1',
      name: 'Sarah Jenkins',
      email: 'sarah.jenkins@example.com',
      phone: '+1 555 0145',
      age: 28,
      gender: 'Female',
      goal: 'Build lean muscle',
      notes: 'Focus on strength and posture improvement.',
      trainingProgram: 'General Fitness',
      schedule: 'Mon · Wed · Fri',
      weightKg: 63,
      heightCm: 165,
      bodyFatPercent: 22,
      waistCm: 72,
      hipsCm: 96,
      chestCm: 88,
    ),
    Client(
      id: '2',
      name: 'Marcus Johnson',
      email: 'marcus.johnson@example.com',
      phone: '+1 555 0167',
      age: 31,
      gender: 'Male',
      goal: 'Lose fat and improve cardio',
      notes: 'Weekly progress photos and interval sessions.',
      trainingProgram: 'Strength + Cardio',
      schedule: 'Tue · Thu · Sat',
      weightKg: 84,
      heightCm: 180,
      bodyFatPercent: 19,
      waistCm: 88,
      hipsCm: 99,
      chestCm: 104,
    ),
  ];

  List<Client> get clients => List.unmodifiable(_clients);

  Client? getById(String id) {
    try {
      return _clients.firstWhere((client) => client.id == id);
    } catch (_) {
      return null;
    }
  }

  void addClient(Client client) {
    _clients.add(client);
  }

  void updateClient(Client client) {
    final index = _clients.indexWhere((item) => item.id == client.id);
    if (index >= 0) {
      _clients[index] = client;
    }
  }

  void deleteClient(String id) {
    _clients.removeWhere((client) => client.id == id);
  }

  String createClientId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
