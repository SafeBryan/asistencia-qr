class Token {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  Token({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      expiresIn: json['expiresIn'] ?? 0,
    );
  }
}
