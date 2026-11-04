import 'package:flutter/material.dart';
import 'package:httpapps/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  Future<void> launchWhatsApp({required String phoneNumber, required String message}) async {
  // تنسيق رابط واتساب الرسمي
  final url = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
  
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}
  TextEditingController codecontroller =TextEditingController();
  String errormessage = '';
  bool isloading = false;

  Future<void> verify()async{
    String encodecontroller = codecontroller.text.trim();
    if(encodecontroller.isEmpty){
      setState(() {
        errormessage = "بالرجاء ادخال الكود";

      });
    }
    setState(() {
      isloading = true;
      errormessage = '';
    });

    try{
      final response = await Supabase.instance.client
            .from("codes")
            .select()
            .eq("code_value", encodecontroller.trim())
            .maybeSingle();
       if(response == null){
        setState(() {
          errormessage = "الكود غير صحيح ";
          isloading = false;
        });

       }else{
          bool isUsed = response["is_used"];
          if(isUsed){
            setState(() {
              errormessage = "هذا الكود تم استخدامه من قبل";
              isloading = false;
            });
          }else{
            await Supabase.instance.client
                .from("codes")
                .update({"is_used" : true})
                .eq("id", response["id"]);
            final prefs = await SharedPreferences.getInstance(); 
            await prefs.setBool("isActivated", true);
            OneSignal.User.addTagWithKey("status", "activated");
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>Home()));
            
          }
       }     
            
    } catch(e){
      setState(() {
        errormessage = "حدث خطأ";
        isloading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            const SizedBox(height: 90,),
            Container(
              color: Colors.black,
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: TextField(
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w600),
                controller: codecontroller,
                decoration: InputDecoration(
                  hintText: "أدخل الكود ",
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),borderSide: BorderSide.none)
                ),
              ),
            ),
            const SizedBox(height: 9,),
            ElevatedButton(onPressed: (){verify();}, child: isloading? CircularProgressIndicator(color: Colors.black,strokeWidth: 0.4,):Text("تسجيل" ,style: TextStyle(color: Colors.black,fontSize: 14,fontWeight: FontWeight.bold),)),
            const SizedBox(height: 40,),
             Text(errormessage,style: TextStyle(color: Colors.red,fontSize: 30,fontWeight: FontWeight.bold),),

          
            const SizedBox(height: 50,),

            Column(children: [
              Container(child: Text("للحصول علي الكود عليك بدفع مبلغ ",style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),)),
              Container(alignment: Alignment.center,child: Text("30 L.E ",style: TextStyle(color: Colors.green,fontSize: 30,fontWeight: FontWeight.bold),),),
              Text("الدفع كاش عند المقابله بيني وبينك",style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
            const SizedBox(height: 5,),
              
              Text("لو هتبعت فودافون كاش علي الرقم دا",style: TextStyle(color: Colors.white,fontSize: 19,fontWeight: FontWeight.bold),),
              Container(alignment: Alignment.center,child: SelectableText("01130237474",style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),)),
            const SizedBox(height: 5,),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 
                  Container(decoration: BoxDecoration(color: const Color.fromARGB(255, 46, 102, 47),borderRadius: BorderRadius.circular(40)),width: 60,child: IconButton(onPressed: (){launchWhatsApp(phoneNumber: "01130237474", message:"");}, icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 30),)),
                   Text(" للتواصل والاستفسار ",style: TextStyle(color: Colors.white,fontSize: 15),),
                ],
              )
            ],)
          
          ],
        ),
      ),
    );
  }
}