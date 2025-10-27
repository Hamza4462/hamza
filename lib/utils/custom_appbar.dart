import 'package:flutter/material.dart';
import '../constants/colors.dart';

PreferredSizeWidget customAppBar(String title) => AppBar(
      title: Text(title),
      backgroundColor: AppColors.primary,
    );
