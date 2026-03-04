import '../models/user_model.dart';
import '../services/mongodb_service.dart';

class UserRepository {
  static const String collectionName = 'users';

  Future<void> insertUser(User user) async {
    final db = await MongoDBService.getDb();
    await db.collection(collectionName).insert(user.toJson());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await MongoDBService.getDb();
    final data = await db.collection(collectionName).findOne({'email': email});
    if (data != null) {
      return User.fromJson(data);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await MongoDBService.getDb();
    final users = await db.collection(collectionName).find().toList();
    return users.map((e) => User.fromJson(e)).toList();
  }

  Future<void> updateUser(User user) async {
    final db = await MongoDBService.getDb();
    await db
        .collection(collectionName)
        .replaceOne({'_id': user.id}, user.toJson());
  }

  Future<void> deleteUser(String id) async {
    final db = await MongoDBService.getDb();
    await db.collection(collectionName).remove({'_id': id});
  }

  Future<void> updateUserPhoto(String userId, String base64Photo) async {
    final db = await MongoDBService.getDb();
    await db.collection(collectionName).updateOne(
      {'_id': userId},
      {
        r'$set': {'userPhotoUrl': base64Photo}
      },
    );
  }

  Future<List<User>> getUsersByType(UserType userType) async {
    final db = await MongoDBService.getDb();
    final typeName = userType.toString().split('.').last;
    final users = await db
        .collection(collectionName)
        .find({'userType': typeName}).toList();
    return users.map((e) => User.fromJson(e)).toList();
  }
}
