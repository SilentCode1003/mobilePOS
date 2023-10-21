class ProductModel {
  final String id;
  final String categoryid;
  final String description;
  final String image;
  final String barcode;
  final double price;
  final int status;
  final int createdby;
  final int createddate;

  ProductModel(
    this.id,
    this.categoryid,
    this.description,
    this.image,
    this.barcode,
    this.price,
    this.status,
    this.createdby,
    this.createddate,
  );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      json['id'],
      json['categoryid'],
      json['description'],
      json['image'],
      json['barcode'],
      json['price'],
      json['status'],
      json['createdby'],
      json['createddate'],
    );
  }
}
