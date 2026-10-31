import 'dart:convert';
import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:serverpod/serverpod.dart' hide Message;

/// Service for sending transactional emails (Registration OTP, Password Reset,
/// Order Receipts, and VIP Concierge notifications) using HTTPS Port 443 relay
/// and Gmail SMTP fallback.
class EmailService {
  static const String senderEmailDefault = 'uabdullahi676@gmail.com';
  static const String fallbackAppPassword = 'pqadrynmtgfenttd';
  static const String senderName = 'Al-Nur Modest Haute Couture';

  static const String relayUrl = 'https://al-nur-tau.vercel.app/api/send-email';
  static const String relaySecret = 'alnur_luxury_vault_2026';

  /// Dispatches email over HTTPS Port 443 REST relay to bypass container firewall blocks
  static Future<bool> _dispatchViaHttpsRelay(
    Session session, {
    required String toEmail,
    required String subject,
    required String htmlBody,
  }) async {
    HttpClient? httpClient;
    try {
      httpClient = HttpClient()..connectionTimeout = const Duration(seconds: 8);
      final request = await httpClient.postUrl(Uri.parse(relayUrl)).timeout(
        const Duration(seconds: 8),
      );
      request.headers.contentType = ContentType.json;

      final payload = jsonEncode({
        'key': relaySecret,
        'to': toEmail,
        'subject': subject,
        'html': htmlBody,
      });

      request.write(payload);
      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );

      final responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        final decoded = jsonDecode(responseBody);
        if (decoded is Map && decoded['success'] == true) {
          session.log(
            '[EmailService] ✅ Email dispatched successfully via HTTPS Port 443 relay to $toEmail',
          );
          return true;
        }
      }
      session.log(
        '[EmailService] ⚠️ Relay returned status ${response.statusCode}: $responseBody',
      );
      return false;
    } catch (e) {
      session.log(
        '[EmailService] ⚠️ HTTPS relay notice: $e. Falling back to direct SMTP...',
      );
      return false;
    } finally {
      httpClient?.close();
    }
  }

  /// Retrieves the configured SMTP App Password from Serverpod passwords.yaml
  /// or environment variable fallback, with safe production default.
  static String? getAppPassword(Session session) {
    // 1. Check passwords.yaml
    final pwd = session.passwords['smtpAppPassword']?.trim();
    if (pwd != null &&
        pwd.isNotEmpty &&
        pwd != 'your-16-char-app-password-here') {
      return pwd.replaceAll(' ', '');
    }

    // 2. Fallback to environment variable
    final envPwd =
        Platform.environment['GMAIL_APP_PASSWORD']?.trim() ??
        Platform.environment['SMTP_APP_PASSWORD']?.trim();
    if (envPwd != null && envPwd.isNotEmpty) {
      return envPwd.replaceAll(' ', '');
    }

    // 3. Fallback to configured boutique app password so cloud & container runtimes
    // reliably dispatch transactional OTPs and welcome letters.
    return fallbackAppPassword;
  }

  /// Retrieves the sender email address.
  static String getSenderEmail(Session session) {
    return session.passwords['smtpEmail']?.trim() ?? senderEmailDefault;
  }

  /// Sends a registration email verification OTP.
  static Future<bool> sendRegistrationOtp(
    Session session, {
    required String email,
    required String code,
  }) async {
    const subject = '🔐 Verify Your Al-Nur Modest Store Account';
    final htmlContent = _buildOtpEmailHtml(
      title: 'Welcome to Al-Nur Store',
      subtitle: 'Complete your account verification',
      greeting: 'Assalamu alaykum wa rahmatullah,',
      description:
          'Thank you for joining Al-Nur Store, your premier sanctuary for luxury Rings, Royal Arabian Perfumes, Fine Jewelry, Wedding Rings, and Swiss-grade Wristwatches. Please enter the verification code below to activate your account:',
      otpCode: code,
      actionNote:
          'This verification code is valid for 15 minutes. For your protection, never share this code with anyone.',
    );

    return await _sendEmail(
      session,
      toEmail: email,
      subject: subject,
      htmlBody: htmlContent,
      fallbackType: 'Registration OTP ($code)',
    );
  }

  /// Sends a password reset verification code.
  static Future<bool> sendPasswordResetOtp(
    Session session, {
    required String email,
    required String code,
  }) async {
    const subject = '🔑 Reset Your Al-Nur Account Password';
    final htmlContent = _buildOtpEmailHtml(
      title: 'Password Reset Request',
      subtitle: 'Secure your Al-Nur Store access',
      greeting: 'Assalamu alaykum wa rahmatullah,',
      description:
          'We received a request to reset the password for your Al-Nur Store account. Enter the authorization code below in the mobile application to set your new password:',
      otpCode: code,
      actionNote:
          'If you did not request this password reset, please disregard this email or contact concierge support immediately.',
    );

    return await _sendEmail(
      session,
      toEmail: email,
      subject: subject,
      htmlBody: htmlContent,
      fallbackType: 'Password Reset OTP ($code)',
    );
  }

  /// Sends general notification / order receipt email.
  static Future<bool> sendNotificationEmail(
    Session session, {
    required String toEmail,
    required String recipientName,
    required String subject,
    required String headerTitle,
    required String messageHtml,
  }) async {
    final htmlContent = _buildGeneralEmailHtml(
      title: headerTitle,
      recipientName: recipientName,
      messageHtml: messageHtml,
    );

    return await _sendEmail(
      session,
      toEmail: toEmail,
      subject: subject,
      htmlBody: htmlContent,
      fallbackType: 'Notification Email',
    );
  }

  /// Dispatches branded status lifecycle emails for all 5 fulfillment stages:
  /// 1. Order Placed & Confirmed
  /// 2. Processing & Handcrafted Tailoring
  /// 3. Shipped & Handed to Courier
  /// 4. Out for Delivery
  /// 5. Delivered
  static Future<bool> sendOrderStatusEmail(
    Session session, {
    required String orderRef,
    required String customerEmail,
    required String customerName,
    required String shippingAddress,
    required double totalAmount,
    required String canonicalStatus,
  }) async {
    final status = canonicalStatus.toLowerCase().trim();
    int currentStep = 1;
    String stageNumber = '1';
    String stageTitle = 'Order Placed & Confirmed';
    String subjectPrefix = '✨';
    String description =
        'Your order has been officially confirmed and registered in our artisanal atelier. Our tailoring team is preparing your garments.';

    if (status.contains('cancel')) {
      currentStep = 0;
      stageNumber = '✕';
      stageTitle = 'Order Cancelled';
      subjectPrefix = '⚠️';
      description =
          'Your order has been cancelled. If this was unexpected or you require assistance, please contact our VIP Concierge support.';
    } else if (status.contains('deliver')) {
      currentStep = 5;
      stageNumber = '5';
      stageTitle = 'Delivered';
      subjectPrefix = '🎉';
      description =
          'Alhamdulillah! Your haute couture parcel has been successfully delivered and signed for. May Allah shower barakah and modesty upon your home.';
    } else if (status.contains('out_for_delivery') || status.contains('transit')) {
      currentStep = 4;
      stageNumber = '4';
      stageTitle = 'Out for Delivery';
      subjectPrefix = '🚚';
      description =
          'Our dispatch courier rider is actively en route heading towards your delivery address. Please ensure your contact phone is available for handover.';
    } else if (status.contains('ship') || status.contains('dispatch') || status.contains('courier')) {
      currentStep = 3;
      stageNumber = '3';
      stageTitle = 'Shipped & Handed to Courier';
      subjectPrefix = '📦';
      description =
          'Your modest garments have been inspected, sealed in our signature gold-foil heirloom box, and handed over to our trusted courier partner.';
    } else if (status.contains('process') || status.contains('tailor') || status.contains('craft')) {
      currentStep = 2;
      stageNumber = '2';
      stageTitle = 'Processing & Handcrafted Tailoring';
      subjectPrefix = '✂️';
      description =
          'Our master artisans and tailors have commenced cutting, stitching, and handcrafted embellishment on your bespoke couture.';
    }

    final subject = '$subjectPrefix Al-Nur Order #$orderRef: $stageTitle';
    final recipient = customerName.trim().isNotEmpty ? customerName.trim() : 'Valued Patron';

    // Build the visual 5-step progress stepper
    final steps = [
      {'num': '1', 'name': 'Placed'},
      {'num': '2', 'name': 'Tailoring'},
      {'num': '3', 'name': 'Shipped'},
      {'num': '4', 'name': 'Delivery'},
      {'num': '5', 'name': 'Delivered'},
    ];

    final stepperHtml = StringBuffer();
    stepperHtml.write('<table style="width:100%;border-collapse:collapse;margin:24px 0 16px;"><tr>');
    for (int i = 0; i < steps.length; i++) {
      final stepIndex = i + 1;
      final step = steps[i];
      final isCompleted = currentStep > stepIndex;
      final isCurrent = currentStep == stepIndex;

      String circleBg;
      String circleColor;
      String circleBorder;
      String circleContent;

      if (isCompleted) {
        circleBg = '#0B291E';
        circleColor = '#FFFFFF';
        circleBorder = '2px solid #C87A1E';
        circleContent = '✓';
      } else if (isCurrent) {
        circleBg = '#C87A1E';
        circleColor = '#FFFFFF';
        circleBorder = '2px solid #2E110A';
        circleContent = step['num']!;
      } else {
        circleBg = '#F3F4F6';
        circleColor = '#9CA3AF';
        circleBorder = '2px solid #E5E7EB';
        circleContent = step['num']!;
      }

      final labelColor = isCurrent ? '#C87A1E' : (isCompleted ? '#0B291E' : '#9CA3AF');
      final fontWeight = (isCurrent || isCompleted) ? 'bold' : 'normal';

      stepperHtml.write('''
        <td style="text-align:center;width:20%;vertical-align:top;padding:0 2px;">
          <div style="width:30px;height:30px;border-radius:50%;margin:0 auto;line-height:30px;font-size:12px;font-weight:bold;background:$circleBg;color:$circleColor;border:$circleBorder;text-align:center;">
            $circleContent
          </div>
          <div style="font-size:10px;font-weight:$fontWeight;color:$labelColor;margin-top:6px;line-height:1.2;">
            \${step['name']}
          </div>
        </td>
      ''');
    }
    stepperHtml.write('</tr></table>');

    final messageHtml = '''
      <div style="background:#FAF7F2;border:1px solid #E5A83B;border-radius:14px;padding:18px 20px;margin-bottom:20px;">
        <span style="font-size:11px;font-weight:700;color:#C87A1E;text-transform:uppercase;letter-spacing:1px;display:block;margin-bottom:4px;">Current Order Stage</span>
        <div style="font-size:18px;font-weight:800;color:#2E110A;margin-bottom:8px;">
          $stageNumber. $stageTitle
        </div>
        <p style="margin:0;font-size:13px;color:#4B5563;line-height:1.6;">$description</p>
      </div>

      $stepperHtml

      <div style="background:#FFFFFF;border:1px solid #E5E7EB;border-radius:12px;padding:18px 20px;margin:20px 0;">
        <div style="font-size:11px;font-weight:700;color:#6B7280;text-transform:uppercase;letter-spacing:1px;margin-bottom:12px;border-bottom:1px solid #F3F4F6;padding-bottom:6px;">Order Details</div>
        <table style="width:100%;font-size:13px;color:#374151;border-collapse:collapse;">
          <tr>
            <td style="padding:6px 0;color:#6B7280;">Order Reference:</td>
            <td style="padding:6px 0;text-align:right;font-family:monospace;font-weight:bold;color:#2E110A;">$orderRef</td>
          </tr>
          <tr>
            <td style="padding:6px 0;color:#6B7280;">Total Amount:</td>
            <td style="padding:6px 0;text-align:right;font-weight:bold;color:#059669;">₦\${totalAmount.toStringAsFixed(0)}</td>
          </tr>
          <tr>
            <td style="padding:6px 0;color:#6B7280;vertical-align:top;">Shipping Address:</td>
            <td style="padding:6px 0;text-align:right;color:#374151;max-width:240px;">$shippingAddress</td>
          </tr>
        </table>
      </div>

      <p style="font-size:12px;color:#6B7280;margin-top:20px;text-align:center;line-height:1.6;">
        For questions or VIP styling requests, reply directly to this email or contact our WhatsApp Concierge.<br>
        <strong>Al-Nur Modest Haute Couture • Sealed with Modesty & Barakah</strong>
      </p>
    ''';

    return await sendNotificationEmail(
      session,
      toEmail: customerEmail,
      recipientName: recipient,
      subject: subject,
      headerTitle: 'Order Update: $orderRef',
      messageHtml: messageHtml,
    );
  }

  /// Sends a branded luxury welcome email to newly registered patrons.
  static Future<bool> sendWelcomeEmail(
    Session session, {
    required String email,
    String? name,
  }) async {
    final customerName = (name != null && name.trim().isNotEmpty) ? name.trim() : 'Valued Patron';
    const subject = '✨ Ahlan wa Sahlan! Welcome to Al-Nur Haute Couture';
    final htmlContent = _buildGeneralEmailHtml(
      title: 'Welcome to Al-Nur Modest Haute Couture',
      recipientName: customerName,
      messageHtml: '''
        <p style="margin-bottom:16px;">Assalamu alaykum wa rahmatullah wa barakatuh,</p>
        <p style="margin-bottom:16px;">We are honored to welcome you into the <strong>Al-Nur Luxury Family</strong>. Your membership grants you premier access to our artisanal Moroccan Jalabias, bespoke Abayas, Royal Arabian Ouds, Bridal Jewelry, and Swiss-grade timepieces.</p>
        
        <div style="background:#FAF7F2;padding:20px;border-radius:14px;border:1px solid #E5A83B;margin:24px 0;text-align:center;">
          <span style="font-size:11px;font-weight:700;color:#C87A1E;text-transform:uppercase;letter-spacing:1.5px;display:block;margin-bottom:6px;">Your Member Welcome Privilege</span>
          <div style="font-size:20px;font-weight:800;color:#2E110A;letter-spacing:3px;font-family:monospace;padding:10px 16px;background:#FFFFFF;border-radius:8px;border:1px dashed #C87A1E;display:inline-block;margin:6px 0;">
            ALNUR-VIP-2026
          </div>
          <p style="font-size:12px;color:#8F581B;margin:8px 0 0;">Enjoy complimentary express logistics courier delivery on your first haute couture order.</p>
        </div>

        <p style="margin-bottom:14px;"><strong>Your Exclusive Member Privileges:</strong></p>
        <ul style="color:#4B5563;font-size:13px;padding-left:20px;margin-bottom:20px;line-height:1.8;">
          <li>Direct WhatsApp VIP Concierge styling and custom tailoring reservations.</li>
          <li>Real-time parcel tracking with sealed gold-foil heirloom unboxing.</li>
          <li>Private invitations to our limited Ramadan & Eid seasonal couture collections.</li>
        </ul>

        <p style="color:#6B7280;font-size:12px;margin-top:24px;">May Allah shower your home with barakah, modesty, and timeless elegance.</p>
      ''',
    );

    return await _sendEmail(
      session,
      toEmail: email,
      subject: subject,
      htmlBody: htmlContent,
      fallbackType: 'Welcome Email',
    );
  }

  /// Core email dispatcher via HTTPS Port 443 relay with Gmail SMTP fallback.
  static Future<bool> _sendEmail(
    Session session, {
    required String toEmail,
    required String subject,
    required String htmlBody,
    required String fallbackType,
  }) async {
    // 1. Primary: HTTPS Port 443 Relay (Bypasses Serverpod Cloud GCP port 465/587 blocks)
    final relaySuccess = await _dispatchViaHttpsRelay(
      session,
      toEmail: toEmail,
      subject: subject,
      htmlBody: htmlBody,
    );
    if (relaySuccess) {
      return true;
    }

    // 2. Direct SMTP Fallback (for local development or when relay is unreachable)
    final senderEmail = getSenderEmail(session);
    final appPassword = getAppPassword(session);

    if (appPassword == null || appPassword.isEmpty) {
      session.log(
        '[EmailService] ✉️ [LOCAL DEV LOG] $fallbackType -> $toEmail\n'
        '  Subject: $subject\n'
        '  Notice: Gmail SMTP is awaiting App Password in config/passwords.yaml (smtpAppPassword).',
      );
      return true;
    }

    try {
      // 1. Primary: Direct SSL on port 465 (Reliable in cloud containers & data centers)
      final smtpServer = SmtpServer(
        'smtp.gmail.com',
        port: 465,
        ssl: true,
        username: senderEmail,
        password: appPassword,
      );

      final message = Message()
        ..from = Address(senderEmail, senderName)
        ..recipients.add(toEmail)
        ..subject = subject
        ..html = htmlBody;

      final sendReport = await send(message, smtpServer).timeout(
        const Duration(seconds: 12),
      );
      session.log(
        '[EmailService] ✅ Email sent successfully via Port 465 SSL to $toEmail (SMTP: ${sendReport.toString()})',
      );
      return true;
    } catch (e, stack) {
      session.log(
        '[EmailService] ⚠️ Port 465 attempt notice: $e. Retrying Port 587 STARTTLS...',
      );
      try {
        final smtpServer587 = SmtpServer(
          'smtp.gmail.com',
          port: 587,
          ssl: false,
          username: senderEmail,
          password: appPassword,
        );

        final message = Message()
          ..from = Address(senderEmail, senderName)
          ..recipients.add(toEmail)
          ..subject = subject
          ..html = htmlBody;

        final sendReport = await send(message, smtpServer587).timeout(
          const Duration(seconds: 8),
        );
        session.log(
          '[EmailService] ✅ Email sent successfully via Port 587 to $toEmail (SMTP: ${sendReport.toString()})',
        );
        return true;
      } catch (err) {
        session.log(
          '[EmailService] ❌ Failed to dispatch email via Gmail SMTP: $err\n$stack',
          level: LogLevel.error,
        );
        // Log fallback code so registration/reset is not blocked if Google temporarily limits
        session.log(
          '[EmailService] ⚠️ Fallback delivery reference: $fallbackType to $toEmail',
        );
        return false;
      }
    }
  }

  /// Builds a luxury gold & emerald responsive HTML template for OTP verification.
  static String _buildOtpEmailHtml({
    required String title,
    required String subtitle,
    required String greeting,
    required String description,
    required String otpCode,
    required String actionNote,
  }) {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$title</title>
  <style>
    body {
      margin: 0;
      padding: 0;
      background-color: #F8F9FA;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
      color: #1F2937;
      line-height: 1.6;
    }
    .wrapper {
      width: 100%;
      background-color: #F8F9FA;
      padding: 30px 15px;
    }
    .container {
      max-width: 560px;
      margin: 0 auto;
      background: #FFFFFF;
      border-radius: 18px;
      overflow: hidden;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
      border: 1px solid #E5E7EB;
    }
    .header {
      background: linear-gradient(135deg, #0B291E 0%, #164E3A 100%);
      padding: 36px 30px 28px;
      text-align: center;
      color: #FFFFFF;
    }
    .brand-crest {
      font-size: 26px;
      margin-bottom: 6px;
    }
    .brand-title {
      font-family: 'Cinzel', Georgia, serif;
      font-size: 24px;
      letter-spacing: 2px;
      font-weight: 700;
      color: #D4AF37;
      margin: 0;
    }
    .brand-tagline {
      font-size: 11px;
      letter-spacing: 1.5px;
      text-transform: uppercase;
      color: #E2E8F0;
      margin-top: 4px;
      opacity: 0.9;
    }
    .content {
      padding: 36px 32px 28px;
    }
    .greeting {
      font-size: 15px;
      font-weight: 600;
      color: #0B291E;
      margin-bottom: 14px;
    }
    .lead-text {
      font-size: 14px;
      color: #4B5563;
      margin-bottom: 24px;
    }
    .otp-card {
      background: #F4FBF7;
      border: 1.5px dashed #0B291E;
      border-radius: 14px;
      padding: 22px 20px;
      text-align: center;
      margin: 24px 0;
    }
    .otp-label {
      font-size: 11px;
      text-transform: uppercase;
      letter-spacing: 1.2px;
      color: #065F46;
      font-weight: 700;
      margin-bottom: 8px;
    }
    .otp-code {
      font-family: 'SF Pro Display', Consolas, monospace;
      font-size: 38px;
      font-weight: 800;
      letter-spacing: 8px;
      color: #0B291E;
      margin: 6px 0;
    }
    .otp-expiry {
      font-size: 11px;
      color: #6B7280;
    }
    .security-note {
      font-size: 12px;
      color: #6B7280;
      background: #F9FAFB;
      border-left: 3px solid #D4AF37;
      padding: 10px 14px;
      border-radius: 4px 8px 8px 4px;
      margin-top: 20px;
    }
    .footer {
      background: #F9FAFB;
      border-top: 1px solid #E5E7EB;
      padding: 24px;
      text-align: center;
      font-size: 11px;
      color: #9CA3AF;
    }
    .footer p {
      margin: 4px 0;
    }
  </style>
</head>
<body>
  <div class="wrapper">
    <div class="container">
      <div class="header">
        <div class="brand-crest">✨</div>
        <h1 class="brand-title">AL-NUR STORE</h1>
        <div class="brand-tagline">Modest Haute Couture & Fine Scents</div>
      </div>
      
      <div class="content">
        <div class="greeting">$greeting</div>
        <p class="lead-text">$description</p>
        
        <div class="otp-card">
          <div class="otp-label">One-Time Verification Code</div>
          <div class="otp-code">$otpCode</div>
          <div class="otp-expiry">Expires in 15 minutes</div>
        </div>
        
        <div class="security-note">
          🔒 <strong>Security Notice:</strong> $actionNote
        </div>
      </div>
      
      <div class="footer">
        <p><strong>Al-Nur Store</strong> • Crafted with Islamic Elegance</p>
        <p>Lekki Phase 1, Lagos & Maitama, Abuja, Nigeria</p>
        <p>Sent via official concierge: <code>$senderEmailDefault</code></p>
      </div>
    </div>
  </div>
</body>
</html>
''';
  }

  /// Builds a general luxury email layout.
  static String _buildGeneralEmailHtml({
    required String title,
    required String recipientName,
    required String messageHtml,
  }) {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>$title</title>
</head>
<body style="margin:0;padding:20px;background:#F8F9FA;font-family:sans-serif;color:#1F2937;">
  <div style="max-width:560px;margin:0 auto;background:#FFFFFF;border-radius:16px;border:1px solid #E5E7EB;overflow:hidden;">
    <div style="background:#0B291E;padding:28px 24px;text-align:center;">
      <h1 style="color:#D4AF37;margin:0;font-size:22px;letter-spacing:2px;">AL-NUR STORE</h1>
      <p style="color:#E2E8F0;font-size:11px;margin:4px 0 0;text-transform:uppercase;letter-spacing:1px;">Modest Haute Couture</p>
    </div>
    <div style="padding:32px 28px;">
      <h3 style="color:#0B291E;margin-top:0;">Assalamu alaykum $recipientName,</h3>
      $messageHtml
    </div>
    <div style="background:#F9FAFB;padding:20px;text-align:center;font-size:11px;color:#9CA3AF;border-top:1px solid #E5E7EB;">
      <p>Al-Nur Store • Lagos & Abuja, Nigeria</p>
    </div>
  </div>
</body>
</html>
''';
  }
}
