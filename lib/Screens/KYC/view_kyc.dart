import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/KYC/apply_kyc.dart';
import 'package:sdaemployee/Services/API/KYC/kyc_api.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/Section.dart';

// ignore: must_be_immutable
class ViewKyc extends StatefulWidget {
  Map<String,dynamic> user;
   ViewKyc({required this.user, super.key});

  @override
  State<ViewKyc> createState() => _ViewKycState();
}

class _ViewKycState extends State<ViewKyc> {
  Map<String, dynamic> kyc = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchKYCOfUser();
    });
  }

  void fetchKYCOfUser() async {
    try {
    
      Map<String, dynamic> res = await KycApi().fetchKYCOfUser(widget.user['user_id']);
    

      if (!mounted) return; // Check if the widget is still mounted

      if (res['status']) {
        if (res['kyc'].isEmpty) {
          ScreenRouter.replaceScreen(context, KYC (user:widget.user, isUpdate: false));
        } else {
          setState(() {
            isLoading = false;
            kyc = res['kyc'][0];
          });
        }
      } else {
        DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "KYC",
          message: res['message'],
        );
      }
    } catch (e) {
      if (!mounted) return; // Check if the widget is still mounted
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Error",
        message: "Something Went Wrong",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarClass().buildSubScreenAppBar(context, "KYC Details"),
      body: isLoading
          ? Expanded(
              child: ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return Section().buildShimmerList(100, 60, 5);
                },
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Section().buildSectionTitle("Document Details"),
                  Section().builButtonCard(
                    [
                      Section().buildDetailRow("Aadhar Number", kyc['adhar_no'],
                          Icons.credit_card, Colors.blue),
                      Section().buildDetailRow("PAN Number", kyc['pan_no'],
                          Icons.account_balance_wallet, Colors.deepPurple),
                      Section().buildDetailRow("Account Holder Name",
                          kyc['acc_holder_name'], Icons.person, Colors.green),
                      Section().buildDetailRow("Account Number", kyc['acc_no'],
                          Icons.numbers, Colors.orange),
                      Section().buildDetailRow("Bank IFSC", kyc['bank_ifsc'],
                          Icons.confirmation_number, Colors.red),
                      Section().buildDetailRow("Bank Name", kyc['bank_name'],
                          Icons.account_balance, Colors.teal),
                      Section().buildDetailRow(
                          "Branch Name",
                          kyc['bank_branch_name'],
                          Icons.location_on,
                          Colors.pink),
                      Section().buildDetailRow(
                          "KYC Status",
                          kyc['kyc_status'],
                          Icons.verified_user,
                          kyc['kyc_status'] == "Verified"
                              ? Colors.green
                              : Colors.red),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Section().buildSectionTitle("Uploaded Documents"),
                  Section().builButtonCard([
                    _buildDocumentRow(
                        "Aadhar Front Image", kyc['adhar_front_img']),
                    _buildDocumentRow(
                        "Aadhar Back Image", kyc['adhar_back_img']),
                    _buildDocumentRow("PAN Image", kyc['pan_img']),
                    _buildDocumentRow(
                        "Bank Proof Image", kyc['bank_proof_img']),
                  ]),
                  const SizedBox(height: 30),
                   kyc['update_request'] == "Accepted"?Buttons().actionButton(title: "Update KYC",onPressed: () {
                        ScreenRouter.replaceScreen(
                          context,
                          KYC(
                            user: widget.user,
                            adharCardNo: kyc['adhar_no'],
                            panNo: kyc['pan_no'],
                            accHolderName: kyc['acc_holder_name'],
                            accNo: kyc['acc_no'],
                            bankIfsc: kyc['bank_ifsc'],
                            bankName: kyc['bank_name'],
                            bankBranchName: kyc['bank_branch_name'],
                            isUpdate: true,
                          ),
                        );
                      },color: Colors.teal):kyc['update_request'] == "Submitted"?Text(
                            "Update Request Submitted",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple),
                          ):Buttons().actionButton(
                            title: "Request Update",
                            color: Colors.purpleAccent,
                            onPressed: () async {
                              await DialogClass().showFullScreenDialog(
                                  context: context,
                                  module: "KYC",
                                  id:kyc['kyc_id'],);
                            }),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildDocumentRow(String label, String? imageUrl) {
    return ListTile(
      leading: const Icon(Icons.image, color: Colors.teal),
      title: Text(label),
      subtitle: imageUrl != null
          ? ElevatedButton.icon(
              onPressed: () {
                _viewImage(imageUrl);
              },
              icon: const Icon(Icons.image),
              label: const Text("View Image"),
            )
          : const Text("No Image Available"),
    );
  }

  void _viewImage(String imageUrl) {
    // You can add code here to view the image
  }
}
