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
  final String gender;
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
    this.gender = 'Not specified',
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
    String? gender,
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
      gender: gender ?? this.gender,
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
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$month/$day/${date.year}';
}
