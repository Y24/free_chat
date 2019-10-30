enum Language {
  en,
  zh,
}
enum ConnectionStatus {
  success,
  failture,
}
enum LoginStatus {
  authenticationsuccess,
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
enum RegisterStatus {
  success,
  InvalidUsername,
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

enum ChatProtocolCode {
  //handshake,
  newSend,
  reSend,
  accept,
  reject,
}
