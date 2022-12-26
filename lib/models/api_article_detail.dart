class APIArticleDetail {
  late String sId;
  late String lastUpdated;
  late String createdOn;
  late String name;
  late String slug;
  late String singularName;
  late List<Fields> fields;

  APIArticleDetail({
    required this.sId,
    required this.lastUpdated,
    required this.createdOn,
    required this.name,
    required this.slug,
    required this.singularName,
    required this.fields,
  });

  APIArticleDetail.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    lastUpdated = json['lastUpdated'];
    createdOn = json['createdOn'];
    name = json['name'];
    slug = json['slug'];
    singularName = json['singularName'];
    if (json['fields'] != null) {
      fields = <Fields>[];
      json['fields'].forEach((v) {
        fields.add(Fields.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['lastUpdated'] = this.lastUpdated;
    data['createdOn'] = this.createdOn;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['singularName'] = this.singularName;
    if (this.fields != null) {
      data['fields'] = this.fields.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Fields {
  late String? name;
  late String? slug;
  late String? type;
  late bool? required;
  late bool? editable;
  late String? helpText;
  late String? id;
  late Validations? validations;
  late bool? unique;
  late bool? defaultData;

  Fields(
      {required this.name,
      required this.slug,
      required this.type,
      required this.required,
      required this.editable,
      required this.helpText,
      required this.id,
      required this.validations,
      required this.unique,
      required this.defaultData});

  Fields.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    slug = json['slug'];
    type = json['type'];
    required = json['required'];
    editable = json['editable'];
    helpText = json['helpText'];
    id = json['id'];
    validations = json['validations'] != null ? Validations.fromJson(json['validations']) : null;
    unique = json['unique'];
    defaultData = json['default'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['type'] = this.type;
    data['required'] = this.required;
    data['editable'] = this.editable;
    data['helpText'] = this.helpText;
    data['id'] = this.id;
    if (this.validations != null) {
      data['validations'] = this.validations!.toJson();
    }
    data['unique'] = this.unique;
    data['default'] = this.defaultData;
    return data;
  }
}

class Validations {
  late bool? singleLine;
  late int? maxLength;
  late Pattern? pattern;
  late Messages? messages;

  Validations({required this.singleLine, required this.maxLength, required this.pattern, required this.messages});

  Validations.fromJson(Map<String, dynamic> json) {
    singleLine = json['singleLine'];
    maxLength = json['maxLength'];
    pattern = json['pattern'] != null ? new Pattern.fromJson(json['pattern']) : null;
    messages = json['messages'] != null ? new Messages.fromJson(json['messages']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['singleLine'] = this.singleLine;
    data['maxLength'] = this.maxLength;
    if (this.pattern != null) {
      data['pattern'] = this.pattern!.toJson();
    }
    if (this.messages != null) {
      data['messages'] = this.messages!.toJson();
    }
    return data;
  }
}

class Pattern {
  Pattern();

  Pattern.fromJson(Map<String, dynamic> json) {}

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    return data;
  }
}

class Messages {
  late String? pattern;
  late String? maxLength;

  Messages({required this.pattern, required this.maxLength});

  Messages.fromJson(Map<String, dynamic> json) {
    pattern = json['pattern'];
    maxLength = json['maxLength'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pattern'] = this.pattern;
    data['maxLength'] = this.maxLength;
    return data;
  }
}
