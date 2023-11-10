class Config {
  // static const String apiUrl = 'http://192.168.30.18:3060/';
  static const String apiUrl = 'http://192.168.50.16:3060/';
  // static const String apiUrl = 'https://sois.5lsolutions.com/';
  // static const String apiUrl = 'https://salesinventory.5lsolutions.com/';

  static const String getActiveCategoryAPI = 'mastercategory/getactive';
  static const String getProductAPI = 'product/load';
  static const String getPaymentAPI = 'masterpayment/load';
  static const String sendTransactionAPI = 'salesdetails/save';
  static const String getDetailIDAPI = 'salesdetails/getdetailid';
  static const String loginDAPI = 'login/login';
  static const String posAPI = 'masterpos/getpos';
  static const String storeAPI = 'masterstore/getstore';
  static const String getCustomerCreditAPI = 'customercredit/getcredit';
}
