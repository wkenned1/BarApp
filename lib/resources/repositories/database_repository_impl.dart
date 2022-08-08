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
}

abstract class DatabaseRepository {
  Future<void> saveUserData(UserModel user);
  Future<List<UserModel>> retrieveUserData();
  Future<void> addWaitTime(String address, int waitTime);
}
