const defaultLocationId = 1; // Tulum

class Profile {
  String id;
  String? firstName;
  String? familyName;
  String provider;
  String? email;
  String? telephone;
  bool newsMonthly;
  bool newsOffer;
  bool subscriber;
  int locationId;

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