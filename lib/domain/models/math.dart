class Math {
  final int? uid; // auto-increment
  final String result;
  final String imageUri;
  final String solution;
  final bool isFavorite;
  final DateTime? createdAt;

  Math({
    this.uid,
    required this.result,
    required this.imageUri,
    required this.solution,
    this.isFavorite = false,
    this.createdAt,
  });

  factory Math.fromMap(Map<String, dynamic> map) {
    return Math(
      uid: map['uid'] is int
          ? map['uid']
          : int.tryParse(map['uid']?.toString() ?? ''),
      result: map['result']?.toString() ?? '',      // đồng bộ với toMap
      imageUri: map['image_uri']?.toString() ?? '',
      solution: map['solution']?.toString() ?? '',  // đồng bộ với toMap
      isFavorite: map['is_favorite'] == 1 || map['is_favorite'] == true,
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
        int.tryParse(map['created_at'].toString()) ?? 0,
      )
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'result': result,
      'image_uri': imageUri,
      'solution': solution,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt?.millisecondsSinceEpoch, // lưu dạng int
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'result': result,
      'image_uri': imageUri,
      'solution': solution,
      'is_favorite': isFavorite,
      'created_at': createdAt?.toIso8601String(), // JSON thì lưu ISO
    };
  }

  Math copyWith({
    int? uid,
    String? result,
    String? imageUri,
    String? solution,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return Math(
      uid: uid ?? this.uid,
      result: result ?? this.result,
      imageUri: imageUri ?? this.imageUri,
      solution: solution ?? this.solution,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
