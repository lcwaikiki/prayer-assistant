/// A user sound. The audio lives in the file at [path]; [toMap] holds only
/// the metadata that is stored in Hive.
class SoundItem {
  const SoundItem({
    required this.id,
    required this.title,
    required this.path,
    this.mimeType = 'audio/m4a',
    this.durationMs,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String path;
  final String mimeType;
  final int? durationMs;
  final DateTime createdAt;

  SoundItem copyWith({
    String? id,
    String? title,
    String? path,
    String? mimeType,
    int? durationMs,
    DateTime? createdAt,
  }) {
    return SoundItem(
      id: id ?? this.id,
      title: title ?? this.title,
      path: path ?? this.path,
      mimeType: mimeType ?? this.mimeType,
      durationMs: durationMs ?? this.durationMs,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'mimeType': mimeType,
      'durationMs': durationMs,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SoundItem.fromMap(Map<dynamic, dynamic> map, {required String path}) {
    final rawCreatedAt = map['createdAt']?.toString();
    final createdAt = rawCreatedAt != null && rawCreatedAt.isNotEmpty
        ? DateTime.tryParse(rawCreatedAt) ?? DateTime.now()
        : DateTime.now();

    return SoundItem(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      path: path,
      mimeType: (map['mimeType'] ?? 'audio/m4a').toString(),
      durationMs: (map['durationMs'] as num?)?.toInt(),
      createdAt: createdAt,
    );
  }
}
