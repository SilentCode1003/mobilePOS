class EmployeeModel {
  final int id;
  final int employeeid;
  final String fullname;
  final String username;
  final String password;
  final double accessid;
  final String status;
  final String createdby;
  final String createddate;

  EmployeeModel(
    this.id,
    this.employeeid,
    this.fullname,
    this.username,
    this.password,
    this.accessid,
    this.status,
    this.createdby,
    this.createddate,
  );

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      json['id'],
      json['employeeid'],
      json['fullname'],
      json['username'],
      json['password'],
      json['accessid'],
      json['status'],
      json['createdby'],
      json['createddate'],
    );
  }
}
