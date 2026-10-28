import '../models/ingredient.dart';
class TemperamentResult {final String label; final int score; const TemperamentResult(this.label,this.score);}
class TemperamentService {static TemperamentResult analyze(List<Ingredient> items){final s=items.fold<int>(0,(v,i)=>v+(i.temperament=='گرم'?1:i.temperament=='سرد'?-1:0));return TemperamentResult(s>0?'گرم':s<0?'سرد':'معتدل',s);}}
