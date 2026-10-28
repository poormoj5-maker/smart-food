import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/school_lunch_profile.dart';
import '../data/school_lunch_data.dart';
class SchoolLunchService {
 static const _key='school_lunch_profile_v1';
 static Future<SchoolLunchProfile> load() async {final p=await SharedPreferences.getInstance();final s=p.getString(_key);if(s==null)return const SchoolLunchProfile();try{return SchoolLunchProfile.fromJson(jsonDecode(s) as Map<String,dynamic>);}catch(_){return const SchoolLunchProfile();}}
 static Future<void> save(SchoolLunchProfile profile) async {final p=await SharedPreferences.getInstance();await p.setString(_key,jsonEncode(profile.toJson()));}
 static String ageBand(int age)=>age<=6?'۳-۶':age<=12?'۷-۱۲':'۱۳-۱۸';
 static List<SchoolLunchMeal> safeCandidates(SchoolLunchProfile p){
   final blocked=[...p.allergies,...p.dislikes];
   final rules=p.schoolRules.toLowerCase();
   // Common plain-language school bans are treated as exclusions too.
   const ruleTerms={'مغز':'مغزها','آجیل':'آجیل','گردو':'گردو','لبنیات':'لبنیات','شیر':'شیر','تخم مرغ':'تخم‌مرغ','تخم‌مرغ':'تخم‌مرغ','گوشت':'گوشت','سس':'سس'};
   for(final e in ruleTerms.entries){if(rules.contains(e.key))blocked.add(e.value);}
   final b=blocked.map(_norm).where((x)=>x.isNotEmpty).toList();
   bool restricted(SchoolLunchMeal m){final tags=m.ingredients.map(_norm).toList();
     for(final item in b){
       if(tags.any((tag)=>_overlap(item,tag)))return true;
       // Broaden common allergy/avoid wording to ingredient families.
       final families=<String,List<String>>{
         'مغز':['گردو','مغزها','آجیل'],'آجیل':['گردو','مغزها','آجیل'],'بادام زمینی':['گردو','مغزها','آجیل'],'بادام':['گردو','مغزها','آجیل'],
         'لبنی':['لبنیات','پنیر','ماست','شیر'],'شیر':['لبنیات','پنیر','ماست','شیر'],'لاکتوز':['لبنیات','پنیر','ماست','شیر'],
         'تخممرغ':['تخم‌مرغ','تخم مرغ'],'گلوتن':['گندم','آرد','نان'],'گندم':['گندم','آرد','نان'],
       };
       for(final family in families.entries){if(item.contains(_norm(family.key))&&family.value.any((f)=>tags.any((t)=>_overlap(_norm(f),t))))return true;}
     }
     for(final r in p.restrictions){final x=_norm(r);if(x.isEmpty)continue;
       final banned= x.contains('گیاه')||x.contains('vegetarian') ? ['گوشت','مرغ'] :
         x.contains('مغز')||x.contains('آجیل')||x.contains('nut') ? ['گردو','مغزها','آجیل'] :
         x.contains('لبنی')||x.contains('شیر')||x.contains('dairy') ? ['لبنیات','پنیر','ماست','شیر'] :
         x.contains('تخم')||x.contains('egg') ? ['تخم‌مرغ','تخم مرغ'] : <String>[];
       if(banned.any((z)=>tags.any((t)=>_overlap(_norm(z),t))))return true;
     }
     if(!p.canReheat&&m.needsReheating)return true;
     // No whole nuts in meal suggestions for preschool age.
     if(p.age<=6&&tags.any((t)=>t.contains('گردو')||t.contains('آجیل')||t.contains('مغزها')))return true;
     return false;
   }
   return schoolLunchMeals.where((m)=>m.ageBands.contains(ageBand(p.age))&&!restricted(m)).toList();
 }
 static List<SchoolLunchMeal> ranked(SchoolLunchProfile p){final list=safeCandidates(p);final likes=p.likes.map(_norm).where((e)=>e.isNotEmpty).toList();
   list.sort((a,b){int score(SchoolLunchMeal m){final tags=m.ingredients.map(_norm).join(' ');final n=_norm(m.name);return likes.where((x)=>_overlap(x,tags)||_overlap(x,n)).length*10+(m.ageBands.contains(ageBand(p.age))?2:0);}return score(b).compareTo(score(a));});return list;}
 static SchoolLunchMeal? daily(SchoolLunchProfile p){final list=ranked(p);if(list.isEmpty)return null;final day=DateTime.now().difference(DateTime(2024,1,1)).inDays;return list[day%list.length];}
 static List<SchoolLunchMeal> weekly(SchoolLunchProfile p){final list=ranked(p);if(list.isEmpty)return [];final start=DateTime.now().difference(DateTime(2024,1,1)).inDays%list.length;final result=<SchoolLunchMeal>[];for(var i=0;i<list.length&&result.length<5;i++){result.add(list[(start+i)%list.length]);}return result;}
 static String _norm(String s)=>s.toLowerCase().replaceAll('ي','ی').replaceAll('ك','ک').replaceAll(RegExp(r'[‌\s،,؛;_-]+'),'');
 static bool _overlap(String a,String b)=>a==b||a.contains(b)||b.contains(a);
}
