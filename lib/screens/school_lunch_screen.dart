import 'package:flutter/material.dart';
import '../data/school_lunch_data.dart';
import '../models/school_lunch_profile.dart';
import '../services/school_lunch_service.dart';

class SchoolLunchScreen extends StatefulWidget {
 const SchoolLunchScreen({super.key});
 @override State<SchoolLunchScreen> createState()=>_SchoolLunchScreenState();
}
class _SchoolLunchScreenState extends State<SchoolLunchScreen> {
 SchoolLunchProfile? profile; bool loading=true;
 @override void initState(){super.initState();_load();}
 Future<void> _load()async{final p=await SchoolLunchService.load();if(!mounted)return;setState((){profile=p;loading=false;});}
 Future<void> _edit()async{final updated=await Navigator.of(context).push<SchoolLunchProfile>(MaterialPageRoute(builder:(_)=>SchoolLunchProfileScreen(initial:profile??const SchoolLunchProfile())));if(updated!=null){await SchoolLunchService.save(updated);if(mounted)setState(()=>profile=updated);}}
 @override Widget build(BuildContext context){final p=profile;return Directionality(textDirection:TextDirection.rtl,child:Scaffold(appBar:AppBar(title:const Text('چاشت مدرسه'),actions:[IconButton(onPressed:loading?null:_edit,tooltip:'ویرایش پروفایل',icon:const Icon(Icons.edit_outlined))]),body:loading?const Center(child:CircularProgressIndicator()):p==null?const SizedBox():_content(p));}
 Widget _content(SchoolLunchProfile p){final daily=SchoolLunchService.daily(p);final week=SchoolLunchService.weekly(p);return ListView(padding:const EdgeInsets.all(16),children:[
 Card(color:const Color(0xFFE5EDDF),child:Padding(padding:const EdgeInsets.all(16),child:Row(children:[const Icon(Icons.child_care,color:Color(0xFF1E4D38),size:32),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(p.childName.isEmpty?'پروفایل کودک':p.childName,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:17)),Text('سن ${p.age} سال · ${p.gender}') ])),TextButton(onPressed:_edit,child:const Text('ویرایش'))]))),
 const SizedBox(height:12),const Text('پیشنهاد امروز',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:Color(0xFF1E4D38))),const SizedBox(height:8),
 if(daily==null)_empty() else _mealCard(daily,featured:true),
 const SizedBox(height:18),const Text('پیشنهادهای متنوع هفته',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:Color(0xFF1E4D38))),const SizedBox(height:8),
 if(week.isEmpty)_empty() else ...week.map((m)=>_mealCard(m)),
 const SizedBox(height:12),Card(child:ListTile(leading:const Icon(Icons.water_drop_outlined,color:Color(0xFF1E4D38)),title:const Text('یادآوری آب'),subtitle:const Text('یک بطری آب در دسترس کودک بگذارید و نوشیدن آب را یادآوری کنید.'))),
 const SizedBox(height:12),const Card(child:Padding(padding:EdgeInsets.all(14),child:Text('ایده‌های عمومی هستند، نه برنامه غذایی یا توصیه پزشکی. قوانین مدرسه و برچسب مواد غذایی را بررسی کنید؛ آلرژی و پرهیزها همیشه بر پیشنهادها اولویت دارند. برای نیازهای خاص با پزشک کودک یا متخصص تغذیه مشورت کنید. غذا را متناسب با سن خرد و آماده کنید؛ از خوراکی‌های گرد و سفت و مغز کامل برای خردسالان پرهیز کنید و شرایط نگهداری ایمن غذا را رعایت کنید.',style:TextStyle(height:1.5)))),
 ]);}
 Widget _empty()=>const Card(child:Padding(padding:EdgeInsets.all(18),child:Text('با محدودیت‌های ثبت‌شده پیشنهاد امنی پیدا نشد. محدودیت‌ها را تغییر ندهید مگر پس از اطمینان از ایمنی غذا.',style:TextStyle(height:1.5))));
 Widget _mealCard(SchoolLunchMeal m,{bool featured=false})=>Card(child:ListTile(leading:Text(m.emoji,style:const TextStyle(fontSize:30)),title:Text(m.name,style:TextStyle(fontWeight:featured?FontWeight.bold:FontWeight.w600)),subtitle:Text(m.description),isThreeLine:true));
}

class SchoolLunchProfileScreen extends StatefulWidget {
 final SchoolLunchProfile initial;const SchoolLunchProfileScreen({super.key,required this.initial});
 @override State<SchoolLunchProfileScreen> createState()=>_SchoolLunchProfileScreenState();
}
class _SchoolLunchProfileScreenState extends State<SchoolLunchProfileScreen>{
 late final TextEditingController name,likes,dislikes,allergies,restrictions,rules;late int age;late String gender;late bool canReheat;
 @override void initState(){super.initState();final p=widget.initial;name=TextEditingController(text:p.childName);likes=TextEditingController(text:p.likes.join('، '));dislikes=TextEditingController(text:p.dislikes.join('، '));allergies=TextEditingController(text:p.allergies.join('، '));restrictions=TextEditingController(text:p.restrictions.join('، '));rules=TextEditingController(text:p.schoolRules);age=p.age.clamp(3,18).toInt();gender=p.gender;canReheat=p.canReheat;}
 @override void dispose(){for(final c in [name,likes,dislikes,allergies,restrictions,rules]){c.dispose();}super.dispose();}
 List<String> _items(String s)=>s.split(RegExp(r'[,،٬؛;|\r\n]+')).map((x)=>x.trim()).where((x)=>x.isNotEmpty).toSet().toList();
 void _save(){Navigator.pop(context,SchoolLunchProfile(childName:name.text.trim(),age:age,gender:gender,likes:_items(likes.text),dislikes:_items(dislikes.text),allergies:_items(allergies.text),restrictions:_items(restrictions.text),schoolRules:rules.text.trim(),canReheat:canReheat));}
 @override Widget build(BuildContext context)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(appBar:AppBar(title:const Text('پروفایل چاشت')),body:ListView(padding:const EdgeInsets.all(16),children:[
 TextField(controller:name,decoration:const InputDecoration(labelText:'نام کودک (اختیاری)',border:OutlineInputBorder())),const SizedBox(height:12),
 Row(children:[const Text('سن کودک'),const SizedBox(width:12),DropdownButton<int>(value:age,items:[for(var i=3;i<=18;i++)DropdownMenuItem(value:i,child:Text('$i سال'))],onChanged:(v)=>setState(()=>age=v??age))]),
 DropdownButtonFormField<String>(value:gender,decoration:const InputDecoration(labelText:'جنسیت (در محاسبه کالری یا نیاز فردی استفاده نمی‌شود)'),items:const [DropdownMenuItem(value:'دختر',child:Text('دختر')),DropdownMenuItem(value:'پسر',child:Text('پسر')),DropdownMenuItem(value:'ترجیح می‌دهم نگویم',child:Text('ترجیح می‌دهم نگویم'))],onChanged:(v)=>setState(()=>gender=v??gender)),
 const SizedBox(height:12),_field(likes,'خوراکی‌های موردعلاقه','مثال: پنیر، میوه، سبزی'),_field(dislikes,'خوراکی‌های نامطلوب','با ویرگول جدا کنید'),_field(allergies,'آلرژی‌ها و عدم‌تحمل‌ها','مثال: بادام‌زمینی، لبنیات، تخم‌مرغ؛ با ویرگول جدا کنید'),_field(restrictions,'محدودیت‌های غذایی','مثال: گیاه‌خواری، بدون مغزها، بدون لبنیات، بدون تخم‌مرغ'),_field(rules,'قوانین مدرسه','مثال: ممنوعیت مغزها یا نیاز به غذای سرد',lines:2),
 SwitchListTile(title:const Text('امکان گرم‌کردن غذا در مدرسه هست'),value:canReheat,onChanged:(v)=>setState(()=>canReheat=v)),const SizedBox(height:6),const Text('آلرژی‌ها و موارد اجتنابی برای حذف پیشنهادها به‌کار می‌روند؛ فهرست کامل مواد و آلودگی متقاطع را همیشه بررسی کنید.',style:TextStyle(height:1.45)),const SizedBox(height:16),FilledButton(onPressed:_save,child:const Text('ذخیره پروفایل')),
 ])));
 Widget _field(TextEditingController c,String label,String hint,{int lines=1})=>Padding(padding:const EdgeInsets.only(top:12),child:TextField(controller:c,maxLines:lines,decoration:InputDecoration(labelText:label,hintText:hint,border:const OutlineInputBorder())));
}
