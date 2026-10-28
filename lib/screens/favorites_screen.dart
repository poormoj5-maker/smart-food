import 'package:flutter/material.dart';
import '../data/recipes_data.dart';
import '../widgets/shared.dart';
import 'recipe_detail_screen.dart';
class FavoritesScreen extends StatelessWidget {final Set<String> ids;const FavoritesScreen({super.key,required this.ids});@override Widget build(BuildContext c){final list=recipes.where((r)=>ids.contains(r.id)).toList();return list.isEmpty?const EmptyState('هنوز غذایی به علاقه‌مندی‌ها اضافه نشده است'):ListView(children:[for(final r in list)ListTile(leading:Text(r.emoji,style:const TextStyle(fontSize:28)),title:Text(r.name),onTap:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>RecipeDetailScreen(recipe:r,favorite:true))))]);}}
