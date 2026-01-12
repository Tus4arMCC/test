class AddressModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String houseNo;
  final String addressLine;
  final String town;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.houseNo,
    required this.addressLine,
    required this.town,
    required this.city,
    required this.state,
    required this.pincode,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['code']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? json['fullName'] ?? '',
      phone: json['phone'] ?? json['mobile'] ?? '',
      email: json['email'] ?? '',
      houseNo: json['houseNo'] ?? json['flat'] ?? '',
      addressLine: json['address'] ?? json['addressLine'] ?? '',
      town: json['town'] ?? '',
      city: json['city'] ?? json['district'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode']?.toString() ?? '',
      isDefault: json['isDefault'] == true || json['default'] == true,
    );
  }
}
