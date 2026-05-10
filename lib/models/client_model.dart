class ProgressEntry {
  final DateTime date;
  final double weightKg;
  final double heightCm;
  final double bodyFatPercent;
  final double waistCm;
  final double hipsCm;
  final double chestCm;
  final String note;

  ProgressEntry({
    DateTime? date,
    required this.weightKg,
    required this.heightCm,
    required this.bodyFatPercent,
    required this.waistCm,
    required this.hipsCm,
    required this.chestCm,
    this.note = '',
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'weightKg': weightKg,
      'heightCm': heightCm,
      'bodyFatPercent': bodyFatPercent,
      'waistCm': waistCm,
      'hipsCm': hipsCm,
      'chestCm': chestCm,
      'note': note,
    };
  }

  factory ProgressEntry.fromMap(Map<String, dynamic> map) {
    return ProgressEntry(
      date: DateTime.parse(map['date']),
      weightKg: map['weightKg'] ?? 0.0,
      heightCm: map['heightCm'] ?? 0.0,
      bodyFatPercent: map['bodyFatPercent'] ?? 0.0,
      waistCm: map['waistCm'] ?? 0.0,
      hipsCm: map['hipsCm'] ?? 0.0,
      chestCm: map['chestCm'] ?? 0.0,
      note: map['note'] ?? '',
    );
  }

  double? get bmi {
    if (weightKg <= 0 || heightCm <= 0) return null;
    final heightMeters = heightCm / 100;
    return weightKg / (heightMeters * heightMeters);
  }

  String get dateLabel {
    return _formatDate(date);
  }
}

class Client {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int age;
  final String sex;
  final String goal;
  final String notes;
  final String trainingProgram;
  final String schedule;
  final String fitnessRegime;
  final String cardioPlan;
  final DateTime joinDate;
  final double weightKg;
  final double heightCm;
  final double bodyFatPercent;
  final double waistCm;
  final double hipsCm;
  final double chestCm;
  final List<ProgressEntry> progressEntries;

  Client({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.age = 0,
    this.sex = 'Not specified',
    required this.goal,
    this.notes = '',
    this.trainingProgram = '',
    this.schedule = '',
    this.fitnessRegime = '',
    this.cardioPlan = '',
    DateTime? joinDate,
    this.weightKg = 0,
    this.heightCm = 0,
    this.bodyFatPercent = 0,
    this.waistCm = 0,
    this.hipsCm = 0,
    this.chestCm = 0,
    List<ProgressEntry>? progressEntries,
  }) : joinDate = joinDate ?? DateTime.now(),
       progressEntries =
           progressEntries ??
           _initialProgressEntries(
             weightKg: weightKg,
             heightCm: heightCm,
             bodyFatPercent: bodyFatPercent,
             waistCm: waistCm,
             hipsCm: hipsCm,
             chestCm: chestCm,
             joinDate: joinDate,
           );

  Client copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    int? age,
    String? sex,
    String? goal,
    String? notes,
    String? trainingProgram,
    String? schedule,
    String? fitnessRegime,
    String? cardioPlan,
    DateTime? joinDate,
    double? weightKg,
    double? heightCm,
    double? bodyFatPercent,
    double? waistCm,
    double? hipsCm,
    double? chestCm,
    List<ProgressEntry>? progressEntries,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      goal: goal ?? this.goal,
      notes: notes ?? this.notes,
      trainingProgram: trainingProgram ?? this.trainingProgram,
      schedule: schedule ?? this.schedule,
      fitnessRegime: fitnessRegime ?? this.fitnessRegime,
      cardioPlan: cardioPlan ?? this.cardioPlan,
      joinDate: joinDate ?? this.joinDate,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      bodyFatPercent: bodyFatPercent ?? this.bodyFatPercent,
      waistCm: waistCm ?? this.waistCm,
      hipsCm: hipsCm ?? this.hipsCm,
      chestCm: chestCm ?? this.chestCm,
      progressEntries: progressEntries ?? this.progressEntries,
    );
  }

  String get joinDateLabel {
    return _formatDate(joinDate);
  }

  double? get bmi {
    if (weightKg <= 0 || heightCm <= 0) return null;
    final heightMeters = heightCm / 100;
    return weightKg / (heightMeters * heightMeters);
  }

  String get bmiLabel {
    final value = bmi;
    return value == null ? '--' : value.toStringAsFixed(1);
  }

  String get weightTrendLabel {
    if (progressEntries.length < 2) return 'No trend yet';

    final sorted = [...progressEntries]
      ..sort((a, b) => a.date.compareTo(b.date));
    final change = sorted.last.weightKg - sorted.first.weightKg;
    if (change.abs() < 0.1) return 'Stable';

    final direction = change > 0 ? 'gained' : 'lost';
    return '${change.abs().toStringAsFixed(1)} kg $direction';
  }

  static List<ProgressEntry> _initialProgressEntries({
    required double weightKg,
    required double heightCm,
    required double bodyFatPercent,
    required double waistCm,
    required double hipsCm,
    required double chestCm,
    DateTime? joinDate,
  }) {
    if (weightKg <= 0 && heightCm <= 0) return [];

    return [
      ProgressEntry(
        date: joinDate,
        weightKg: weightKg,
        heightCm: heightCm,
        bodyFatPercent: bodyFatPercent,
        waistCm: waistCm,
        hipsCm: hipsCm,
        chestCm: chestCm,
        note: 'Initial record',
      ),
    ];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'sex': sex,
      'goal': goal,
      'notes': notes,
      'trainingProgram': trainingProgram,
      'schedule': schedule,
      'fitnessRegime': fitnessRegime,
      'cardioPlan': cardioPlan,
      'joinDate': joinDate.toIso8601String(),
      'weightKg': weightKg,
      'heightCm': heightCm,
      'bodyFatPercent': bodyFatPercent,
      'waistCm': waistCm,
      'hipsCm': hipsCm,
      'chestCm': chestCm,
      'progressEntries': progressEntries.map((e) => e.toMap()).toList(),
    };
  }

  factory Client.fromMap(Map<String, dynamic> map, String id) {
    return Client(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      age: map['age'] ?? 0,
      sex: map['sex'] ?? 'Not specified',
      goal: map['goal'] ?? '',
      notes: map['notes'] ?? '',
      trainingProgram: map['trainingProgram'] ?? '',
      schedule: map['schedule'] ?? '',
      fitnessRegime: map['fitnessRegime'] ?? '',
      cardioPlan: map['cardioPlan'] ?? '',
      joinDate: map['joinDate'] != null
          ? DateTime.parse(map['joinDate'])
          : null,
      weightKg: map['weightKg'] ?? 0.0,
      heightCm: map['heightCm'] ?? 0.0,
      bodyFatPercent: map['bodyFatPercent'] ?? 0.0,
      waistCm: map['waistCm'] ?? 0.0,
      hipsCm: map['hipsCm'] ?? 0.0,
      chestCm: map['chestCm'] ?? 0.0,
      progressEntries: (map['progressEntries'] as List<dynamic>?)
          ?.map((e) => ProgressEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$month/$day/${date.year}';
}
