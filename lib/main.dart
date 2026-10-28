import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models/user_prefs.dart';
import 'services/prefs_service.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pantry_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/settings_screen.dart';
void main()=>runApp(const SmartFoodApp());
class SmartFoodApp extends StatelessWidget {const SmartFoodApp({super.key});@override Widget build(BuildContext c)=>MaterialApp(title:'غذای هوشمند',debugShowCheckedModeBanner:false,theme:AppTheme.light,locale:const Locale('fa'),supportedLocales:const [Locale('fa')],localizationsDelegates:const [GlobalMaterialLocalizations.delegate,GlobalWidgetsLocalizations.delegate,GlobalCupertinoLocalizations.delegate],home:const Directionality(textDirection:TextDirection.rtl,child:RootPage()));}
class RootPage extends StatefulWidget {const RootPage({super.key});@override State<RootPage> createState()=>_RootPageState();}
class _RootPageState extends State<RootPage>{UserPrefs prefs=UserPrefs();int tab=0;@override void initState(){super.initState();PrefsService.load().then((v)=>setState(()=>prefs=v));}
 Future<void> save(UserPrefs u)async{await PrefsService.save(u);setState(()=>prefs=u);}
 @override Widget build(BuildContext c){if(!prefs.welcomed)return WelcomeScreen(onDone:()=>save(prefs.copyWith(welcomed:true)));if(!prefs.loggedIn)return LoginScreen(onLogin:(n)=>save(prefs.copyWith(loggedIn:true)));
 final body=[HomeScreen(city:prefs.city,pantry:prefs.pantry.toSet(),onOpenPantry:()=>setState(()=>tab=1)),PantryScreen(pantry:prefs.pantry.toSet(),onChange:(s)=>save(prefs.copyWith(pantry:s.toList()))),FavoritesScreen(ids:prefs.favorites.toSet()),SettingsScreen(city:prefs.city,level:prefs.level,localFirst:prefs.showLocalFirst,onSave:(city,level,local)=>save(prefs.copyWith(city:city,level:level,showLocalFirst:local)))];
 return AppScaffold(index:tab,onTab:(i)=>setState(()=>tab=i),title:['خانه','انبار','علاقه‌مندی‌ها','تنظیمات'][tab],body:body[tab]);}}
