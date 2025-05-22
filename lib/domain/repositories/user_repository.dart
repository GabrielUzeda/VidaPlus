// Interface de repositório para User
import '../entities/user.dart';

abstract class UserRepository {
  Future<User> getUserById(String id);
  Future<User> createUser({
    required String id,
    required String email,
    required String name,
    String? photoUrl,
  });
  Future<User> updateUser({
    required String id,
    String? name,
    String? photoUrl,
  });
  Future<void> deleteUser(String id);
} 