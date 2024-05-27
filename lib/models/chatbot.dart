class ChatbotModel {
  int? id;
  int? subCatIndex;
  String? text;
  String? imageText;
  String? subCatKeyString;
  String? subCatValueString;
  bool? toClick;
  bool? subCatClick;
  bool? imageShow;
  bool? showResult;
  List<String>? options;
  Iterable<String>? subCategoryKey;
  Iterable<String>? subCategoryValues;

  ChatbotModel();

  ChatbotModel.addItem(this.id, this.text, [this.imageShow, this.imageText]);

  ChatbotModel.options(this.id, this.options, this.toClick);

  ChatbotModel.subCategory(this.id, this.subCategoryKey, this.subCategoryValues, this.subCatClick);

  ChatbotModel.userSubCategory(this.id, this.subCatKeyString, this.subCatValueString, this.subCatClick);

  ChatbotModel.addResut(this.id, this.text, this.showResult);

}