import 'package:fitness_tracker_app/features/fitness/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    super.id,
    required super.name,
    required super.age,
    required super.height,
    required super.weight,
    required super.gender,
    required super.bio,
    super.createdAt,
    super.updatedAt,
    super.profileImagePath,
  });
  
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      age: json['age'] as int,
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      gender: Gender.values.firstWhere(
        (g) => g.name == json['gender'],
        orElse: () => Gender.other,
      ),
      bio: json['bio'] as String,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      profileImagePath: json['profile_image_path'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender.name,
      'bio': bio,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'profile_image_path': profileImagePath,
    };
  }
  
  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      name: profile.name,
      age: profile.age,
      height: profile.height,
      weight: profile.weight,
      gender: profile.gender,
      bio: profile.bio,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
      profileImagePath: profile.profileImagePath,
    );
  }
  
  UserProfile toEntity() {
    return UserProfile(
      id: id,
      name: name,
      age: age,
      height: height,
      weight: weight,
      gender: gender,
      bio: bio,
      createdAt: createdAt,
      updatedAt: updatedAt,
      profileImagePath: profileImagePath,
    );
  }
}
