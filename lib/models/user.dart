const defaultLocationId = 1; // Tulum

class Profile {
  late String id;
  String? firstName;
  String? familyName;
  late String provider;
  String? email;
  String? telephone;
  bool newsMonthly = false;
  bool newsOffer = false;
  bool subscriber = false;
  int locationId = defaultLocationId;

  Profile(
      this.id,
      this.provider,
      {
        this.firstName,
        this.familyName,
        this.email,
        this.telephone,
        this.newsMonthly = false,
        this.newsOffer = false,
        this.subscriber = false,
        this.locationId = defaultLocationId,
      });

  Profile.from(Map<String, dynamic> json) {
    id = json["userUID"] as String;
    provider = json["provider"] as String;
    email = json["email"] as String?;
    telephone = json["telephone"] as String?;
    firstName = json["firstName"] as String?;
    familyName = json["familyName"] as String?;
    newsMonthly = (json["newsMonthly"] as bool?) ?? false;
    newsOffer = (json["newsOffer"] as bool?) ?? false;
    subscriber = (json["subscriber"] as bool?) ?? false;
    locationId = (json["locationId"] as int?) ?? defaultLocationId;
  }

  // Profile(Map<String, dynamic> json) {
  //   id = json["userUID"] as String;
  //   provider = json["provider"] as String;
  //   email = json["email"] as String?;
  //   telephone = json["telephone"] as String?;
  //   firstName = json["firstName"] as String?;
  //   familyName = json["familyName"] as String?;
  //   newsMonthly = (json["newsMonthly"] as bool?) ?? false;
  //   newsOffer = (json["newsOffer"] as bool?) ?? false;
  //   subscriber = (json["subscriber"] as bool?) ?? false;
  //   locationId = (json["locationId"] as int?) ?? defaultLocationId;
  // }

  Map<String, dynamic> toJson() => {
    "userUID": id,
    "firstName": firstName,
    "familyName": familyName,
    "provider": provider,
    "email": email,
    "telephone": telephone,
    "newsMonthly": newsMonthly,
    "newsOffer": newsOffer,
    "subscriber": subscriber,
    "locationId": locationId
  };

}