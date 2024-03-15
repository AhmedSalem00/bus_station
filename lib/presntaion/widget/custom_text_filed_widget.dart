import 'package:flutter/material.dart';

class CustomTextFiled extends StatelessWidget {
  final String? hintText;
  final String labelText;
  final IconButton? iconButton;
  final TextEditingController? textEditingController;
  final Function()? onTap;
  final String? Function(String?)? validatorFun;
  final String? initialValue;
  final bool obscureText;
    const CustomTextFiled(
      {super.key,
        this.hintText,
        required this.labelText,
        this.iconButton,
        this.textEditingController,
        this.onTap,
        this.obscureText = false,
        this.validatorFun, this.initialValue});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText:obscureText ,
      initialValue: initialValue,
      validator: validatorFun,
      onTap: onTap,
      controller: textEditingController,
      decoration: InputDecoration(
          hintText: hintText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
          label: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(labelText)),
          suffixIcon: iconButton,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          )),
    );
  }
}
