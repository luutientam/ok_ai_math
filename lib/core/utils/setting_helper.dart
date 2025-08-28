import 'package:flutter/material.dart';
import 'package:flutter_ai_math_2/app.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingHelper {
  static void openStore() async {
    // Replace with your app's actual store link
    final packageInfo = await PackageInfo.fromPlatform();
    final packageName = packageInfo.packageName;
    final url = 'https://play.google.com/store/apps/details?id=$packageName';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Open email client to send feedback using flutter_email_sender
  static Future<void> openFeedbackEmail(BuildContext context) async {
    try {
      final Email email = Email(
        body: Config.bodyFeedback,
        subject: 'Feedback for ${Config.appName}',
        recipients: [Config.emailFeedback],
        isHTML: false,
      );
      await FlutterEmailSender.send(email);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không tìm thấy ứng dụng email phù hợp để gửi phản hồi.',
          ),
        ),
      );
    }
  }

  static void openRateApp(BuildContext context) {
    // RateAppDialog.show(
    //   context,
    //   onRated: (rateStar) {
    //     if (rateStar > 0 && rateStar <= 3) {
    //       openFeedbackEmail(context);
    //     }
    //     if (rateStar > 3 && rateStar <= 5) {
    //       openStore();
    //     }
    //   },
    // );
  }

  static void openPrivacyPolicy() async {
    const url = Config.privacyPolicy;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  static void openTermsOfUse() async {
    const url = Config.termsOfUse;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  static Future<void> openShareApp() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final packageName = packageInfo.packageName;
    final url = 'https://play.google.com/store/apps/details?id=$packageName';
    await SharePlus.instance.share(ShareParams(text: url));
  }
}
