import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChapterDetailsScreen extends StatefulWidget {
  final int chapterId;
  const ChapterDetailsScreen({ required this.chapterId,super.key}) ;

  @override
  State<ChapterDetailsScreen> createState() => _ChapterDetailsScreenState();
}

class _ChapterDetailsScreenState extends State<ChapterDetailsScreen> {
  String chapterContent = 'جاري التحميل...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadChapterContent();
  }

  // دالة لجلب الشابتر مع الحفظ المؤقت (Cache)
  Future<void> loadChapterContent() async {
    final prefs = await SharedPreferences.getInstance();
    String cacheKey = 'chapter_${widget.chapterId}';

    // 1. التحقق إذا كان الشابتر مخزناً محلياً من قبل
    String? cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      setState(() {
        chapterContent = cachedData;
        isLoading = false;
      });
      return; // افتحه فوراً بدون إنترنت أو انتظار داتابيز!
    }

    // 2. إذا لم يكن مخزناً، جلبه من Supabase وحفظه
    try {
      final response = await Supabase.instance.client
          .from('chapters')
          .select('content')
          .eq('id', widget.chapterId)
          .single();

      final content = response['content'] as String;

      // حفظه محلياً للاستخدام المستقبلي
      await prefs.setString(cacheKey, content);

      setState(() {
        chapterContent = content;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        chapterContent = 'حدث خطأ في تحميل الشابتر. تأكد من الاتصال بالإنترنت.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text('تفاصيل الشابتر ${widget.chapterId}',style: TextStyle(color: Colors.white),),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                // استخدام SelectableText يسمح للمستخدم بتحديد ونسخ النص تماماً مثل المواقع
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: SelectableText(
                    chapterContent,
                    style: const TextStyle(fontSize: 18, height: 1.6,color: Colors.white,fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
    );
  }
}