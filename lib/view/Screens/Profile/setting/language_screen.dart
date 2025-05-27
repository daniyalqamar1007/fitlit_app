import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../main.dart';
import '../../../../routes/App_routes.dart';
import '../../../Utils/Colors.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLanguage = 'English'; // Default selection
  bool isLoading = false;

  final List<Map<String, String>> languages = [
    {'name': 'English', 'nativeName': 'English', 'flag': '🇺🇸', 'code': 'en'},
    {'name': 'Spanish', 'nativeName': 'Español', 'flag': '🇪🇸', 'code': 'es'},
  ];
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedCode = prefs.getString('language_code');

    if (savedCode != null) {
      final selectedLang = languages.firstWhere(
        (lang) => lang['code'] == savedCode,
        orElse: () => languages[0], // fallback to English
      );

      setState(() {
        selectedLanguage = selectedLang['name']!;
      });
    }
  }

  void _selectLanguage(String language) {
    setState(() {
      selectedLanguage = language;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _loadSavedLanguage();
    super.initState();
  }

  Future<void> _saveLanguage() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final selectedLang =
        languages.firstWhere((lang) => lang['name'] == selectedLanguage);
    final code = selectedLang['code']!;

    await prefs.setString('language_code', code);

    // Dynamically change the app language
    MyApp.setLocale(context, Locale(code));

    setState(() => isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!
              .languageChangedTo(selectedLanguage)),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate directly to desired page (e.g., HomePage or ProfilePage)
      Navigator.of(context)
          .pushReplacementNamed(AppRoutes.dashboard); // or profile
    }
  }

  Widget _buildLanguageOption(Map<String, String> language) {
    bool isSelected = selectedLanguage == language['name'];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectLanguage(language['name']!),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? appcolor : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              color: isSelected ? appcolor.withOpacity(0.05) : Colors.white,
            ),
            child: Row(
              children: [
                // Flag
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade100,
                  ),
                  child: Center(
                    child: Text(
                      language['flag']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Language names
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language['name']!,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? appcolor : Colors.black87,
                        ),
                      ),
                      Text(
                        language['nativeName']!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Selection indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? appcolor : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: isSelected ? appcolor : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: appcolor),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.language,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: appcolor,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header description
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: appcolor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: appcolor.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.language,
                          size: 48,
                          color: appcolor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.chooseLanguage,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: appcolor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select your preferred language to personalize your app experience. You can change this anytime in settings.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    AppLocalizations.of(context)!.availableLanguages,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Language options
                  ...languages
                      .map((language) => _buildLanguageOption(language)),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Save button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveLanguage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: appcolor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.saveLanguage,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
