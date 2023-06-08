import 'package:flutter_test/flutter_test.dart';

import 'test_module/routes.dart';
import 'test_module/setup.module.dart';

void main() {
  final testMod = TestModule();
  setUpAll(() {
    print(testMod.routes);
    testMod.init<TestModule>();
  });

  test('tests if module routes actually begin with the module name', () {
    print(testMod.moduleRoutes.first.absolutePath);
    expect(
        testMod.moduleRoutes.first.absolutePath.startsWith("/$modName"), true);
  });
}
