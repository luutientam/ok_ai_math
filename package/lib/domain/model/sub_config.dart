class SubConfig {
  final int uid;
  final bool isSub;
  final bool isLifetime;
  final bool isRemoveAd;

  SubConfig({
    required this.uid,
    required this.isSub,
    required this.isLifetime,
    required this.isRemoveAd,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'is_sub': isSub ? 1 : 0,
      'is_lifetime': isLifetime ? 1 : 0,
      'is_remove_ad': isRemoveAd ? 1 : 0,
    };
  }

  factory SubConfig.fromMap(Map<String, dynamic> map) {
    return SubConfig(
      uid: map['uid'],
      isSub: map['is_sub'] == 1,
      isLifetime: map['is_lifetime'] == 1,
      isRemoveAd: map['is_remove_ad'] == 1,
    );
  }

  // copyWith method to create a new instance with updated values
  SubConfig copyWith({int? uid, bool? isSub, bool? isLifetime, bool? isRemoveAd}) {
    return SubConfig(
      uid: uid ?? this.uid,
      isSub: isSub ?? this.isSub,
      isLifetime: isLifetime ?? this.isLifetime,
      isRemoveAd: isRemoveAd ?? this.isRemoveAd,
    );
  }
}
