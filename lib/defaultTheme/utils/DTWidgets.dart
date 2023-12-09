import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:five_str/main/utils/AppColors.dart';

import '../../main.dart';

Widget priceWidget(int? price, {bool applyStrike = false, double? fontSize, Color? textColor}) {
  return Text(
    applyStrike ? '$price' : '\$$price',
    style: TextStyle(
      decoration: applyStrike ? TextDecoration.lineThrough : TextDecoration.none,
      color: textColor != null
          ? textColor
          : applyStrike
              ? appStore.textSecondaryColor
              : appStore.textPrimaryColor,
      fontSize: fontSize != null
          ? fontSize
          : applyStrike
              ? 15
              : 18,
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget dot() {
  return Container(
    height: 7,
    width: 7,
    decoration: BoxDecoration(color: Colors.black12, shape: BoxShape.circle),
  );
}

Gradient defaultThemeGradient() {
  return LinearGradient(
    colors: [
      appColorPrimary,
      appColorPrimary.withOpacity(0.5),
    ],
    tileMode: TileMode.mirror,
    begin: Alignment.topCenter,
    end: Alignment.bottomLeft,
  );
}



Widget totalAmountWidget(int subTotal, int shippingCharges, int totalAmount) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Sub Total', style: boldTextStyle(size: 18)),
          priceWidget(subTotal),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Shipping Charges', style: boldTextStyle(size: 18)),
          priceWidget(shippingCharges),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total Amount', style: boldTextStyle(size: 18)),
          priceWidget(totalAmount),
        ],
      ),
      20.height,
    ],
  );
}