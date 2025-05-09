import 'package:shared_preferences/shared_preferences.dart';

bool first_time=true;
String token="";
Future<bool> gettoken()async{
  SharedPreferences prefs=await SharedPreferences.getInstance();
  token=await prefs.getString('token')??"";
  print(token);
  return token==""?false:true;
}
Future<void> savetoken(String token)async{
  SharedPreferences prefs=await SharedPreferences.getInstance();
  await prefs.setString('token',token);
}