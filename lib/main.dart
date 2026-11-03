import 'package:flutter/material.dart';
import 'package:httpapps/splash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async{
    WidgetsFlutterBinding.ensureInitialized();
    OneSignal.initialize("656b7b02-f309-42b2-9963-f39b7d2d3039");

  // 2. طلب إذن إرسال الإشعارات من المستخدم (سيظهر له تنبيه يوافق عليه)
  OneSignal.Notifications.requestPermission(true);

  // تهيئة Supabase بالرابط والمفتاح الخاص بك
  await Supabase.initialize(
    url: 'https://rnplpcpnyrmhrwdcjvdl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJucGxwY3BueXJtaHJ3ZGNqdmRsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTM3MjU4MTcsImV4cCI6MjEwOTMwMTgxN30.FR4CBqGhd3qBGnXH12DMqhQYRcRQ1sm1dotSZo0LW8A',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,

        home:Splash() ,
    );
  }
}