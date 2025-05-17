import 'package:shared_preferences/shared_preferences.dart';
bool first_time=true;
// final String baseUrl = "https://zqxct4xv-3099.inc1.devtunnels.ms";
final String baseUrl = "http://147.93.47.17:3099";

String token="";
Future<bool> gettoken()async{
  SharedPreferences prefs=await SharedPreferences.getInstance();
  token=await prefs.getString('token')??"";
  print(token);
  print(token);
  return token==""?false:true;
}
Future<void> savetoken(String token)async{
  SharedPreferences prefs=await SharedPreferences.getInstance();
  await prefs.setString('token',token);
}
String url="";
Future<void> remove()async {
  SharedPreferences prefs=await SharedPreferences.getInstance();
  await prefs.remove('token');
}
int avatarindex=0;
int storedindex=0;