import 'package:flutter/material.dart';

class AppState with ChangeNotifier{
  bool _isAdUploaded = false;
  
  bool getAdUpload (){
    return _isAdUploaded;
  }

  void setIsAdUpload(bool value){
    _isAdUploaded = value;
    notifyListeners();
  }
}
