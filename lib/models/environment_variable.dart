class EnvironmentVariable {
  final String key;
  final String value;
  final String? description;
  final bool encrypted;

  EnvironmentVariable({
    required this.key,
    required this.value,
    this.description,
    this.encrypted = true,
  });

  factory EnvironmentVariable.fromJson(Map<String, dynamic> json) {
    return EnvironmentVariable(
      key: json['key'],
      value: json['value'],
      description: json['description'],
      encrypted: json['encrypted'] ?? true,
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
}