
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:telecaller_app/core/controllers/auth_controller.dart';
import 'package:telecaller_app/core/helpers/utils.dart';
import 'package:telecaller_app/core/models/language_entity.dart';
import 'package:telecaller_app/core/services/api_service.dart';
import 'package:telecaller_app/core/services/lang_service.dart';

class LanguageController extends GetxController {
  final AuthController authController = AuthController.to;
  final ApiService apiService = Get.find();
  final LangService langService = Get.find();
  final storage = GetStorage();

  RxInt selectedLanguage = 0.obs;
  TextEditingController searchlangController = TextEditingController();
  RxList<LanguageEntity> filteredLanguages = RxList<LanguageEntity>();

  @override
  void onInit() {
    super.onInit();

    // Delay locale setting until after first frame to avoid rebuild error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadSelectedLanguage();
    });

    filteredLanguages.value = langService.langs.value;

    searchlangController.addListener(() {
      filterLanguages();
    });
  }

  void onSearch() {
    filterLanguages();
  }

  void filterLanguages() {
    String query = searchlangController.text.toLowerCase();
    if (query.isEmpty) {
      filteredLanguages.value = langService.langs.value;
    } else {
      filteredLanguages.value = langService.langs.value.where((lang) {
        return lang.name!.toLowerCase().contains(query);
      }).toList();
    }
  }

  void onChangeLang(int index) {
    LanguageEntity selectedLang = filteredLanguages[index];
    int actualIndex = langService.langs.value.indexOf(selectedLang);

    selectedLanguage.value = actualIndex;
    storage.write('selectedLanguage', actualIndex);

    final selectedKey = langService.langs.value[actualIndex].key!;
    langService.onChangeLang(selectedKey);

    Utils.showToast("Language : ${selectedLang.name}");
    Get.back();
  }

  void loadSelectedLanguage() {
    int englishIndex = langService.langs.value.indexWhere(
          (lang) => lang.name?.toLowerCase() == 'english',
    );

    selectedLanguage.value =
        storage.read('selectedLanguage') ?? englishIndex;

    if (storage.read<int>('selectedLanguage') == null) {
      storage.write('selectedLanguage', englishIndex);
    }

    final selectedKey =
    langService.langs.value[selectedLanguage.value].key!;

    // Only update if different from current locale
    if (Get.locale?.languageCode != selectedKey) {
      langService.onChangeLang(selectedKey);
    }
  }
}
