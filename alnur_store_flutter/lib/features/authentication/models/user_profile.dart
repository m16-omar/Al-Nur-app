class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final bool isGuest;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.isGuest = false,
  });

  factory UserProfile.guest() {
    return const UserProfile(
      id: 'guest_user',
      name: 'Guest Shopper',
      email: 'guest@alnur.store',
      isGuest: true,
    );
  }
}
