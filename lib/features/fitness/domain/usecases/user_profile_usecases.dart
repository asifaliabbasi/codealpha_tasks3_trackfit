import 'package:fitness_tracker_app/core/utils/result.dart';
import 'package:fitness_tracker_app/core/errors/failures.dart' as failures;
import 'package:fitness_tracker_app/features/fitness/domain/entities/user_profile.dart';
import 'package:fitness_tracker_app/features/fitness/domain/repositories/fitness_repository.dart';

class GetUserProfile {
  final FitnessRepository repository;

  const GetUserProfile(this.repository);

  Future<Result<UserProfile?>> call() async {
    return await repository.getUserProfile();
  }
}

class SaveUserProfile {
  final FitnessRepository repository;

  const SaveUserProfile(this.repository);

  Future<Result<UserProfile>> call(UserProfile profile) async {
    if (profile.name.trim().isEmpty) {
      return const Failure(
          failures.ValidationFailure(message: 'Name cannot be empty'));
    }

    if (profile.age <= 0 || profile.age > 150) {
      return const Failure(
          failures.ValidationFailure(message: 'Age must be between 1 and 150'));
    }

    if (profile.height <= 0 || profile.height > 300) {
      return const Failure(failures.ValidationFailure(
          message: 'Height must be between 1 and 300 cm'));
    }

    if (profile.weight <= 0 || profile.weight > 500) {
      return const Failure(failures.ValidationFailure(
          message: 'Weight must be between 1 and 500 kg'));
    }

    return await repository.saveUserProfile(profile);
  }
}

class DeleteUserProfile {
  final FitnessRepository repository;

  const DeleteUserProfile(this.repository);

  Future<Result<void>> call() async {
    return await repository.deleteUserProfile();
  }
}
