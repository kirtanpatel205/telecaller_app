import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:telecaller_app/core/controllers/auth_controller.dart';
import 'package:telecaller_app/core/helpers/utils.dart';
import 'package:telecaller_app/core/models/api_response_entity.dart';
import 'package:telecaller_app/core/services/api_service.dart';

class EditProfileController extends GetxController {
  AuthController authController = Get.find();
  ApiService apiService = Get.find();

  RxBool buttonLoading = false.obs;
  RxBool isLoading = false.obs;

//  String name = "";
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    loadProfile();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    loadProfile();
  }

  final formKey = GlobalKey<FormState>();
  RxString selectedCountryIndex = ''.obs;

  RxList<Map<String, String>> countryList = <Map<String, String>>[
    {"code": "IN", "name": "India"},
    {"code": "US", "name": "United States"},
    {"code": "UK", "name": "United Kingdom"},
    {"code": "CA", "name": "Canada"},
    {"code": "AU", "name": "Australia"},
  ].obs;
  // CountryService countryService = Get.find();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController addressLine1Controller = TextEditingController();
  TextEditingController addressLine2Controller = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();

  void onChangeCountry(String index) {
    selectedCountryIndex.value = index;
  }
  void customerSave() {
    if (formKey.currentState!.validate()) {
      updateProfile();
    }
  }

  void loadProfile() async {
    isLoading.value = true;
    await authController.refreshProfile();
    // name = authController.profile.value!.name;
    firstNameController.text = authController.profile.value!.name ?? "";
    // lastNameController.text = authController.profile.value!.lastName ?? "";
    emailAddressController.text = authController.profile.value!.email ?? "";
    addressLine1Controller.text =
        authController.profile.value!.address!.addressLine1 ?? "";
    addressLine2Controller.text =
        authController.profile.value!.address!.addressLine2 ?? "";
    cityController.text = authController.profile.value!.address!.city ?? "";
    stateController.text = authController.profile.value!.address!.state ?? "";
    countryController.text = authController.profile.value!.address?.country ?? "";
    // if(authController.profile.value!.address!.country != null){
    // selectedCountry.value =  authController.profile.value!.address!.country ?? "";
    // }
    selectedCountryIndex.value =
        authController.profile.value!.address!.country ?? "";
    zipCodeController.text = authController.profile.value!.address!.zip ?? "";
    isLoading.value = false;
    print("selectedCountryIndex.value = ${selectedCountryIndex.value}");
    // log('${selectedCountry.value =  authController.profile.value!.address!.country ?? ""}');
  }

  RxString imagepath = ''.obs;
  Future getImage1() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      print("getImage imagepath : $imagepath");
      imagepath.value = image.path;
      Get.back();
    }
  }
  Future getImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      imagepath.value = image.path;
      print('getImage imagepath : $imagepath');
      Get.back();
    }
  }
  RxString downloadUrl = "".obs;
  updateImage(var name)async{
    Map<String, dynamic> response  = await apiService.UpdateprofileImage(
        name: name);
    if (response["status"]==true) {
      Utils.showToast(response["message"]);
      downloadUrl.value = response["downloadUrl"];
      // authController.refreshProfile();
      Get.back();
    }
  }
  void updateProfile() async {
    buttonLoading.value = true;
    print("selectedCountry.value = ${selectedCountryIndex.value}");
    if (imagepath.value != '') {
      File imageFile = File(imagepath.value);
      print("onUpdateProfile image path : ${imagepath}");
      print("onUpdateProfile image file : ${imageFile}");

      if (await imageFile.exists()) {
        final fileSize = await imageFile.length();
        print("Image file size: $fileSize bytes");
        await updateImage(imageFile);
      } else {
        // Utils.showToast("Image file does not exist.");
      }
    }
    ApiResponseEntity profileEntity = await apiService.Updateprofile(
      email: emailAddressController.text,
      profile: downloadUrl.value,
      name: firstNameController.text,
      lastName: lastNameController.text,
      addressLine1: addressLine1Controller.text,
      addressLine2: addressLine2Controller.text,
      city: cityController.text,
      state: stateController.text,
      zipCode: zipCodeController.text,
      country: selectedCountryIndex.value.toString(),
      //countryController.text
    );

    if (profileEntity.status!) {
      Utils.showToast(profileEntity.message!);
      authController.refreshProfile();
      Get.back();
    }
    buttonLoading.value = false;
    log("${profileEntity}");
  }
}
