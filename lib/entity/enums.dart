enum Language {
  en,
  zh,
}
enum ConnectionStatus {
  success,
  failture,
}
enum LoginStatus {
  authenticationSuccess,
  authenticationFailture,
  serverError,
  timeoutError,
  unknownError,
}
enum Role {
  admin,
  service,
  user,
}
enum LogoutOrCleanUpStatus {
  success,
  authenticationFailture,
  serverError,
}
enum RegisterStatus {
  success,
  invalidUsername,
  permissionDenied,
  serverError,
  timeoutError,
  unknownError,
}
enum ThemeDataCode {
  defLight,
  defDark,
}

enum MessageSendStatus {
  processing,
  success,
  failture,
}
enum SendStatus {
  success,
  reject,
  serverError,
}
enum ChatProtocolCode {
  //handshake,
  newSend,
  reSend,
  accept,
  reject,
}
enum AccountProtocolCode {
  login,
  logout,
  register,
  cleanUp,
}
