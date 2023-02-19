import "package:realm/realm.dart";

part 'model.g.dart';

@RealmModel()
class $Car {
  @PrimaryKey()
  late ObjectId id;
  late String make;
  late String model;
  int? kilometers = 500;

  @override
  String toString() {
    return 'id=$id, make=$make, model=$model, kilometers=$kilometers';
  }
}
