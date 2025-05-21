import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
bool first_time=true;

final String baseUrl = "https://l8wlljm3-3099.inc1.devtunnels.ms";
 ValueNotifier<bool?> isNewImageSelected = ValueNotifier<bool?>(false);
String? token;
Future<bool> gettoken()async{
  SharedPreferences prefs=await SharedPreferences.getInstance();
  token=await prefs.getString('token')??"";
  print(token);
  print(token);
  return token==""?false:true;
}
Future<void> savetoken(String token)async{
  print("new token saved");
  print(token);
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
String? selectedShirtId;
String? selectedPantId;
String? selectedShoeId;
String? selectedAccessoryId;
