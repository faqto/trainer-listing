import 'user_role.dart';

class AppUserProfile {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String lastName;
  final String phone;
  final int age;
  final String sex;
  final String goal;
  final String schedule;
  final double weightKg;
  final double heightCm;
  final double bodyFatPercent;
  final double waistCm;
  final double hipsCm;
  final double chestCm;
  final String? assignedCoachId;
  final String? assignedCoachName;

  const AppUserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.lastName = '',
    this.phone = '',
    this.age = 0,
    this.sex = 'Not specified',
    this.goal = '',
    this.schedule = '',
    this.weightKg = 0,
    this.heightCm = 0,
    this.bodyFatPercent = 0,
    this.waistCm = 0,
    this.hipsCm = 0,
    this.chestCm = 0,
    this.assignedCoachId,
    this.assignedCoachName,
  });

  factory AppUserProfile.fromMap(Map<String, dynamic> map, String id) {
    return AppUserProfile(
      id: id,
      name: (map['name'] as String?)?.trim() ?? '',
      email: (map['email'] as String?)?.trim() ?? '',
      role: userRoleFromName(map['role'] as String?),
      lastName: (map['lastName'] as String?)?.trim() ?? '',
      phone: (map['phone'] as String?)?.trim() ?? '',
      age: map['age'] is int ? map['age'] as int : 0,
      sex: (map['sex'] as String?)?.trim().isNotEmpty == true
          ? (map['sex'] as String).trim()
          : 'Not specified',
      goal: (map['goal'] as String?)?.trim() ?? '',
      schedule: (map['schedule'] as String?)?.trim() ?? '',
      weightKg: _readDouble(map['weightKg']),
      heightCm: _readDouble(map['heightCm']),
      bodyFatPercent: _readDouble(map['bodyFatPercent']),
      waistCm: _readDouble(map['waistCm']),
      hipsCm: _readDouble(map['hipsCm']),
      chestCm: _readDouble(map['chestCm']),
      assignedCoachId: (map['assignedCoachId'] as String?)?.trim(),
      assignedCoachName: (map['assignedCoachName'] as String?)?.trim(),
    );
  }
}

double _readDouble(Object? value) {
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
