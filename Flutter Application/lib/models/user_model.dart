class UserModel {
  String id;
  String exp;
  double totalCost;
  double enterFee;
  double tentRental;
  double house;
  double campingFee;
  String campsite;
  final String name;
  final String email;
  List<String> tag; // เพิ่มตัวแปร tag ที่เป็น array
  String background;
  String avatar;

  UserModel(
      {required this.id,
      required this.exp,
      required this.name,
      required this.email,
      required this.tag,
      required this.campingFee,
      required this.campsite,
      required this.enterFee,
      required this.house,
      required this.tentRental,
      required this.totalCost,
      required this.background,
      required this.avatar}); // ปรับ constructor

  factory UserModel.fromMap(Map<String, dynamic>? user) {
    if (user != null) {
      String id = user['id'];
      String exp = user['exp'];
      String name = user['name'];
      String email = user['email'];
      double totalCost = user['totalCost'];
      double enterFee = user['enterFee'];
      double tentRental = user['tentRental'];
      double house = user['house'];
      double campingFee = user['campingFee'];
      String campsite = user['campsite'];
      List<String> tag =
          List<String>.from(user['tag'] ?? []); // แปลง tag เป็น List<String>
      String background = user['background'];
      String avatar = user['avatar'];
      return UserModel(
          id: id,
          exp: exp,
          name: name,
          email: email,
          tag: tag,
          campingFee: campingFee,
          campsite: campsite,
          enterFee: enterFee,
          house: house,
          tentRental: tentRental,
          totalCost: totalCost,
          background: background,
          avatar: avatar);
    } else {
      throw ArgumentError('Unexpected type for user');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exp': exp,
      'name': name,
      'email': email,
      'tag': tag, // เพิ่ม tag ใน toMap
      'campingFee': campingFee,
      'campsite': campsite,
      'enterFee': enterFee,
      'house': house,
      'tentRental': tentRental,
      'totalCost': totalCost,
      'background': background,
      'avatar': avatar
    };
  }

  Map<String, dynamic> toJson() {
    print(
        'Converting UserModel to JSON with exp: $exp'); // พิมพ์ค่า exp ก่อนแปลงเป็น JSON
    return {
      'id': id,
      'exp': exp, // ตรวจสอบว่ามีค่าถูกต้อง
      'name': name,
      'email': email,
      'tag': tag, // เพิ่ม tag ใน toJson
      'campingFee': campingFee,
      'campsite': campsite,
      'enterFee': enterFee,
      'house': house,
      'tentRental': tentRental,
      'totalCost': totalCost,
      'background': background,
      'avatar': avatar,
    };
  }
}
