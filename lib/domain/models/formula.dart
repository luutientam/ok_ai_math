class Formula {
  final int? uid; // auto-increment
  final String name;
  final String iconPath;

  Formula({
    this.uid,
    required this.name,
    required this.iconPath,
  });

  factory Formula.fromJson(Map<String, dynamic> json) {
    return Formula(
      uid: json['uid'] as int?,
      name: json['name'] as String,
      iconPath: json['iconPath'] as String,
    );
  }

  factory Formula.fromMap(Map<String, dynamic> map) {
    return Formula(
      uid: map['uid'] is int
          ? map['uid']
          : int.tryParse(map['uid']?.toString() ?? ''),
      name: map['name']?.toString() ?? '',
      iconPath: map['icon_path']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'iconPath': iconPath,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'icon_path': iconPath,
    };
  }
}