class ClientModel {
  final String id;
  final String name;
  final String date;
  final double weight;

  ClientModel({
    required this.id,
    required this.name,
    required this.date,
    required this.weight,
  });
}

final List<ClientModel> recentActivities = [
  ClientModel(id: '1', name: 'John Doe', date: 'May 7, 2026', weight: 72),

  ClientModel(id: '2', name: 'Sarah Smith', date: 'May 6, 2026', weight: 65),

  ClientModel(id: '3', name: 'Michael Cruz', date: 'May 5, 2026', weight: 81),

  ClientModel(id: '4', name: 'Angela Reyes', date: 'May 4, 2026', weight: 58),

  ClientModel(id: '5', name: 'Kevin Lee', date: 'May 3, 2026', weight: 90),

  ClientModel(id: '6', name: 'Nicole Tan', date: 'May 2, 2026', weight: 54),
];
