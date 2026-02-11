import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'leadscontact_controller.dart';

class LeadscontactPage extends GetView<LeadsContactController>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Leads Contact"),
      ),
      body: Container(
        child: Text("Leads Contact"),
      ),
    );
  }
}