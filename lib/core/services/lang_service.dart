import 'dart:convert';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:telecaller_app/core/helpers/storage.dart';
import 'package:telecaller_app/core/helpers/utils.dart';
import 'package:telecaller_app/core/models/language_entity.dart';

import '../../constants/app_constants.dart';

class LangService extends GetxService {
  Rx<List<LanguageEntity>> langs = Rx<List<LanguageEntity>>([]);

  RxString selectedLang = "en".obs;

  Future<void> init() async {
    //langs.value = await Utils.langs();

    String? savedLang = Storage.getValue(AppConstants.LANGUAGE);
    this.selectedLang.value = savedLang ?? "en";
    print("🌍 LangService: Initialized with $selectedLang");

    String langString = await Utils.loadJsonData("assets/lang/lang.json");
    String langDataString = await Utils.loadJsonData(
      "assets/lang/langData.json",
    );

    List<Map<String, dynamic>> lang = List<Map<String, dynamic>>.from(
      json.decode(langString),
    );
    Map<String, Map<String, dynamic>> langData =
        Map<String, Map<String, dynamic>>.from(json.decode(langDataString));

    this.langs.value = lang.map((e) => LanguageEntity.fromJson(e)).toList();

    // Map<String,Map<String,String>> data = {};
    //
    // lang.forEach((l){
    //
    //   Map<String,String> ldMap = {
    //
    //   };
    //
    //   langData.forEach((ld) {
    //     ldMap[ld["key"]] = ld[l["key"]];
    //   });
    //
    //   data[l["key"]] = ldMap;
    //
    // });

    Get.addTranslations(convertMap(langData));

    // Ensure the locale is set to the saved value on initialization
    Get.updateLocale(Locale(selectedLang.value));
  }

  Map<String, Map<String, String>> convertMap(Map<String, dynamic> inputMap) {
    final Map<String, Map<String, String>> resultMap = {};
    inputMap.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        resultMap[key] = convertInnerMap(
          value,
        ); // Recursive call for nested maps
      } else {
        resultMap[key] = {
          'value': value?.toString() ?? '',
        }; // Handle non-map values
      }
    });
    return resultMap;
  }

  // Helper function to convert nested maps
  Map<String, String> convertInnerMap(Map<String, dynamic> innerMap) {
    final Map<String, String> convertedMap = {};
    innerMap.forEach((key, value) {
      convertedMap[key] = value?.toString() ?? '';
    });
    return convertedMap;
  }

  String selectedLangName(String code) {
    //return "";
    LanguageEntity? languageEntity = langs.value.firstWhereOrNull(
      (lang) => lang.key == code,
    );
    if (languageEntity != null) {
      return languageEntity.name!;
    } else {
      return "";
    }
  }

  Future<void> onChangeLang(String code) async {
    await Storage.saveValue(AppConstants.LANGUAGE, code);
    this.selectedLang.value = code;
    Get.updateLocale(Locale(code));
  }
}
