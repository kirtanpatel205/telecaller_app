
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

  RxString selectedLanguage = "".obs;
  TextEditingController searchlangController = TextEditingController();
  RxList<LanguageEntity> filteredLanguages = RxList<LanguageEntity>();

  @override
  void onInit() {
    super.onInit();
    selectedLanguage.value = langService.selectedLang.value;
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
    final selectedKey = selectedLang.key!;
    
    selectedLanguage.value = selectedKey;
    langService.onChangeLang(selectedKey);

    Utils.showToast("Language : ${selectedLang.name}");
    Get.back();
  }


}
