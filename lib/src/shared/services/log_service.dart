import 'package:get/get.dart';
import 'package:vault_env_manager/src/features/workbench/domain/models/system_log.dart';

class LogService extends GetxService {
  static LogService get to => Get.find();

  final RxList<SystemLog> logs = <SystemLog>[].obs;
  static const int _maxLogs = 100;

  void info(String message) => append(message, level: LogLevel.info);
  void success(String message) => append(message, level: LogLevel.success);
  void warning(String message) => append(message, level: LogLevel.warning);
  void error(String message) => append(message, level: LogLevel.error);

  void append(String message, {LogLevel level = LogLevel.info}) {
    logs.add(SystemLog(message: message, level: level));
    if (logs.length > _maxLogs) {
      logs.removeAt(0);
    }
  }

  void clear() => logs.clear();
}
