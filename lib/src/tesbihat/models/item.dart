class Item {
  const Item({
    required this.id,
    required this.title,
    this.notes = '',
    required this.count,
    required this.check,
    required this.setCount,
    required this.vibrationIntensity,
    this.currentProgress = 0,
  }) : assert(count > 0, 'count must be positive'),
       assert(check > 0, 'check must be positive'),
       assert(setCount >= 0, 'setCount cannot be negative'),
       assert(check * 2 <= count, 'check must not exceed half of count'),
       assert(
         vibrationIntensity >= 1 && vibrationIntensity <= 100,
         'vibrationIntensity must be between 1 and 100',
       ),
       assert(
         currentProgress >= 0 && currentProgress <= count,
         'currentProgress must be in range',
       );

  final String id;
  final String title;
  final String notes;
  final int count;
  final int check;
  final int setCount;
  final int vibrationIntensity;
  final int currentProgress;

  Item copyWith({
    String? id,
    String? title,
    String? notes,
    int? count,
    int? check,
    int? setCount,
    int? vibrationIntensity,
    int? currentProgress,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      count: count ?? this.count,
      check: check ?? this.check,
      setCount: setCount ?? this.setCount,
      vibrationIntensity: vibrationIntensity ?? this.vibrationIntensity,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'count': count,
      'check': check,
      'setCount': setCount,
      'vibrationIntensity': vibrationIntensity,
      'currentProgress': currentProgress,
    };
  }

  factory Item.fromMap(Map<dynamic, dynamic> map) {
    return Item(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      notes: (map['notes'] ?? '').toString(),
      count: (map['count'] ?? 0) as int,
      check: (map['check'] ?? 0) as int,
      setCount: (map['setCount'] ?? 0) as int,
      vibrationIntensity: (map['vibrationIntensity'] ?? 1) as int,
      currentProgress: (map['currentProgress'] ?? 0) as int,
    );
  }

  static String? validateCheckValue({
    required int? count,
    required int? check,
  }) {
    if (check == null) {
      return 'Check is required';
    }
    if (check <= 0) {
      return 'Check must be greater than 0';
    }
    if (count == null || count <= 0) {
      return 'Enter a valid count first';
    }
    if (check * 2 > count) {
      return 'Check cannot be greater than half of count';
    }
    return null;
  }

  static bool isCheckpointProgress({
    required int currentProgress,
    required int check,
  }) {
    if (currentProgress <= 0 || check <= 0) {
      return false;
    }
    return currentProgress % check == 0;
  }
}
