import 'package:flutter/material.dart';
import 'package:sdaemployee/Services/API/Business/business_api.dart';
import 'package:sdaemployee/Services/API/Display/display_api.dart';
import 'package:sdaemployee/Services/API/KYC/kyc_api.dart';
import 'package:sdaemployee/Services/API/Setup/address_api.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
class DialogClass {
  void showCustomDialog({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 16,
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 50,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onPressed ?? () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showLoadingDialog({
    required BuildContext context,
    required bool isLoading,
  }) {
    if (isLoading) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 16,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 20),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<String?> showFullScreenDialog({
    required String module,
    required int id,
    required BuildContext context,
  }) async {
    TextEditingController _controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Enter Reason for Update'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reason:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your reason here...',
                  ),
                ),
                SizedBox(height: 20),
                Center(
                    child: Buttons().updateButton(
                        buttonText: "Send Request",
                        onPressed: () async {
                          try {
                            Map<String, dynamic> res;
                            showLoadingDialog(
                                context: context, isLoading: true);

                            if (module == "Display") {
                              res = await DisplayApi()
                                  .updateRequestDisplay(_controller.text, id);
                            } else if (module == "Address") {
                              res = await AddressApi()
                                  .updateRequestAddress(_controller.text, id);
                            } else if (module == "KYC") {
                              res = await KycApi()
                                  .updateRequestKYC(_controller.text, id);
                            } else {
                              res = await BusinessApi()
                                  .updateRequestBusiness(_controller.text, id);
                            }

                            showLoadingDialog(
                                context: context, isLoading: false);

                            // Close the full-screen dialog first
                            Navigator.of(context).pop();

                            // Show success or error dialog after closing full-screen dialog
                            showCustomDialog(
                              context: context,
                              icon: res['status'] ? Icons.done : Icons.error,
                              title: "Update Request",
                              message: res['message'],
                            );
                          } catch (e) {
                            print(e);
                          }
                        })),
              ],
            ),
          ),
        );
      },
    );
  }
}
