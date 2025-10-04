import 'package:hive/hive.dart';

part 'household.g.dart';

@HiveType(typeId: 4)
class Household extends HiveObject {
  @HiveField(0)
  late String id; // Unique household code

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String ownerName; // Person who created the household

  @HiveField(3)
  late DateTime createdAt;

  @HiveField(4)
  List<String> members; // List of member names

  Household({
    required this.id,
    required this.name,
    required this.ownerName,
    DateTime? createdAt,
    List<String>? members,
  })  : createdAt = createdAt ?? DateTime.now(),
        members = members ?? [];

  /// Generate a random household code
  static String generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var code = '';
    var seed = random;

    for (var i = 0; i < 6; i++) {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      code += chars[seed % chars.length];
    }

    return code;
  }
}
