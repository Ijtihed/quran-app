import 'package:flutter/material.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'dart:io';

import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  var directory = await getApplicationDocumentsDirectory();
  var path = directory.path;
  var mark = File('$path/mark.txt');
  var last = File('$path/last.txt');
  var localeFile = File('$path/locale.txt');

  bool startRead = false;

  try {
    MyApp.currentPage = int.parse(await last.readAsString());
    startRead = true;
  } catch(_) {
    var directory = await getApplicationDocumentsDirectory();
    var path = directory.path;
    var file = File('$path/last.txt');
    await file.writeAsString('${MyApp.currentPage}');
  }
  
  runApp(ChangeNotifierProvider(
    create: (ctx) {
      int page = -1;
      try {
        page = int.parse(mark.readAsStringSync());
      } catch(_) {}

      String locale = "ar";
      try {
        locale = localeFile.readAsStringSync();
      } catch(_) {}

      return MyState(page, Locale(locale));
    },
    child: MyApp(startRead ? "/quran" : "/"),
  ));
}

class MyState extends ChangeNotifier {
  int _currentBookmark;
  Locale _locale;

  MyState(this._currentBookmark, this._locale);

  set currentBookmark(int v) {
    _currentBookmark = v;
    notifyListeners();
  }

  int get currentBookmark => _currentBookmark;

  set locale(Locale v) {
    _locale = v;
    notifyListeners();
  }

  Locale get locale => _locale;
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp(this.initialRoute);

  static int currentPage = 0;

  // Data from https://github.com/quran/quran_android/blob/master/common/data/src/main/java/com/quran/data/pageinfo/common/MadaniDataSource.kt

  static final List<int> surahs = [
    /*   1 -  10 */ 1, 2, 50, 77, 106, 128, 151, 177, 187, 208,
    /*  11 -  20 */ 221, 235, 249, 255, 262, 267, 282, 293, 305, 312,
    /*  21 -  30 */ 322, 332, 342, 350, 359, 367, 377, 385, 396, 404,
    /*  31 -  40 */ 411, 415, 418, 428, 434, 440, 446, 453, 458, 467,
    /*  41 -  50 */ 477, 483, 489, 496, 499, 502, 507, 511, 515, 518,
    /*  51 -  60 */ 520, 523, 526, 528, 531, 534, 537, 542, 545, 549,
    /*  61 -  70 */ 551, 553, 554, 556, 558, 560, 562, 564, 566, 568,
    /*  71 -  80 */ 570, 572, 574, 575, 577, 578, 580, 582, 583, 585,
    /*  81 -  90 */ 586, 587, 587, 589, 590, 591, 591, 592, 593, 594,
    /*  91 - 100 */ 595, 595, 596, 596, 597, 597, 598, 598, 599, 599,
    /* 101 - 110 */ 600, 600, 601, 601, 601, 602, 602, 602, 603, 603,
    /* 111 - 114 */ 603, 604, 604, 604
  ];
  static final List<int> pages = [
    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
    3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
    4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
    5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7,
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8,
    8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 10,
    10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11,
    11, 11, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
    13, 13, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16,
    16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17,
    17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19,
    19, 19, 19, 19, 20, 20, 20, 20, 20, 20, 20, 20, 20, 21, 21, 21, 21, 21, 21, 21,
    21, 21, 21, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 23, 23, 23, 23, 23, 23, 23,
    23, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 25, 25, 25, 25, 25, 25, 25, 26, 26,
    26, 26, 26, 26, 26, 26, 26, 26, 27, 27, 27, 27, 27, 27, 27, 27, 27, 28, 28, 28,
    28, 28, 28, 28, 28, 28, 28, 28, 29, 29, 29, 29, 29, 29, 29, 29, 30, 30, 30, 30,
    30, 30, 31, 31, 31, 31, 32, 32, 32, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 34,
    34, 34, 34, 34, 34, 34, 35, 35, 35, 35, 35, 35, 36, 36, 36, 36, 36, 37, 37, 37,
    37, 37, 37, 37, 38, 38, 38, 38, 38, 38, 39, 39, 39, 39, 39, 39, 39, 39, 39, 40,
    40, 40, 40, 40, 40, 40, 40, 40, 41, 41, 41, 41, 41, 41, 42, 42, 42, 42, 42, 42,
    42, 43, 43, 43, 43, 43, 43, 44, 44, 44, 45, 45, 45, 45, 46, 46, 46, 46, 47, 47,
    47, 47, 48, 48, 48, 48, 48, 49, 49, 50, 50, 50, 51, 51, 51, 52, 52, 53, 53, 53,
    54, 54, 54, 55, 55, 55, 56, 56, 56, 57, 57, 57, 57, 58, 58, 58, 58, 59, 59, 59,
    60, 60, 60, 61, 62, 62, 63, 64, 64, 65, 65, 66, 66, 67, 67, 67, 68, 68, 69, 69,
    70, 70, 71, 72, 72, 73, 73, 74, 74, 75, 76, 76, 77, 78, 78, 79, 80, 81, 82, 83,
    83, 85, 86, 87, 89, 89, 91, 92, 95, 97, 98, 100, 103, 106, 109, 112
  ];
  static final List<String> surahNames = [
    "Al-Fātihah",
    "Al-Baqarah",
    "Āli-ʿImrān",
    "An-Nisāʾ",
    "Al-Māʾidah",
    "Al-Anʿām",
    "Al-Aʿrāf",
    "Al-Anfāl",
    "At-Tawbah",
    "Yūnus",
    "Hūd",
    "Yūsuf",
    "Ar-Raʿd",
    "Ibrāhīm",
    "Al-Ḥijr",
    "An-Naḥl",
    "Al-Isrāʾ",
    "Al-Kahf",
    "Maryam",
    "Ṭā-Hā",
    "Al-Anbiyāʾ",
    "Al-Ḥajj",
    "Al-Muʾminūn",
    "An-Nūr",
    "Al-Furqān",
    "Ash-Shuʿarāʾ",
    "An-Naml",
    "Al-Qaṣaṣ",
    "Al-ʿAnkabūt",
    "Ar-Rūm",
    "Luqmān",
    "As-Sajdah",
    "Al-Aḥzāb",
    "Sabaʾ",
    "Fāṭir",
    "Yā-Sīn",
    "Aṣ-Ṣāffāt",
    "Ṣād",
    "Az-Zumar",
    "Ghāfir",
    "Fuṣṣilat",
    "Ash-Shūrā",
    "Az-Zukhruf",
    "Ad-Dukhān",
    "Al-Jāthiyah",
    "Al-Aḥqāf",
    "Muḥammad",
    "Al-Fatḥ",
    "Al-Ḥujurāt",
    "Qāf",
    "Adh-Dhāriyāt",
    "Aṭ-Ṭūr",
    "An-Najm",
    "Al-Qamar",
    "Ar-Raḥmān",
    "Al-Wāqiʿah",
    "Al-Ḥadīd",
    "Al-Mujādilah",
    "Al-Ḥashr",
    "Al-Mumtaḥanah",
    "Aṣ-Ṣaff",
    "Al-Jumuʿah",
    "Al-Munāfiqūn",
    "At-Taghābun",
    "Aṭ-Ṭalāq",
    "At-Taḥrīm",
    "Al-Mulk",
    "Al-Qalam",
    "Al-Ḥāqqah",
    "Al-Maʿārij",
    "Nūḥ",
    "Al-Jinn",
    "Al-Muzzammil",
    "Al-Muddaththir",
    "Al-Qiyāmah",
    "Al-Insān",
    "Al-Mursalāt",
    "An-Nabaʾ",
    "An-Nāziʿāt",
    "ʿAbasa",
    "At-Takwīr",
    "Al-Infiṭār",
    "Al-Muṭaffifīn",
    "Al-Inshiqāq",
    "Al-Burūj",
    "Aṭ-Ṭāriq",
    "Al-Aʿlā",
    "Al-Ghāshiyah",
    "Al-Fajr",
    "Al-Balad",
    "Ash-Shams",
    "Al-Layl",
    "Aḍ-Ḍuḥā",
    "Ash-Sharḥ",
    "At-Tīn",
    "Al-ʿAlaq",
    "Al-Qadr",
    "Al-Bayyinah",
    "Az-Zalzalah",
    "Al-ʿĀdiyāt",
    "Al-Qāriʿah",
    "At-Takāthur",
    "Al-ʿAṣr",
    "Al-Humazah",
    "Al-Fīl",
    "Quraysh",
    "Al-Māʿūn",
    "Al-Kawthar",
    "Al-Kāfirūn",
    "An-Naṣr",
    "Al-Masad",
    "Al-Ikhlāṣ",
    "Al-Falaq",
    "An-Nās",
  ];

  static final List<String> surahNamesAr = [
    "الفَاتِحَةِ",
    "البَقَرَةِ",
    "آلِ عِمۡرَانَ",
    "النِّسَاءِ",
    "المَائـِدَةِ",
    "الأَنۡعَامِ",
    "الأَعۡرَافِ",
    "الأَنفَالِ",
    "التَّوۡبَةِ",
    "يُونُسَ",
    "هُودٍ",
    "يُوسُفَ",
    "الرَّعۡدِ",
    "إِبۡرَاهِيمَ",
    "الحِجۡرِ",
    "النَّحۡلِ",
    "الإِسۡرَاءِ",
    "الكَهۡفِ",
    "مَرۡيَمَ",
    "طه",
    "الأَنبِيَاءِ",
    "الحَجِّ",
    "المُؤۡمِنُونَ",
    "النُّورِ",
    "الفُرۡقَانِ",
    "الشُّعَرَاءِ",
    "النَّمۡلِ",
    "القَصَصِ",
    "العَنكَبُوتِ",
    "الرُّومِ",
    "لُقۡمَانَ",
    "السَّجۡدَةِ",
    "الأَحۡزَابِ",
    "سَبَإٍ",
    "فَاطِرٍ",
    "يسٓ",
    "الصَّافَّاتِ",
    "صٓ",
    "الزُّمَرِ",
    "غَافِرٍ",
    "فُصِّلَتۡ",
    "الشُّورَىٰ",
    "الزُّخۡرُفِ",
    "الدُّخَانِ",
    "الجَاثِيَةِ",
    "الأَحۡقَافِ",
    "مُحَمَّدٍ",
    "الفَتۡحِ",
    "الحُجُرَاتِ",
    "قٓ",
    "الذَّارِيَاتِ",
    "الطُّورِ",
    "النَّجۡمِ",
    "القَمَرِ",
    "الرَّحۡمَٰن",
    "الوَاقِعَةِ",
    "الحَدِيدِ",
    "المُجَادلَةِ",
    "الحَشۡرِ",
    "المُمۡتَحنَةِ",
    "الصَّفِّ",
    "الجُمُعَةِ",
    "المُنَافِقُونَ",
    "التَّغَابُنِ",
    "الطَّلَاقِ",
    "التَّحۡرِيمِ",
    "المُلۡكِ",
    "القَلَمِ",
    "الحَاقَّةِ",
    "المَعَارِجِ",
    "نُوحٍ",
    "الجِنِّ",
    "المُزَّمِّلِ",
    "المُدَّثِّرِ",
    "القِيَامَةِ",
    "الإِنسَانِ",
    "المُرۡسَلَاتِ",
    "النَّبَإِ",
    "النَّازِعَاتِ",
    "عَبَسَ",
    "التَّكۡوِيرِ",
    "الانفِطَارِ",
    "المُطَفِّفِينَ",
    "الانشِقَاقِ",
    "البُرُوجِ",
    "الطَّارِقِ",
    "الأَعۡلَىٰ",
    "الغَاشِيَةِ",
    "الفَجۡرِ",
    "البَلَدِ",
    "الشَّمۡسِ",
    "اللَّيۡلِ",
    "الضُّحَىٰ",
    "الشَّرۡحِ",
    "التِّينِ",
    "العَلَقِ",
    "القَدۡرِ",
    "البَيِّنَةِ",
    "الزَّلۡزَلَةِ",
    "العَادِيَاتِ",
    "القَارِعَةِ",
    "التَّكَاثُرِ",
    "العَصۡرِ",
    "الهُمَزَةِ",
    "الفِيلِ",
    "قُرَيۡشٍ",
    "المَاعُونِ",
    "الكَوۡثَرِ",
    "الكَافِرُونَ",
    "النَّصۡرِ",
    "المَسَدِ",
    "الإِخۡلَاصِ",
    "الفَلَقِ",
    "النَّاسِ",
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<MyState>(builder: (ctx, state, child) => MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.title,
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 239, 195, 138))
                .copyWith(
          background: Color.fromARGB(255, 233, 205, 169),
          primary: Colors.white,
        ),
        useMaterial3: true,
        buttonTheme: ButtonThemeData(padding: EdgeInsets.zero),
      ),
      //builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!), //ScreenSizeTest(child: child),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: state.locale,
      routes: {
        "/": (ctx) => Home(),
        "/quran": (ctx) => Quran(),
      },
      initialRoute: initialRoute,
    ));
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 2, child: Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 48, 39, 29),
        foregroundColor: Colors.white,
        title: //Stack(children: [
          Text(AppLocalizations.of(context)!.title),
          /*Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if(Localizations.localeOf(context).languageCode != "en") TextButton(
              onPressed: () => switchLocale(context, "en"),
              child: Text("Switch to English")
            ),
            if(Localizations.localeOf(context).languageCode != "ar") TextButton(
              onPressed: () => switchLocale(context, "ar"),
              child: Text("اللغه العربية")
            ),
          ]),
        ]),*/
        actions: [
          IconButton(onPressed: () async {
            switchLocale(context, await showDialog(context: context, builder: (ctx) => SimpleDialog(
              title: Text(AppLocalizations.of(context)!.lang),
              children: [
                SimpleDialogOption(
                  onPressed: () { Navigator.pop(context, "ar"); },
                  child: Text("العربية"),
                ),
                SimpleDialogOption(
                  onPressed: () { Navigator.pop(context, "en"); },
                  child: Text("English"),
                ),
              ],
            )));
          }, icon: Icon(Icons.language)),
          PopupMenuButton(
            icon: Icon(Icons.info),
            itemBuilder: (ctx) => [
            PopupMenuItem(
              value: () {
                Navigator.push(context, MaterialPageRoute(builder: (ctx) => Help()));
              },
              child: Text(AppLocalizations.of(context)!.help),
            ),
            PopupMenuItem(
              value: () {
                showAboutDialog(context: context,
                  applicationName: AppLocalizations.of(context)!.title,
                  children: [
                    Text("${AppLocalizations.of(context)!.support}: ijtihed.kilani@gmail.com")
                  ],
                );
              },
              child: Text(AppLocalizations.of(context)!.about),
            ),
            PopupMenuItem(
              value: () => switchLocale(context, Localizations.localeOf(context).languageCode == "ar" ? "en" : "ar"),
              child: Text(AppLocalizations.of(context)!.changeLang),
            ),
          ], onSelected: (f) => f())
        ],
        bottom: TabBar(
          unselectedLabelColor: Color.fromARGB(255, 246, 184, 118),
          tabs: [
          Tab(child: Text(AppLocalizations.of(context)!.quran)),
          Tab(child: Text(AppLocalizations.of(context)!.dua)),
        ]),
      ),
      body: TabBarView(children: [
        SurahList(),
        Dua(),
      ])
    ));
  }

  void switchLocale(BuildContext context, String code) async {
    Provider.of<MyState>(context, listen: false).locale = Locale(code);
    
    var directory = await getApplicationDocumentsDirectory();
    var path = directory.path;
    var localeFile = File('$path/locale.txt');
    localeFile.writeAsString("en");
  }
}

class SurahList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    for(var i = 0; i < MyApp.surahs.length; i++) {
      if(i > 0) {
        children.add(Divider(
          height: 1.0, thickness: 1.0,
          color: Colors.black,
        ));
      }
      children.add(Surah(
        i + 1,
        MyApp.surahs[i] - 1,
        MyApp.surahNames[i],
        MyApp.surahNamesAr[i],
      ));
    }
    return ListView(children: children);
  }
}

class Surah extends StatelessWidget {
  final int index;
  final int page;
  final String name;
  final String nameAr;

  Surah(this.index, this.page, this.name, this.nameAr);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        MyApp.currentPage = page;
        DefaultTabController.of(context).index = await Navigator.push(context, MaterialPageRoute(builder: (context) => Quran()));
      },
      child: Stack(alignment: AlignmentDirectional.centerStart, children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            child: Text('$index')
          ),
          Consumer<MyState>(builder: (ctx, state, child) {
            if(state.currentBookmark >= 0 && MyApp.pages[state.currentBookmark] == index) {
              return SizedBox(height: 64.0, child: Transform.scale(alignment: Alignment.topLeft, scale: 3.0, child: Image.asset("assets/mark.png")));
            } else {
              return SizedBox.shrink();
            }
          }),
        ]),
        Center(child: BorderText(
          height: 48.0,
          child: Row(textDirection: TextDirection.ltr, mainAxisSize: MainAxisSize.min, children: [
            Transform.translate(
              offset: Offset(0.0, 7.0),
              child: Text(
                String.fromCharCode(convertIndex(index)),
                style: TextStyle(fontFamily: "surahnames", fontSize: 32.0),
              ),
            ),
            SizedBox(width: 10.0),
          ])
        )),
      ])
    );
  }
}

class BorderText extends StatelessWidget {
  final double height;
  final Widget child;

  BorderText({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(textDirection: TextDirection.ltr, mainAxisSize: MainAxisSize.min, children: [
      Image.asset("assets/surah_seg.png", height: height),
      Stack(children: [
        Positioned.fill(child: Image.asset("assets/surah_line.png", height: height, repeat: ImageRepeat.repeatX)),
        SizedBox(height: height, child: Center(child: child)),
      ]),
      Transform.flip(flipX: true, child: Image.asset("assets/surah_seg.png", height: height)),
    ]);
  }
}

int convertIndex(int index) {
  if(index < 6) return 0xE903 + index;
  if(index < 34) return 0xE90B + (index - 6);
  if(index < 38) return 0xE92E + (index - 34);
  if(index < 40) return 0xE909 + (index - 38);
  if(index < 47) return 0xE927 + (index - 40);
  if(index == 47) return 0xE932;
  if(index == 48) return 0xE902;
  if(index < 59) return 0xE933 + (index - 49);
  if(index < 61) return 0xE900 + (index - 59);
  if(index < 79) return 0xE941 + (index - 61);
  if(index < 83) return 0xE93D + (index - 79);
  return 0xE953 + (index - 83);
}

class Quran extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QuranState();
}

class _QuranState extends State<Quran> {
  @override
  void initState() {
    super.initState();
    KeepScreenOn.turnOn();
  }
  @override
  void dispose() {
    KeepScreenOn.turnOff();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<MyState>(builder: (ctx, state, child) {
      var pages = <Widget>[];
      for (int i = 1; i <= 604; i++) {
        Widget w = ClipRect(
          child: Stack(fit: StackFit.expand, alignment: Alignment.center, children: [
            Image.asset("assets/frame.png", fit: BoxFit.cover),
            Align(alignment: Alignment.center, child: Column(children: [
              Spacer(flex: 2),
              Flexible(flex: 20, child: Center(
                child: Image.asset('assets/$i.png', width: double.infinity, fit: BoxFit.fitHeight)
              )),
              Spacer(flex: 1),
            ]))]));
        if(i - 1 == state.currentBookmark) {
          w = Stack(children: [
            w,
            Opacity(opacity: 0.4, child: Image.asset("assets/mark.png"))
          ]);
        }
        pages.add(w);
      }
      var controller = PageController(initialPage: MyApp.currentPage);
      return GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Color(0xcc222222),
            builder: (ctx) {
            return Opacity(opacity: 0.8, child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back),
                  label: Text(AppLocalizations.of(context)!.back)
                ),
                BookmarkButtons(controller),
                Wrap(alignment: WrapAlignment.center, spacing: 8.0, children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      iconColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context, 1);
                    },
                    icon: Icon(Icons.list),
                    label: Text(AppLocalizations.of(context)!.dua),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      iconColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: DuaPage.khitm));
                    },
                    icon: Icon(Icons.list),
                    label: Text(AppLocalizations.of(context)!.khitmDua),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      iconColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context, 0);
                    },
                    icon: Icon(Icons.list),
                    label: Text(AppLocalizations.of(context)!.toc),
                  ),
                ])
              ],
            ));
          });
        },
        child: PageView(
          controller: controller,
          reverse: Directionality.of(context) == TextDirection.ltr,
          children: pages,
          onPageChanged: (page) async {
            MyApp.currentPage = page;

            var directory = await getApplicationDocumentsDirectory();
            var path = directory.path;
            var file = File('$path/last.txt');
            await file.writeAsString('${MyApp.currentPage}');
          },
        ),
      );
    });
  }
  
}

class BookmarkButtons extends StatelessWidget {
  final PageController controller;

  BookmarkButtons(this.controller);

  @override
  Widget build(BuildContext context) {
    return Consumer<MyState>(builder: (ctx, state, child) => Row(children: [
      Spacer(),
      if(state.currentBookmark != -1) TextButton.icon(
        style: TextButton.styleFrom(
          backgroundColor: Colors.black,
          iconColor: Colors.white,
        ),
        icon: Icon(Icons.bookmark),
        label: Text(AppLocalizations.of(context)!.goToBookmark),
        onPressed: () {
          controller.animateToPage(state.currentBookmark, duration: Duration(milliseconds: 400), curve: Curves.easeOutQuad);
        },
      ),
      if(state.currentBookmark == -1) TextButton.icon(
        style: TextButton.styleFrom(
          backgroundColor: Colors.black,
          iconColor: Colors.white,
        ),
        icon: Icon(Icons.bookmark_add),
        label: Text(AppLocalizations.of(context)!.setBookmark),
        onPressed: () async {
          var directory = await getApplicationDocumentsDirectory();
          var path = directory.path;
          var file = File('$path/mark.txt');
          await file.writeAsString('${MyApp.currentPage}');
          state.currentBookmark = MyApp.currentPage;
        },
      ),
      if(state.currentBookmark != -1) SizedBox(width: 8),
      if(state.currentBookmark != -1) TextButton.icon(
        style: TextButton.styleFrom(
          backgroundColor: Colors.red,
          iconColor: Colors.white,
        ),
        icon: Icon(Icons.bookmark_remove),
        label: Text(AppLocalizations.of(context)!.removeBookmark),
        onPressed: () async {
          var directory = await getApplicationDocumentsDirectory();
          var path = directory.path;
          var file = File('$path/mark.txt');
          await file.delete();
          state.currentBookmark = -1;
        },
      ),
      Spacer(),
    ]));
  }
}

class Dua extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      DuaBox(AppLocalizations.of(context)!.morningDua, (context) => DuaPage(AppLocalizations.of(context)!.morningDua, [
        AppLocalizations.of(context)!.m0,
        AppLocalizations.of(context)!.m1,
        AppLocalizations.of(context)!.m2,
      ])),
      Divider(),
      DuaBox(AppLocalizations.of(context)!.eveningDua, (context) => DuaPage(AppLocalizations.of(context)!.eveningDua, [
        AppLocalizations.of(context)!.e0,
        AppLocalizations.of(context)!.e1,
        AppLocalizations.of(context)!.e2,
      ])),
      Divider(),
      DuaBox(AppLocalizations.of(context)!.khitmDua, DuaPage.khitm),
    ]);
  }
}

class DuaPage extends StatelessWidget {
  final String name;
  final List<String> duas;

  const DuaPage(this.name, this.duas);

  static DuaPage khitm(BuildContext context) {
    return DuaPage(AppLocalizations.of(context)!.khitmDua, [
      AppLocalizations.of(context)!.k
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ClipRect(
      child: Stack(fit: StackFit.expand, alignment: Alignment.center, children: [
        Image.asset("assets/frame.png", fit: BoxFit.cover),
        Align(alignment: Alignment.center, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Text(name, style: TextStyle(fontSize: 48.0))),
          Center(
            child: TextButton.icon(
              style: TextButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
              label: Text(AppLocalizations.of(context)!.back),
            )
          ),

          ...duas.map((e) => Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10.0),
            child: Text(e, textAlign: TextAlign.center),
          ))

        ]))
      ])
    ));
  }
}

class DuaBox extends StatelessWidget {
  final String name;
  final WidgetBuilder builder;
  DuaBox(this.name, this.builder);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: TextButton(
      style: TextButton.styleFrom(foregroundColor: Colors.black, shape: LinearBorder()),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: builder));
      },
      child: Center(child: BorderText(
        height: 100.0,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(name, textAlign: TextAlign.center, style: TextStyle(fontSize: 24.0)),
        ),
      )),
    ));
  }
}

class Help extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var curve = Curves.easeInOutCubic;
    var controller = ItemScrollController();
    var children = [
      Row(children: [
        Text(AppLocalizations.of(context)!.aboutToc, style: TextStyle(fontSize: 32)),
        Spacer(),
        TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          label: Text(AppLocalizations.of(context)!.back),
        )
      ]),
      Row(children: [Text("\u2022 "), TextButton(
        style: TextButton.styleFrom(foregroundColor: Colors.blue),
        onPressed: () {
          controller.scrollTo(index: 7, duration: Duration(milliseconds: 300), curve: curve);
        },
        child: Text(AppLocalizations.of(context)!.aboutInfo)
      )]),
      Row(children: [Text("\u2022 "), TextButton(
        style: TextButton.styleFrom(foregroundColor: Colors.blue),
        onPressed: () {
          controller.scrollTo(index: 11, duration: Duration(milliseconds: 300), curve: curve);
        },
        child: Text(AppLocalizations.of(context)!.aboutNavigation)
      )]),
      Row(children: [Text("\u2022 "), TextButton(
        style: TextButton.styleFrom(foregroundColor: Colors.blue),
        onPressed: () {
          controller.scrollTo(index: 16, duration: Duration(milliseconds: 300), curve: curve);
        },
        child: Text(AppLocalizations.of(context)!.aboutMenu)
      )]),
      Row(children: [Text("\u2022 "), TextButton(
        style: TextButton.styleFrom(foregroundColor: Colors.blue),
        onPressed: () {
          controller.scrollTo(index: 20, duration: Duration(milliseconds: 300), curve: curve);
        },
        child: Text(AppLocalizations.of(context)!.aboutDua)
      )]),
      Row(children: [Text("\u2022 "), TextButton(
        style: TextButton.styleFrom(foregroundColor: Colors.blue),
        onPressed: () {
          controller.scrollTo(index: 24, duration: Duration(milliseconds: 300), curve: curve);
        },
        child: Text(AppLocalizations.of(context)!.aboutAdditional)
      )]),

      Divider(),

      HelpTitle(AppLocalizations.of(context)!.aboutInfo),
      Text(AppLocalizations.of(context)!.aboutInfoQ0, style: TextStyle(fontSize: 24)),
      Text(AppLocalizations.of(context)!.aboutInfoA0),
      
      Divider(),

      HelpTitle(AppLocalizations.of(context)!.aboutNavigation),
      
      HelpItem(
        AppLocalizations.of(context)!.aboutNavigationQ0,
        AppLocalizations.of(context)!.aboutNavigationA0,
      ),

      HelpItem(
        AppLocalizations.of(context)!.aboutNavigationQ1,
        AppLocalizations.of(context)!.aboutNavigationA1,
      ),

      HelpItem(
        AppLocalizations.of(context)!.aboutNavigationQ2,
        AppLocalizations.of(context)!.aboutNavigationA2,
      ),

      Divider(),

      HelpTitle(AppLocalizations.of(context)!.aboutMenu),
      
      HelpItem(
        AppLocalizations.of(context)!.aboutMenuQ0,
        AppLocalizations.of(context)!.aboutMenuA0,
      ),

      HelpItem(
        AppLocalizations.of(context)!.aboutMenuQ1,
        AppLocalizations.of(context)!.aboutMenuA1,
      ),

      Divider(),

      HelpTitle(AppLocalizations.of(context)!.aboutDua),
      
      HelpItem(
        AppLocalizations.of(context)!.aboutDuaQ0,
        AppLocalizations.of(context)!.aboutDuaA0,
      ),

      HelpItem(
        AppLocalizations.of(context)!.aboutDuaQ1,
        AppLocalizations.of(context)!.aboutDuaA1,
      ),

      Divider(),

      HelpTitle(AppLocalizations.of(context)!.aboutAdditional),
      
      HelpItem(
        AppLocalizations.of(context)!.aboutAdditionalQ0,
        "${AppLocalizations.of(context)!.aboutAdditionalA0} ijtihed.kilani@gmail.com",
      ),

      HelpItem(
        AppLocalizations.of(context)!.aboutAdditionalQ1,
        AppLocalizations.of(context)!.aboutAdditionalA1,
      ),

      Divider(),
      Container(
        padding: EdgeInsets.all(40.0),
        alignment: Alignment.center,
        child: TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          label: Text(AppLocalizations.of(context)!.back),
        )
      )
    ];
    return Scaffold(body: Column(children: [
      Center(child: Text(
        AppLocalizations.of(context)!.title,
        style: TextStyle(fontSize: 48),
      )),
      Expanded(child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: ScrollablePositionedList.builder(
          itemScrollController: controller,
          itemCount: children.length,
          itemBuilder: (ctx, idx) => children[idx],
        )
      ))
    ]));
  }
}

class HelpTitle extends StatelessWidget {
  final String title;

  HelpTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 32),
      child: Center(child: Text(title, style: TextStyle(fontSize: 32)))
    );
  }
}

class HelpItem extends StatelessWidget {
  final String q;
  final String a;

  const HelpItem(this.q, this.a);
  
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(q, style: TextStyle(fontSize: 24)),
      Text(a),
    ]);
  }
}
