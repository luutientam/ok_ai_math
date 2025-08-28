class FormulaItem {
  final int? uid; // auto-increment
  final int formulaId; // foreign key to Formula
  final String name;
  final String imagePath;
  final bool isSaved;

  FormulaItem({
    this.uid,
    required this.formulaId,
    required this.name,
    required this.imagePath,
    required this.isSaved,
  });

  factory FormulaItem.fromJson(Map<String, dynamic> json) {
    return FormulaItem(
      uid: json['uid'] as int?,
      formulaId: json['formulaId'] as int,
      name: json['name'] as String,
      imagePath: json['imagePath'] as String,
      isSaved: json['isSaved'] as bool,
    );
  }

  factory FormulaItem.fromMap(Map<String, dynamic> map) {
    return FormulaItem(
      uid: map['uid'] is int ? map['uid'] : int.tryParse(map['uid']?.toString() ?? ''),
      formulaId: map['formula_id'] is int
          ? map['formula_id']
          : int.tryParse(map['formula_id']?.toString() ?? '') ?? 0,
      name: map['name']?.toString() ?? '',
      imagePath: map['image_path']?.toString() ?? '',
      isSaved: map['is_saved'] is bool
          ? map['is_saved']
          : (map['is_saved'] == 1 || map['is_saved'] == true),
    );
  }

  Map<String, dynamic> toJson() {
    return {'uid': uid, 'name': name, 'imagePath': imagePath, 'isSaved': isSaved};
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'formula_id': formulaId,
      'name': name,
      'image_path': imagePath,
      'is_saved': isSaved ? 1 : 0, // Convert boolean to integer for SQLite
    };
  }

  // Helper for immutable updates
  FormulaItem copyWith({int? uid, int? formulaId, String? name, String? imagePath, bool? isSaved}) {
    return FormulaItem(
      uid: uid ?? this.uid,
      formulaId: formulaId ?? this.formulaId,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
