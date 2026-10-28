import 'ingredient.dart';
class Recipe {
  final String id, name, complexity, difficulty, emoji;
  final List<String> cityTags, steps, benefits;
  final int minutes;
  final int imageColor;
  final List<Ingredient> ingredients;
  const Recipe({required this.id, required this.name, required this.cityTags, required this.complexity, required this.minutes, required this.difficulty, required this.emoji, required this.imageColor, required this.ingredients, required this.steps, required this.benefits});
  String get temperament { final s=ingredients.fold<int>(0,(v,i)=>v+(i.temperament=='گرم'?1:i.temperament=='سرد'?-1:0)); return s>0?'گرم':s<0?'سرد':'معتدل'; }
}
