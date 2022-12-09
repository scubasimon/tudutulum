import 'package:tudu/models/deal.dart';
import 'package:tudu/services/firebase/firebase_service.dart';

abstract class DealRepository {
  Future<List<Deal>> getDeals();
}

class DealRepositoryImpl extends DealRepository {

  final FirebaseService _firebaseService = FirebaseServiceImpl();

  @override
  Future<List<Deal>> getDeals() async {
    var results = await _firebaseService.getDeals();
    return results
        .map((e) => Deal.from(e))
        .toList();
  }

}