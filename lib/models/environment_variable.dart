import 'package:equatable/equatable.dart';

class EnvironmentVariable extends Equatable {
  final String key;
  final String value;
  final String? description;
  final bool encrypted;

  const EnvironmentVariable({
    required this.key,
    required this.value,
    this.description,
    this.encrypted = true,
  }) {
    if (key.isEmpty) {
      throw ArgumentError('Key cannot be empty');
    }
    if (key.contains(' ')) {
      throw ArgumentError('Key cannot contain spaces');
    }
  }

  factory EnvironmentVariable.fromJson(Map<String, dynamic> json) {
    return EnvironmentVariable(
      key: json['key'] as String,
      value: json['value'] as String,
      description: json['description'] as String?,
      encrypted: json['encrypted'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'description': description,
      'encrypted': encrypted,
    };
  }

  EnvironmentVariable copyWith({
    String? key,
    String? value,
    String? description,
    bool? encrypted,
  }) {
    return EnvironmentVariable(
      key: key ?? this.key,
      value: value ?? this.value,
      description: description ?? this.description,
      encrypted: encrypted ?? this.encrypted,
    );
  }

  @override
  List<Object?> get props => [key, value, description, encrypted];
}