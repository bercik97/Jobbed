class User {
  String id;
  String role;
  String username;
  String info;
  String nationality;
  String companyName;
  String authHeader;

  User();

  User create(Map<String, String> data) {
    id = data['id'];
    role = data['role'];
    username = data['username'];
    info = data['info'];
    nationality = data['nationality'];
    companyName = data['companyName'];
    authHeader = data['authorization'];
    return this;
  }
}
