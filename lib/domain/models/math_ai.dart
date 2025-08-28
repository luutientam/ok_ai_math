class MathAi {
  final int? uid; // auto-increment
  final int isContent; // foreign key to Formula
  final String createdAt;

  MathAi({this.uid, required this.isContent, required this.createdAt});

  factory MathAi.fromJson(Map<String, dynamic> json) {
    return MathAi(
      uid: json['uid'] as int?,
      isContent: json['isContent'] as int,
      createdAt: json['createdAt'] as String,
    );
  }

  factory MathAi.fromMap(Map<String, dynamic> map) {
    return MathAi(
      uid: map['uid'] is int
          ? map['uid']
          : int.tryParse(map['uid']?.toString() ?? ''),
      isContent: map['is_content'] is int
          ? map['is_content']
          : int.tryParse(map['is_content']?.toString() ?? '') ?? 0,
      createdAt: map['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'uid': uid, 'isContent': isContent, 'createdAt': createdAt};
  }

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'is_content': isContent, 'created_at': createdAt};
  }

  MathAi copyWith({int? uid, int? isContent, String? createdAt}) {
    return MathAi(
      uid: uid ?? this.uid,
      isContent: isContent ?? this.isContent,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
