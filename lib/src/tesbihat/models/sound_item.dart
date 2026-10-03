import 'dart:convert';
import 'dart:typed_data';

class SoundItem {
  const SoundItem({
    required this.id,
    required this.title,
    required this.bytes,
    this.mimeType = 'audio/m4a',
    this.durationMs,
    required this.createdAt,
  });

  final String id;
  final String title;
  final Uint8List bytes;
  final String mimeType;
  final int? durationMs;
  final DateTime createdAt;

  SoundItem copyWith({
    String? id,
    String? title,
    Uint8List? bytes,
    String? mimeType,
    int? durationMs,
    DateTime? createdAt,
  }) {
    return SoundItem(
      id: id ?? this.id,
      title: title ?? this.title,
      bytes: bytes ?? this.bytes,
      mimeType: mimeType ?? this.mimeType,
      durationMs: durationMs ?? this.durationMs,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'bytes': base64Encode(bytes),
      'mimeType': mimeType,
      'durationMs': durationMs,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SoundItem.fromMap(Map<dynamic, dynamic> map) {
    final rawBytes = map['bytes'];
    final Uint8List parsedBytes;
    if (rawBytes is String) {
      parsedBytes = base64Decode(rawBytes);
    } else if (rawBytes is List<int>) {
      parsedBytes = Uint8List.fromList(rawBytes);
    } else if (rawBytes is Uint8List) {
      parsedBytes = rawBytes;
    } else {
      parsedBytes = Uint8List(0);
    }

    final rawCreatedAt = map['createdAt']?.toString();
    final createdAt = rawCreatedAt != null && rawCreatedAt.isNotEmpty
        ? DateTime.tryParse(rawCreatedAt) ?? DateTime.now()
        : DateTime.now();

    return SoundItem(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      bytes: parsedBytes,
      mimeType: (map['mimeType'] ?? 'audio/m4a').toString(),
      durationMs: (map['durationMs'] as num?)?.toInt(),
      createdAt: createdAt,
    );
  }
}
