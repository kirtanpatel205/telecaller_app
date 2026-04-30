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
import 'package:telecaller_app/core/services/country_service.dart';

class EditProfileController extends GetxController {
  AuthController authController = Get.find();
  ApiService apiService = Get.find();
  CountryService countryService = Get.find();


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
  RxString selectedCountryCode = ''.obs;

  TextEditingController firstNameController = TextEditingController();

  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController addressLine1Controller = TextEditingController();
  TextEditingController addressLine2Controller = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();


  void onChangeCountry(String code) {
    selectedCountryCode.value = code;
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
    
    // Try to match the country from profile to one in our country list

    String initialCountry = authController.profile.value!.address?.country ?? "";
    if (initialCountry.isNotEmpty) {
      var match = countryService.country.value.firstWhereOrNull(
        (c) => c.countryCode == initialCountry || c.countryNameEn == initialCountry
      );
      if (match != null) {
        selectedCountryCode.value = match.countryCode ?? "";
      } else {
        selectedCountryCode.value = initialCountry;
      }
    }

    zipCodeController.text = authController.profile.value!.address!.zip ?? "";
    isLoading.value = false;
    print("selectedCountryCode.value = ${selectedCountryCode.value}");

    // log('${selectedCountry.value =  authController.profile.value!.address!.country ?? ""}');
  }

  RxString imagepath = ''.obs;
  Future getImage1() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (image != null) {
      print("getImage imagepath : $imagepath");
      imagepath.value = image.path;
      Get.back();
    }
  }
  Future getImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1024,
      maxHeight: 1024,
    );
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
    if (response["status"] == true) {
      Utils.showToast(response["message"] ?? "Image uploaded");
      
      // Robust URL extraction
      String? uploadedUrl;
      if (response['data'] != null && response['data']['url'] != null) {
        uploadedUrl = response['data']['url'];
      } else if (response['url'] != null) {
        uploadedUrl = response['url'];
      } else if (response['image'] != null) {
        uploadedUrl = response['image'];
      } else if (response['path'] != null) {
        uploadedUrl = response['path'];
      } else if (response['downloadUrl'] != null) {
        uploadedUrl = response['downloadUrl'];
      }

      if (uploadedUrl != null) {
        downloadUrl.value = uploadedUrl;
      }
      
      Get.back();
    }
  }
  void updateProfile() async {
    buttonLoading.value = true;
    print("selectedCountry.value = ${selectedCountryCode.value}");

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
      country: selectedCountryCode.value.toString(),
      //countryController.text
    );


    if (profileEntity.status!) {
      Utils.showToast(profileEntity.message!);
      authController.refreshProfile();
      Get.back();
    }
    buttonLoading.value = false;
    log("$profileEntity");

  }
}
