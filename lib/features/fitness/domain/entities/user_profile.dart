import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final int? id;
  final String name;
  final int age;
  final double height; // in cm
  final double weight; // in kg
  final Gender gender;
  final String bio;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? profileImagePath;

  const UserProfile({
    this.id,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    required this.bio,
    this.createdAt,
    this.updatedAt,
    this.profileImagePath,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        age,
        height,
        weight,
        gender,
        bio,
        createdAt,
        updatedAt,
        profileImagePath,
      ];

  UserProfile copyWith({
    int? id,
    String? name,
    int? age,
    double? height,
    double? weight,
    Gender? gender,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profileImagePath,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  bool get isComplete => name.isNotEmpty && age > 0 && height > 0 && weight > 0;
}

enum Gender {
  male,
  female,
  other;

  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }
}
