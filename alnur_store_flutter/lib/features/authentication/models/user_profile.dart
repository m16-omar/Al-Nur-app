class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? preferredCurrency;
  final String? bio;
  final bool isGuest;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.preferredCurrency = 'NGN',
    this.bio,
    this.isGuest = false,
  });

  factory UserProfile.guest() {
    return const UserProfile(
      id: 'guest_user',
      name: '',
      email: '',
      isGuest: true,
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? preferredCurrency,
    String? bio,
    bool? isGuest,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      bio: bio ?? this.bio,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  bool get hasName => name.trim().isNotEmpty;
  bool get hasEmail => email.trim().isNotEmpty;
}
