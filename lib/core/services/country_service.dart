import 'dart:convert';

import 'package:get/get.dart';
import 'package:telecaller_app/core/helpers/storage.dart';
import 'package:telecaller_app/core/helpers/utils.dart';
import 'package:telecaller_app/core/models/country_drop_response_entity.dart';

import '../../constants/app_constants.dart';

class CountryService extends GetxService {
  Rx<List<CountryDropResponseEntity>> country =
      Rx<List<CountryDropResponseEntity>>([]);

  RxString selectedLang = "en".obs;

  Future<void> init() async {
    //langs.value = await Utils.langs();

    this.selectedLang.value = Storage.getValue(AppConstants.LANGUAGE) ?? "en";

    String langString =
        await Utils.loadJsonData("assets/lang/countryList.json");
    // String langDataString = await Utils.loadJsonData("assets/lang/langData.json");

    List<Map<String, dynamic>> lang =
        List<Map<String, dynamic>>.from(json.decode(langString));
    // Map<String,Map<String,dynamic>> langData = Map<String,Map<String,dynamic>>.from(json.decode(langDataString));

    this.country.value =
        lang.map((e) => CountryDropResponseEntity.fromJson(e)).toList();

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

    print("country: ${country.value.length}");
    // Get.addTranslations(convertMap(langData));
  }

  Map<String, Map<String, String>> convertMap(Map<String, dynamic> inputMap) {
    final Map<String, Map<String, String>> resultMap = {};
    inputMap.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        resultMap[key] =
            convertInnerMap(value); // Recursive call for nested maps
      } else {
        resultMap[key] = {
          'value': value?.toString() ?? ''
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
    CountryDropResponseEntity? languageEntity =
        country.value.firstWhereOrNull((lang) => lang.currencyCode == code);
    if (languageEntity != null) {
      return languageEntity.countryNameEn!;
    } else {
      return "";
    }
  }
}
