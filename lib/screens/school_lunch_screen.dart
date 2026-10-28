import 'package:flutter/material.dart';
import '../models/school_lunch_profile.dart';
import '../services/school_lunch_service.dart';

class SchoolLunchScreen extends StatefulWidget {
  const SchoolLunchScreen({super.key});

  @override
  State<SchoolLunchScreen> createState() => _SchoolLunchScreenState();
}

class _SchoolLunchScreenState extends State<SchoolLunchScreen> {
  SchoolLunchProfile? p;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final loaded = await SchoolLunchService.load();
    setState(() {
      p = loaded;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('چاشت مدرسه'),
          backgroundColor: const Color(0xFF1E4D38),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: p == null ? _form() : _content(p!),
              ),
      ),
    );
  }

  Widget _form() {
    int age = 8;
    final allergies = <String>{};

    return StatefulBuilder(
      builder: (context, setStateSB) => ListView(
        children: [
          const Text('تنظیم پروفایل دانش‌آموز',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('سن: $age سال'),
          Slider(
            value: age.toDouble(),
            min: 5,
            max: 18,
            divisions: 13,
            label: '$age',
            onChanged: (v) => setStateSB(() => age = v.toInt()),
          ),
          const SizedBox(height: 16),
          const Text('آلرژی‌ها:'),
          Wrap(
            spacing: 8,
            children: ['گلوتن', 'پسته', 'شیر', 'تخم‌مرغ'].map((a) {
              final sel = allergies.contains(a);
              return FilterChip(
                label: Text(a),
                selected: sel,
                onSelected: (s) => setStateSB(() {
                  if (s) {
                    allergies.add(a);
                  } else {
                    allergies.remove(a);
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E4D38)),
            onPressed: () async {
              final newProfile = SchoolLunchProfile(
                age: age,
                allergies: allergies.toList(),
              );
              await SchoolLunchService.save(newProfile);
              setState(() {
                p = newProfile;
              });
            },
            child: const Text('ذخیره و دریافت پیشنهادها',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _content(SchoolLunchProfile profile) {
    final suggestions = SchoolLunchService.ranked(profile);
    return ListView(
      children: [
        Card(
          color: const Color(0xFFE5EDDF),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'سن: ${profile.age} سال\nآلرژی‌ها: ${profile.allergies.isEmpty ? "ندارد" : profile.allergies.join(", ")}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text('پیشنهادهای متناسب:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (suggestions.isEmpty)
          const Text('موردی با این مشخصات یافت نشد.')
        else
          for (final s in suggestions)
            Card(
              child: ListTile(
                leading: Text(s.emoji, style: const TextStyle(fontSize: 28)),
                title: Text(s.name),
                subtitle: Text('زمان آماده‌سازی: ${s.prepMinutes} دقیقه'),
              ),
            ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => setState(() => p = null),
          child: const Text('تغییر مشخصات'),
        ),
      ],
    );
  }
}
