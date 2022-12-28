class Article {
  late List<Items> items;
  late int? count;
  late int? limit;
  late int? offset;
  late int? total;

  Article({
    required this.items,
    required this.count,
    required this.limit,
    required this.offset,
    required this.total,
  });

  Article.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items.add(Items.fromJson(v));
      });
    }
    count = json['count'];
    limit = json['limit'];
    offset = json['offset'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['items'] = items.map((v) => v.toJson()).toList();
    data['count'] = count;
    data['limit'] = limit;
    data['offset'] = offset;
    data['total'] = total;
    return data;
  }
}

class Items {
  late bool bArchived;
  late bool bDraft;
  late bool featured;
  late String name;
  late String postBody;
  late String tags;
  late String postSummary;
  late APIArticleDetailImage? image;
  late APIArticleDetailImage? thumbnailImage;
  late String slug;
  late String updatedOn;
  late String updatedBy;
  late String createdOn;
  late String createdBy;
  late String publishedOn;
  late String publishedBy;
  late String sCid;
  late String sId;
  late String? postBody2;
  late APIArticleDetailImage? image2;

  Items(
      {required this.bArchived,
        required this.bDraft,
        required this.featured,
        required this.name,
        required this.postBody,
        required this.tags,
        required this.postSummary,
        required this.image,
        required this.thumbnailImage,
        required this.slug,
        required this.updatedOn,
        required this.updatedBy,
        required this.createdOn,
        required this.createdBy,
        required this.publishedOn,
        required this.publishedBy,
        required this.sCid,
        required this.sId,
        required this.postBody2,
        required this.image2});

  Items.fromJson(Map<String, dynamic> json) {
    bArchived = json['_archived'];
    bDraft = json['_draft'];
    featured = json['featured'];
    name = json['name'];
    postBody = json['post-body'];
    tags = json['tags'];
    postSummary = json['post-summary'];
    image = json['image'] != null ? new APIArticleDetailImage.fromJson(json['image']) : null;
    thumbnailImage = json['thumbnail-image'] != null ? new APIArticleDetailImage.fromJson(json['thumbnail-image']) : null;
    slug = json['slug'];
    updatedOn = json['updated-on'];
    updatedBy = json['updated-by'];
    createdOn = json['created-on'];
    createdBy = json['created-by'];
    publishedOn = json['published-on'];
    publishedBy = json['published-by'];
    sCid = json['_cid'];
    sId = json['_id'];
    postBody2 = json['post-body-2'];
    image2 = json['image2'] != null ? new APIArticleDetailImage.fromJson(json['image2']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_archived'] = this.bArchived;
    data['_draft'] = this.bDraft;
    data['featured'] = this.featured;
    data['name'] = this.name;
    data['post-body'] = this.postBody;
    data['tags'] = this.tags;
    data['post-summary'] = this.postSummary;
    final image = this.image;
    if (image != null) {
      data['image'] = image.toJson();
    }
    final thumbnailImage = this.thumbnailImage;
    if (thumbnailImage != null) {
      data['thumbnail-image'] = thumbnailImage.toJson();
    }
    data['slug'] = this.slug;
    data['updated-on'] = this.updatedOn;
    data['updated-by'] = this.updatedBy;
    data['created-on'] = this.createdOn;
    data['created-by'] = this.createdBy;
    data['published-on'] = this.publishedOn;
    data['published-by'] = this.publishedBy;
    data['_cid'] = this.sCid;
    data['_id'] = this.sId;
    data['post-body-2'] = this.postBody2;
    final image2 = this.image2;
    if (image2 != null) {
      data['image2'] = image2.toJson();
    }
    return data;
  }
}

class APIArticleDetailImage {
  late String fileId;
  late String url;
  late Null alt;

  APIArticleDetailImage({
    required this.fileId,
    required this.url,
    required this.alt,
  });

  APIArticleDetailImage.fromJson(Map<String, dynamic> json) {
    fileId = json['fileId'];
    url = json['url'];
    alt = json['alt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fileId'] = this.fileId;
    data['url'] = this.url;
    data['alt'] = this.alt;
    return data;
  }
}