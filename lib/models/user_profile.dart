class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String initials;
  final int totalFarms;
  final double totalAreaAcres;
  final int designsCreated;
  final String profileImage;
  final Map<String, dynamic> preferences;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.initials,
    required this.totalFarms,
    required this.totalAreaAcres,
    required this.designsCreated,
    this.profileImage = 'assets/images/farmer_avatar.jpg',
    this.preferences = const {},
  });

  /// Returns the first name only (e.g. "Shivam" from "Shivam Kumar")
  String get firstName {
    if (name.trim().isEmpty) return 'Farmer';
    final first = name.trim().split(' ').first;
    return first.toLowerCase() == 'user' ? 'Farmer' : first;
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final data = (json['user'] is Map<String, dynamic>)
        ? json['user'] as Map<String, dynamic>
        : json;

    final String fName = (data['firstName'] ?? '').toString().trim();
    String lName = (data['lastName'] ?? '').toString().trim();
    if (lName.toLowerCase() == 'user') {
      lName = '';
    }

    String rawName = (data['fullName'] ?? data['name'] ?? '').toString().trim();
    if (rawName.toLowerCase().endsWith(' user')) {
      final withoutUser = rawName.substring(0, rawName.length - 5).trim();
      if (withoutUser.isNotEmpty) {
        rawName = withoutUser;
      }
    }

    if (rawName.isEmpty) {
      if (fName.isNotEmpty && lName.isNotEmpty) {
        rawName = '$fName $lName';
      } else if (fName.isNotEmpty) {
        rawName = fName;
      } else {
        rawName = 'Farmer';
      }
    }

    final name = rawName;
    String initials = (data['initials'] != null && data['initials'].toString().isNotEmpty)
        ? data['initials'].toString()
        : '';
    if (initials.toUpperCase() == 'SU' && !name.toLowerCase().contains('user') && !name.toLowerCase().contains('upadhyay')) {
      // If SU was auto-generated from 'Shivam User', fix it
      initials = '';
    }
    if (initials.isEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (name.length >= 2) {
        initials = name.substring(0, 2).toUpperCase();
      } else if (name.isNotEmpty) {
        initials = name[0].toUpperCase();
      } else {
        initials = 'SK';
      }
    }

    return UserProfile(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      name: name,
      email: (data['email'] ?? '').toString(),
      phone: (data['phoneNumber'] ?? data['phone'] ?? '').toString(),
      initials: initials,
      totalFarms: data['totalFarms'] is num ? (data['totalFarms'] as num).toInt() : 0,
      totalAreaAcres: data['totalAreaAcres'] is num ? (data['totalAreaAcres'] as num).toDouble() : 0.0,
      designsCreated: data['designsCreated'] is num ? (data['designsCreated'] as num).toInt() : 0,
      profileImage: (data['profileImage'] ?? 'assets/images/farmer_avatar.jpg').toString(),
      preferences: data['preferences'] is Map<String, dynamic> ? data['preferences'] : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'initials': initials,
      'totalFarms': totalFarms,
      'totalAreaAcres': totalAreaAcres,
      'designsCreated': designsCreated,
      'profileImage': profileImage,
      'preferences': preferences,
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? initials,
    int? totalFarms,
    double? totalAreaAcres,
    int? designsCreated,
    String? profileImage,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      initials: initials ?? this.initials,
      totalFarms: totalFarms ?? this.totalFarms,
      totalAreaAcres: totalAreaAcres ?? this.totalAreaAcres,
      designsCreated: designsCreated ?? this.designsCreated,
      profileImage: profileImage ?? this.profileImage,
      preferences: preferences ?? this.preferences,
    );
  }
}
