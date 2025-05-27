import 'package:fitlip_app/view/Utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

Future<bool> checkInternetAndShowDialog(BuildContext context) async {
  var connectivityResult = await Connectivity().checkConnectivity();
  bool isConnected = await InternetConnectionChecker.instance.hasConnection;
  if (connectivityResult == ConnectivityResult.none || !isConnected) {
    showDialog(

      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title:  Text('No Internet',style: TextStyle(color: appcolor,fontWeight: FontWeight.w700,fontSize: 20),),
        content:  Text(
          'Please check your internet connection. It is either off or too weak.',style: TextStyle(color: appcolor,fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child:  Text('OK',style: TextStyle(color: appcolor,fontWeight: FontWeight.bold,fontSize: 15),),
          ),
        ],
      ),
    );

    return false;
  }

  return true;
}
