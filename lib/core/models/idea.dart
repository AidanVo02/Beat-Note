import 'package:flutter/foundation.dart';

@immutable
class Idea {
  const Idea({
    required this.id,
    required this.title,
    required this.note,
    required this.bpm,
    required this.musicKey,
    required this.mood,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String note;
  final int? bpm;
  final String? musicKey;
  final String? mood;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get summaryLine {
    final parts = <String>[];
    if (musicKey != null && musicKey!.trim().isNotEmpty) parts.add(musicKey!);
    if (bpm != null) parts.add('${bpm} BPM');
    if (mood != null && mood!.trim().isNotEmpty) parts.add(mood!);
    if (tags.isNotEmpty) parts.add(tags.take(3).map((t) => '#$t').join(' '));
    return parts.isEmpty ? 'Tap to view' : parts.join(' · ');
  }

  Idea copyWith({
    String? id,
    String? title,
    String? note,
    int? bpm,
    String? musicKey,
    String? mood,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Idea(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      bpm: bpm ?? this.bpm,
      musicKey: musicKey ?? this.musicKey,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'bpm': bpm,
      'musicKey': musicKey,
      'mood': mood,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static Idea fromJson(Map<String, Object?> json) {
    return Idea(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      note: (json['note'] as String?) ?? '',
      bpm: json['bpm'] as int?,
      musicKey: json['musicKey'] as String?,
      mood: json['mood'] as String?,
      tags: (json['tags'] as List?)?.whereType<String>().toList() ?? const [],
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse((json['updatedAt'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

