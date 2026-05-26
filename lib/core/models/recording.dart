import 'package:flutter/foundation.dart';

@immutable
class Recording {
  const Recording({
    required this.id,
    required this.title,
    required this.filePath,
    required this.createdAt,
    this.durationMs,
  });

  final String id;
  final String title;
  final String filePath;
  final DateTime createdAt;
  final int? durationMs;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'durationMs': durationMs,
    };
  }

  static Recording fromJson(Map<String, Object?> json) {
    return Recording(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? 'Recording',
      filePath: (json['filePath'] as String?) ?? '',
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      durationMs: json['durationMs'] as int?,
    );
  }

  Recording copyWith({
    String? id,
    String? title,
    String? filePath,
    DateTime? createdAt,
    int? durationMs,
  }) {
    return Recording(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      durationMs: durationMs ?? this.durationMs,
    );
  }
}
