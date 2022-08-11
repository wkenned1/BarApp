import 'package:bar_app/models/wait_time_model.dart';

import '../../models/user_model.dart';
import '../services/database_service.dart';

class DatabaseRepositoryImpl implements DatabaseRepository {
  DatabaseService service = DatabaseService();

  @override
  Future<void> saveUserData(UserModel user) {
    return service.addUserData(user);
  }

  @override
  Future<List<UserModel>> retrieveUserData() {
    return service.retrieveUserData();
  }

  @override
  Future<void> addWaitTime(String address, int waitTime) {
    return service.addWaitTime(address, waitTime);
  }

  @override
  Future<List<WaitTimeModel>> getWaitTimes(String address) {
    return service.getWaitTimes(address);
  }
}

abstract class DatabaseRepository {
  Future<void> saveUserData(UserModel user);
  Future<List<UserModel>> retrieveUserData();
  Future<void> addWaitTime(String address, int waitTime);
  Future<List<WaitTimeModel>> getWaitTimes(String address);
}
