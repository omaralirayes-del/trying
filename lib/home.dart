import 'package:flutter/material.dart';
import 'package:httpapps/view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List chaptersList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchChaptersList();
  }

  // دالة لجلب قائمة الشباتر ديناميكياً من Supabase
  Future<void> fetchChaptersList() async {
    try {
      final response = await Supabase.instance.client
          .from('chapters')
          .select('id, title')
          .order('id', ascending: true);

      setState(() {
        chaptersList = List.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // يمكنك إظهار رسالة خطأ هنا إذا لزم الأمر
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(centerTitle: true,title: Text("Chapters",style: TextStyle(color: Colors.white,fontSize: 30,fontWeight: FontWeight.bold),),backgroundColor: Colors.black,iconTheme: IconThemeData(color: Colors.white),),
      backgroundColor: Colors.black,
      body: isLoading ? Center(child: CircularProgressIndicator(strokeWidth: 0.4,color: Colors.black,),):
      chaptersList.isEmpty? Center(child: Text("لا يوجد فصول مضافه حتي الأن"),):
      Padding(
                  padding: const EdgeInsets.all(8.0),
                  // GridView يعرض الأزرار بناءً على عدد الشباتر المسترجعة فعلياً
                  child: GridView.builder(
                    itemCount: chaptersList.length, // العدد الديناميكي حسب القاعدة
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // زرارين جنب بعض في كل صف
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.5,
                    ),
                    itemBuilder: (context, index) {
                      final chapter = chaptersList[index];
                      final chapterId = chapter['id'];
                      final chapterTitle = chapter['title'] ?? 'شابتر $chapterId';

                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        onPressed: () {
                          // الانتقال لشاشة تفاصيل الشابتر مع إرسال الـ ID الخاص به
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChapterDetailsScreen(
                                chapterId: chapterId,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          chapterTitle,
                          style: const TextStyle(fontSize: 15, color: Colors.black),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}