import 'package:tudu/models/business.dart';
import 'package:tudu/utils/func_utils.dart';

import '../../models/amenity.dart';
import '../../models/partner.dart';
import '../../models/site.dart';
import '../../services/firebase/firebase_service.dart';

abstract class HomeRepository {
  Future<List<Partner>> getListPartners();
  Future<List<Amenity>> getListAmenities();
  Future<List<Business>> getListBusinesses();
}

class HomeRepositoryImpl extends HomeRepository {
  final FirebaseService _firebaseService = FirebaseServiceImpl();

  @override
  Future<List<Partner>> getListPartners() async {
    List<Partner> listPartners = [];
    var listRemotePartners = await _firebaseService.getPartners();
    if (listRemotePartners != null) {
      for (var remotePartner in listRemotePartners) {
        listPartners.add(
            Partner(
              partnerId: remotePartner["partnerId"],
              icon: remotePartner["icon"],
              link: remotePartner["link"],
              name: remotePartner["name"],
            )
        );
      }
    }
    return listPartners;
  }

  @override
  Future<List<Amenity>> getListAmenities() async {
    List<Amenity> listAmenites = [];
    var listRemoteAmenites = await _firebaseService.getAmenities();
    if (listRemoteAmenites != null) {
      for (var remoteAmenity in listRemoteAmenites) {
        listAmenites.add(
            Amenity(
              amenitiyId: remoteAmenity["amenityId"],
              title: remoteAmenity["title"],
              description: remoteAmenity["description"],
              icon: remoteAmenity["icon"],
            )
        );
      }
    }
    return listAmenites;
  }

  @override
  Future<List<Business>> getListBusinesses() async {
    List<Business> listBusiness = [];
    var listRemoteBusiness = await _firebaseService.getBusinesses();
    if (listRemoteBusiness != null) {
      for (var remoteBusiness in listRemoteBusiness) {
        listBusiness.add(
            Business(
              businessid: remoteBusiness["businessid"],
              locationid: remoteBusiness["locationid"],
              type: remoteBusiness["type"],
            )
        );
      }
    }
    return listBusiness;
  }
}