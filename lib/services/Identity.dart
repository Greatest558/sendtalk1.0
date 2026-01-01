class Identity {
  final String username;

  // NEVER expose these outside service layer
  final List<int> privateKey;
  final List<int> publicKey;

  Identity({
    required this.username,
    required this.privateKey,
    required this.publicKey,
  });
}
