class Client {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int age;
  final String gender;
  final String goal;
  final String notes;
  final String trainingProgram;
  final String schedule;
  final DateTime joinDate;
  final double weightKg;
  final double heightCm;
  final double bodyFatPercent;
  final double waistCm;
  final double hipsCm;
  final double chestCm;

  Client({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.age = 0,
    this.gender = 'Not specified',
    required this.goal,
    this.notes = '',
    this.trainingProgram = '',
    this.schedule = '',
    DateTime? joinDate,
    this.weightKg = 0,
    this.heightCm = 0,
    this.bodyFatPercent = 0,
    this.waistCm = 0,
    this.hipsCm = 0,
    this.chestCm = 0,
  }) : joinDate = joinDate ?? DateTime.now();

  Client copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    int? age,
    String? gender,
    String? goal,
    String? notes,
    String? trainingProgram,
    String? schedule,
    DateTime? joinDate,
    double? weightKg,
    double? heightCm,
    double? bodyFatPercent,
    double? waistCm,
    double? hipsCm,
    double? chestCm,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
      notes: notes ?? this.notes,
      trainingProgram: trainingProgram ?? this.trainingProgram,
      schedule: schedule ?? this.schedule,
      joinDate: joinDate ?? this.joinDate,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      bodyFatPercent: bodyFatPercent ?? this.bodyFatPercent,
      waistCm: waistCm ?? this.waistCm,
      hipsCm: hipsCm ?? this.hipsCm,
      chestCm: chestCm ?? this.chestCm,
    );
  }

  String get joinDateLabel {
    return '${joinDate.month.toString().padLeft(2, '0')}/${joinDate.day.toString().padLeft(2, '0')}/${joinDate.year}';
  }
}
