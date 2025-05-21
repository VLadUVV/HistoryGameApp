class User {
  int Id;
  String name;
  String email;
  String password;

  User({
    required this.Id,
    required this.name,
    required this.email,
    required this.password,
});
  Map<String, dynamic> toMap(){
    return {
      'Id' : Id,
      'name' : name,
      'email' : email,
      'password' : password,
    };
  }
  factory User.fromMap(Map<String, dynamic> map){
    return User(
      Id : map['Id'],
      name : map['name'],
      email : map['email'],
      password: map['password'],
    );
  }
  }