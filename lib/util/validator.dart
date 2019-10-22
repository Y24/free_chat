class Validator {
  static const passwordMaxLength = 50;
  static const usernameMaxLength = 20;
  static bool validatePassword(final String password) =>
      password.length < passwordMaxLength;

  static bool validateUsername(final String username) =>
      username.length < usernameMaxLength;
}
