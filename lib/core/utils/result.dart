import 'package:equatable/equatable.dart';
import '../errors/failures.dart' as failures;

abstract class Result<T> extends Equatable {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get data => isSuccess ? (this as Success<T>).data : null;
  failures.Failure? get error =>
      isFailure ? (this as Failure<T>).failure : null;

  @override
  List<Object?> get props => [];
}

class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  List<Object?> get props => [data];
}

class Failure<T> extends Result<T> {
  final failures.Failure failure;

  const Failure(this.failure);

  @override
  List<Object?> get props => [failure];
}

extension ResultExtensions<T> on Result<T> {
  Result<R> map<R>(R Function(T) mapper) {
    if (isSuccess) {
      return Success(mapper(data as T));
    } else {
      return Failure(error! as failures.Failure);
    }
  }

  Result<T> onSuccess(void Function(T) callback) {
    if (isSuccess) {
      callback(data as T);
    }
    return this;
  }

  Result<T> onFailure(void Function(failures.Failure) callback) {
    if (isFailure) {
      callback(error!);
    }
    return this;
  }

  T? getOrNull() => data;

  T getOrElse(T defaultValue) => data ?? defaultValue;

  T getOrThrow() {
    if (isSuccess) return data as T;
    throw Exception(error?.message ?? 'Unknown error');
  }
}
