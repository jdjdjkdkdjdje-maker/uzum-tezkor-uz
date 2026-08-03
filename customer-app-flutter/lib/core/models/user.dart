class AppUser {
  final String id;
  final String? phoneNumber;
  final String? email;
  final String fullName;
  final String? avatarUrl;
  final String role;
  final double bonusBalance;
  final String language;

  AppUser({
    required this.id,
    this.phoneNumber,
    this.email,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    required this.bonusBalance,
    required this.language,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      fullName: json['fullName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String? ?? 'customer',
      bonusBalance: (json['bonusBalance'] as num?)?.toDouble() ?? 0,
      language: json['language'] as String? ?? 'uz',
    );
  }
}
