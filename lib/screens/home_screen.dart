import 'package:flutter/material.dart';
import '../data/recipes_data.dart';
import '../models/recipe.dart';
import '../services/recommendation_service.dart';
import '../widgets/shared.dart';
import 'recipe_detail_screen.dart';
import 'school_lunch_screen.dart';
const categories=['کم‌مواد','روزمره','مجلسی'];
class HomeScreen extends StatefulWidget {final String city;final Set<String> pantry;final VoidCallback onOpenPantry;const HomeScreen({super.key,required this.city,required this.pantry,required this.onOpenPantry});@override State<HomeScreen> createState()=>_HomeScreenState();}
class _HomeScreenState extends State<HomeScreen>{String q='';String? cat;
 @override Widget build(BuildContext c){final h=DateTime.now().hour;final greet=h<12?'صبح بخیر':h<18?'ظهر بخیر':'شب بخیر';
 var list=recipes.where((r)=>(cat==null||r.complexity==cat)&&(q.isEmpty||r.name.contains(q)||r.ingredients.any((i)=>i.name.contains(q)))).toList();
 final best=RecommendationService.rank(recipes,pantry:widget.pantry,city:widget.city,level:'همه').take(3).toList();
 return ListView(padding:const EdgeInsets.all(16),children:[Text('$greet 👋',style:Theme.of(c).textTheme.headlineSmall?.copyWith(color:const Color(0xFF1E4D38),fontWeight:FontWeight.bold)),const SizedBox(height:12),TextField(decoration:const InputDecoration(hintText:'جستجوی غذا یا ماده اولیه...',prefixIcon:Icon(Icons.search),border:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(16)))),onChanged:(v)=>setState(()=>q=v)),const SizedBox(height:10),Card(color:const Color(0xFFE5EDDF),child:ListTile(leading:const Icon(Icons.lunch_dining,color:Color(0xFF1E4D38),size:30),title:const Text('چاشت مدرسه',style:TextStyle(fontWeight:FontWeight.bold)),subtitle:const Text('پیشنهادهای متناسب با سن و سلیقه، با رعایت آلرژی‌ها'),trailing:const Icon(Icons.chevron_left),onTap:()=>Navigator.of(c).push(MaterialPageRoute(builder:(_)=>const SchoolLunchScreen())))),SectionTitle('پیشنهاد بر اساس موجودی'),SizedBox(height:150,child:ListView(scrollDirection:Axis.horizontal,children:[for(final r in best) _recipeCard(c,r)])),SectionTitle('دسته‌بندی‌ها'),Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:[for(final x in categories) ChipPill(label:x,selected:cat==x,onTap:()=>setState(()=>cat=cat==x?null:x))]),SectionTitle('همه غذاها'),for(final r in list) ListTile(leading:Text(r.emoji,style:const TextStyle(fontSize:28)),title:Text(r.name),subtitle:Text(r.complexity),trailing:Text(r.minutes.toString()),onTap:()=>Navigator.of(c).push(MaterialPageRoute(builder:(_)=>RecipeDetailScreen(recipe:r))));]);}
 Widget _recipeCard(BuildContext c,Recipe r)=>Card(child:InkWell(onTap:()=>Navigator.of(c).push(MaterialPageRoute(builder:(_)=>RecipeDetailScreen(recipe:r))),child:SizedBox(width:150,child:Padding(padding:const EdgeInsets.all(12),child:Column(children:[Text(r.emoji,style:const TextStyle(fontSize:36)),Text(r.name,style:const TextStyle(fontWeight:FontWeight.bold)),Text(r.cityTags.first)])))));}
