import 'package:flutter/material.dart';

class UIHelper {
  static void showLoadingDailog(BuildContext context, String title) {
    AlertDialog loadingDailog = AlertDialog(
      content: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(
              height: 30,
            ),
            Text(title)
          ],
        ),
      ),
    );

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return loadingDailog;
        });
  }

  static void showAlertDailog(
      BuildContext context, String title, String contant) {
    AlertDialog alertDailog = AlertDialog(
      title: Text(title),
      content: Text(contant),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Ok"))
      ],
    );

    showDialog(
        context: context,
        builder: (context) {
          return alertDailog;
        });
  }
}
