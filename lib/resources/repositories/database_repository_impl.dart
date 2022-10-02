import 'package:Linez/models/wait_time_model.dart';

import '../../models/profile_model.dart';
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
  Future<void> addWaitTime(String id, int waitTime) {
    return service.addWaitTime(id, waitTime);
  }

  @override
  Future<List<WaitTimeModel>> getWaitTimes(String id) {
    return service.getWaitTimes(id);
  }

  @override
  Future<bool> sendFeedback(String message) {
    return service.sendFeedback(message);
  }

  @override
  void incrementTickets({bool fromFeedback = false}) {
    service.incrementTickets(fromFeedback: fromFeedback);
  }

  @override
  Future<void> deleteProfile() async {
    await service.deleteProfile();
  }

  @override
  Future<void> addReportedLocation(String address) async {
    await service.addReportedLocation(address);
  }

  @override
  Future<ProfileModel?> getUserProfile() async {
    return await service.getUserProfile();
  }

  @override
  Future<bool> getRestrictionMode() async {
    return await service.getRestrictionMode();
  }
}

abstract class DatabaseRepository {
  Future<void> saveUserData(UserModel user);
  Future<List<UserModel>> retrieveUserData();
  Future<void> addWaitTime(String id, int waitTime);
  Future<List<WaitTimeModel>> getWaitTimes(String id);
  Future<bool> sendFeedback(String message);
  void incrementTickets({bool fromFeedback = false});
  Future<void> deleteProfile();
  Future<void> addReportedLocation(String address);
  Future<ProfileModel?> getUserProfile();
  Future<bool> getRestrictionMode();
}


class StorageRepositoryImpl implements StorageRepository {
  StorageService service = StorageService();

  @override
  Future<bool> submitLineImage(String imagePath, String address) {
    return service.submitLineImage(imagePath, address);
  }
}

abstract class StorageRepository {
  Future<bool> submitLineImage(String imagePath, String address);
}
