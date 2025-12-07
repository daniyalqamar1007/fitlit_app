import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Safe getter that never returns null
  static AppLocalizations safeOf(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
    return localizations ?? AppLocalizations(const Locale('en'));
  }

  // Stub translations - returning English strings
  String get loading => 'Loading...';
  String get language => 'Language';
  String get chooseLanguage => 'Choose Language';
  String get availableLanguages => 'Available Languages';
  String get saveLanguage => 'Save Language';
  String languageChangedTo(String lang) => 'Language changed to $lang';
  String get noOutfitAvailable => 'No outfit available';
  String get errorFetchingOutfit => 'Error fetching outfit';
  String get socialMediaPage => 'Social Media';
  String get comments => 'Comments';
  String get reply => 'Reply';
  String get failedToProcessImage => 'Failed to process image';
  String get nameCannotBeEmpty => 'Name cannot be empty';
  String get profileUpdatedSuccessfully => 'Profile updated successfully';
  String get editProfile => 'Edit Profile';
  String get failedToLoadProfileData => 'Failed to load profile data';
  String get name => 'Name';
  String get email => 'Email';
  String get updatingYourProfile => 'Updating your profile';
  String get gender => 'Gender';
  String get selectGender => 'Select Gender';
  String get male => 'Male';
  String get female => 'Female';
  String get saveChanges => 'Save Changes';
  String get rateOurApp => 'Rate Our App';
  String get rateAppDescription => 'Please rate our app';
  String get cancel => 'Cancel';
  String get submit => 'Submit';
  
  // Clothing categories - Tops
  String get tShirt => 'T-Shirt';
  String get halfShirt => 'Half Shirt';
  String get casualShirt => 'Casual Shirt';
  String get dressShirt => 'Dress Shirt';
  String get poloShirt => 'Polo Shirt';
  
  // Accessories
  String get accessories => 'Accessories';
  String get necklace => 'Necklace';
  String get bracelet => 'Bracelet';
  String get earring => 'Earring';
  String get watch => 'Watch';
  String get belt => 'Belt';
  String get hat => 'Hat';
  String get scarf => 'Scarf';
  
  // Bottoms
  String get jeans => 'Jeans';
  String get trousers => 'Trousers';
  String get shorts => 'Shorts';
  String get cargo => 'Cargo';
  String get trackPants => 'Track Pants';
  String get formalPants => 'Formal Pants';
  
  // Footwear
  String get sneakers => 'Sneakers';
  String get formalShoes => 'Formal Shoes';
  String get boots => 'Boots';
  String get loafers => 'Loafers';
  String get sandals => 'Sandals';
  String get sportsShoes => 'Sports Shoes';
  
  // Camera and upload
  String get openingCamera => 'Opening camera...';
  String error(String error) => 'Error: $error';
  String failedToOpenCamera(String error) => 'Failed to open camera: $error';
  String get ok => 'OK';
  String get itemCaptured => 'Item Captured';
  String itemSuccessfullyCaptured(String subcategory) => '$subcategory successfully captured!';
  String get addToWardrobe => 'Add to Wardrobe';
  String get calendarTitle => 'Calendar';
  String get takeAPhoto => 'Take a Photo';
  String get chooseFromGallery => 'Choose from Gallery';
  String get selectCategory => 'Select Category';
  String get back => 'Back';
  String get openCamera => 'Open Camera';
  String get uploadingItem => 'Uploading item...';
  String get addingToWardrobe => 'Adding to wardrobe...';
  String get generateFromPrompt => 'Generate from prompt';
  String noCategoryAvailable(String category) => 'No $category available';
  String get wardrobeEmpty => 'Your wardrobe is empty';
  String get addItemsToGetStarted => 'Add items to get started';
  String get addFirstItem => 'Add First Item';
  String get backgrounds => 'Backgrounds';
  String get wardrobe => 'Wardrobe';
  
  // Save outfit
  String get saveOutfit => 'Save Outfit';
  String doYouWantToSaveThisOutfit(String name) => 'Do you want to save this outfit as "$name"?';
  String get save => 'Save';
  String get fitlit => 'FitLit';
  
  // Categories
  String get shirts => 'Shirts';
  String get pants => 'Pants';
  String get shoes => 'Shoes';
  
  // Months
  String get jan => 'Jan';
  String get feb => 'Feb';
  String get mar => 'Mar';
  String get apr => 'Apr';
  String get may => 'May';
  String get jun => 'Jun';
  String get jul => 'Jul';
  String get aug => 'Aug';
  String get sep => 'Sep';
  String get oct => 'Oct';
  String get nov => 'Nov';
  String get dec => 'Dec';
  
  // Upload and generation
  String get generating => 'Generating...';
  String get upload => 'Upload';
  
  // Rating responses
  String get ratingResponse1 => 'Poor';
  String get ratingResponse2 => 'Fair';
  String get ratingResponse3 => 'Good';
  String get ratingResponse4 => 'Very Good';
  String get ratingResponse5 => 'Excellent';
  
  // Profile
  String get profile => 'Profile';
  String get settings => 'Settings';
  String get privacyPolicy => 'Privacy Policy';
  String get contactUs => 'Contact Us';
  String get rateApp => 'Rate App';
  String get logout => 'Logout';
  String get confirmLogout => 'Confirm Logout';
  String get areYouSureLogout => 'Are you sure you want to logout?';
  String get delete => 'Delete';
  
  // Social media
  String get like => 'Like';
  String get comment => 'Comment';
  String get share => 'Share';
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
