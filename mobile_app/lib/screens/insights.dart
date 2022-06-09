import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/customAppBar.dart';

class Insights extends StatelessWidget {
  const Insights({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Column(
      children: [
        CustomAppBar(),
      ],
    ));
  }
}
