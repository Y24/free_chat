import 'package:flutter_test/flutter_test.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/protocol/sender/account_protocol_sender.dart';

main() {
  test('Account protocol test', () async {
    final accountProtocols = [
      AccountProtocol(username: 'yj', password: 'password'),
      AccountProtocol(username: 'yj', password: 'pssword'),
      AccountProtocol(username: 'yj', password: 'pssword'),
      AccountProtocol(username: 'yj', password: 'pssword'),
      AccountProtocol(username: 'yj', password: 'pssword'),
    ];
    expect(
        await accountProtocols[0].login(), LoginStatus.authenticationFailture,
        skip: true);
    expect(await accountProtocols[0].register(), RegisterStatus.success,
        skip: true);
    expect(
      await accountProtocols[0].login(),
      LoginStatus.authenticationSuccess,
    );
  });
}
