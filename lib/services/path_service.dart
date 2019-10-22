import 'package:path_provider/path_provider.dart';

abstract class PathService {
  static final paths = {};
  static get appRootPath async =>
      (await getApplicationDocumentsDirectory()).path;
}
