import 'package:free_chat/provider/base_provider.dart';

abstract class IProfileProvider implements IProvider {
  Future addProfile();
  Future updateProfile();
  Future deleteProfile();
  Future queryProfile();
  Future queryAllProfile();
}

class ProfileProvider extends BaseProvider implements IProfileProvider {
  final String username;
  ProfileProvider({this.username});
  @override
  Future addProfile() {
    // TODO: implement addProfile
    return null;
  }

  @override
  Future close() {
    // TODO: implement close
    return null;
  }

  @override
  String get dbName => 'profile';

  @override
  Future deleteProfile() {
    // TODO: implement deleteProfile
    return null;
  }

  @override
  // TODO: implement entity
  get entity => null;

  @override
  Future<bool> init() {
    // TODO: implement init
    return null;
  }

  @override
  // TODO: implement ownerName
  String get ownerName => null;

  @override
  Future provide() {
    // TODO: implement provide
    return null;
  }

  @override
  Future queryAllProfile() {
    // TODO: implement queryAllProfile
    return null;
  }

  @override
  Future queryProfile() {
    // TODO: implement queryProfile
    return null;
  }

  @override
  void setEntity(entity) {
    // TODO: implement setEntity
  }

  @override
  // TODO: implement tables
  Map<String, List<String>> get tables => null;

  @override
  Future updateProfile() {
    // TODO: implement updateProfile
    return null;
  }
}
