class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String initials;
  final int totalFarms;
  final double totalAreaAcres;
  final int designsCreated;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.initials,
    required this.totalFarms,
    required this.totalAreaAcres,
    required this.designsCreated,
  });
}
