import 'package:equatable/equatable.dart';

class VaultSecret extends Equatable {
  final String name;
  final String fullPath;
  final Map<String, dynamic>? data;

  const VaultSecret({required this.name, required this.fullPath, this.data});

  @override
  List<Object?> get props => [name, fullPath, data];

  VaultSecret copyWith({
    String? name,
    String? fullPath,
    Map<String, dynamic>? data,
  }) {
    return VaultSecret(
      name: name ?? this.name,
      fullPath: fullPath ?? this.fullPath,
      data: data ?? this.data,
    );
  }
}
