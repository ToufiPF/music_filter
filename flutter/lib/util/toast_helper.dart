import 'package:fluttertoast/fluttertoast.dart';

class ToastHelper {
  static Future<void> showMessage(String msg, {bool longToast = false}) async {
    await Fluttertoast.showToast(
        msg: msg,
        toastLength: longToast ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT);
  }

  static Future<void> showMessageWithCancel(String msg,
      {bool longToast = false}) async {
    await Fluttertoast.cancel();
    await showMessage(msg, longToast: longToast);
  }

  ToastHelper._();
}
