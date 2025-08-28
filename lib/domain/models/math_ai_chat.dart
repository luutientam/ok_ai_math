class MathAiChat {
  final int? uid;
  final int mathAi; // foreign key to MathAi
  final String role;
  final String? imagePath;
  final String? content;
  final DateTime createdAt;

  MathAiChat({
    this.uid,
    required this.mathAi,
    required this.role,
    this.imagePath,
    this.content,
    required this.createdAt,
  });

  factory MathAiChat.fromJson(Map<String, dynamic> json) {
    return MathAiChat(
      uid: json['uid'] as int?,
      mathAi: json['mathAi'] as int,
      role: json['role'] as String,
      imagePath: json['imagePath'] as String?,
      content: json['content'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'mathAi': mathAi,
      'role': role,
      'imagePath': imagePath,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MathAiChat.fromMap(Map<String, dynamic> map) {
    return MathAiChat(
      uid: map['uid'] is int
          ? map['uid']
          : int.tryParse(map['uid']?.toString() ?? ''),
      mathAi: map['math_ai'] is int
          ? map['math_ai']
          : int.tryParse(map['math_ai']?.toString() ?? '') ?? 0,
      role: map['role']?.toString() ?? '',
      imagePath: map['image_path']?.toString(),
      content: map['content']?.toString(),
      createdAt: DateTime.parse(
        map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'math_ai': mathAi,
      'role': role,
      'image_path': imagePath,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  MathAiChat copyWith({
    int? uid,
    int? mathAi,
    String? role,
    String? imagePath,
    String? content,
    DateTime? createdAt,
  }) {
    return MathAiChat(
      uid: uid ?? this.uid,
      mathAi: mathAi ?? this.mathAi,
      role: role ?? this.role,
      imagePath: imagePath ?? this.imagePath,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
