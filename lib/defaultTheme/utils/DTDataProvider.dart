import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:five_str/defaultTheme/model/DTAddressListModel.dart';
import 'package:five_str/defaultTheme/model/DTChatMessageModel.dart';
import 'package:five_str/defaultTheme/model/DTChatModel.dart';
import 'package:five_str/defaultTheme/model/DTProductModel.dart';
import 'package:five_str/defaultTheme/model/DTReviewModel.dart';


const sender_id = 1;
const receiver_id = 2;




List<DTChatMessageModel> getChatMsgData() {
  List<DTChatMessageModel> list = [];

  DTChatMessageModel c1 = DTChatMessageModel();
  c1.Sender_id = sender_id;
  c1.Recevier_id = receiver_id;
  c1.msg = 'Helloo';
  c1.time = '1:43 AM';
  list.add(c1);

  DTChatMessageModel c2 = DTChatMessageModel();
  c2.Sender_id = sender_id;
  c2.Recevier_id = receiver_id;
  c2.msg = 'How are you? What are you doing?';
  c2.time = '1:45 AM';
  list.add(c2);

  DTChatMessageModel c3 = DTChatMessageModel();
  c3.Sender_id = receiver_id;
  c3.Recevier_id = sender_id;
  c3.msg = 'Helloo...';
  c3.time = '1:45 AM';
  list.add(c3);

  DTChatMessageModel c4 = DTChatMessageModel();
  c4.Sender_id = sender_id;
  c4.Recevier_id = receiver_id;
  c4.msg = 'I am good. Can you do something for me? I need your help.';
  c4.time = '1:45 AM';
  list.add(c4);

  DTChatMessageModel c5 = DTChatMessageModel();
  c5.Sender_id = sender_id;
  c5.Recevier_id = receiver_id;
  c5.msg = 'I am good. Can you do something for me? I need your help.';
  c5.time = '1:45 AM';
  list.add(c5);

  DTChatMessageModel c6 = DTChatMessageModel();
  c6.Sender_id = receiver_id;
  c6.Recevier_id = sender_id;
  c6.msg = 'I am good. Can you do something for me? I need your help.';
  c6.time = '1:45 AM';
  list.add(c6);

  DTChatMessageModel c7 = DTChatMessageModel();
  c7.Sender_id = sender_id;
  c7.Recevier_id = receiver_id;
  c7.msg = 'I am good. Can you do something for me? I need your help.';
  c7.time = '1:45 AM';
  list.add(c7);

  DTChatMessageModel c8 = DTChatMessageModel();
  c8.Sender_id = receiver_id;
  c8.Recevier_id = sender_id;
  c8.msg = 'I am good. Can you do something for me? I need your help.';
  c8.time = '1:45 AM';
  list.add(c8);

  DTChatMessageModel c9 = DTChatMessageModel();
  c9.Sender_id = sender_id;
  c9.Recevier_id = receiver_id;
  c9.msg = 'I am good. Can you do something for me? I need your help.';
  c9.time = '1:45 AM';
  list.add(c9);

  DTChatMessageModel c10 = DTChatMessageModel();
  c10.Sender_id = receiver_id;
  c10.Recevier_id = sender_id;
  c10.msg = 'I am good. Can you do something for me? I need your help.';
  c10.time = '1:45 AM';
  list.add(c10);

  DTChatMessageModel c11 = DTChatMessageModel();
  c11.Sender_id = receiver_id;
  c11.Recevier_id = sender_id;
  c11.msg = 'I am good. Can you do something for me? I need your help.';
  c11.time = '1:45 AM';
  list.add(c11);

  DTChatMessageModel c12 = DTChatMessageModel();
  c12.Sender_id = sender_id;
  c12.Recevier_id = receiver_id;
  c12.msg = 'I am good. Can you do something for me? I need your help.';
  c12.time = '1:45 AM';
  list.add(c12);

  DTChatMessageModel c13 = DTChatMessageModel();
  c13.Sender_id = sender_id;
  c13.Recevier_id = receiver_id;
  c13.msg = 'I am good. Can you do something for me? I need your help.';
  c13.time = '1:45 AM';
  list.add(c13);

  DTChatMessageModel c14 = DTChatMessageModel();
  c14.Sender_id = receiver_id;
  c14.Recevier_id = sender_id;
  c14.msg = 'I am good. Can you do something for me? I need your help.';
  c14.time = '1:45 AM';
  list.add(c14);

  DTChatMessageModel c15 = DTChatMessageModel();
  c15.Sender_id = sender_id;
  c15.Recevier_id = receiver_id;
  c15.msg = 'I am good. Can you do something for me? I need your help.';
  c15.time = '1:45 AM';
  list.add(c15);

  DTChatMessageModel c16 = DTChatMessageModel();
  c16.Sender_id = receiver_id;
  c16.Recevier_id = sender_id;
  c16.msg = 'I am good. Can you do something for me? I need your help.';
  c16.time = '1:45 AM';
  list.add(c16);

  DTChatMessageModel c17 = DTChatMessageModel();
  c17.Sender_id = sender_id;
  c17.Recevier_id = receiver_id;
  c17.msg = 'I am good. Can you do something for me? I need your help.';
  c17.time = '1:45 AM';
  list.add(c17);

  DTChatMessageModel c18 = DTChatMessageModel();
  c18.Sender_id = receiver_id;
  c18.Recevier_id = sender_id;
  c18.msg = 'I am good. Can you do something for me? I need your help.';
  c18.time = '1:45 AM';
  list.add(c18);

  return list;
}

String getMonth(int month) {
  if (month == 1) return 'January';
  if (month == 2) return 'February';
  if (month == 3) return 'March';
  if (month == 4) return 'April';
  if (month == 5) return 'May';
  if (month == 6) return 'Jun';
  if (month == 7) return 'July';
  if (month == 8) return 'August';
  if (month == 9) return 'September';
  if (month == 10) return 'October';
  if (month == 11) return 'November';
  if (month == 12) return 'December';
  return '';
}

List<DTAddressListModel> getAddressList() {
  List<DTAddressListModel> list = [];

  DTAddressListModel a1 = DTAddressListModel();
  a1.name = "Smith Jones";
  a1.type = "Home";
  a1.addressLine1 = '381, Shirley St. Munster, New York';
  a1.addressLine2 = 'United States - 10005';
  a1.phoneNo = '+913972847376';
  list.add(a1);

  DTAddressListModel a2 = DTAddressListModel();
  a2.name = "Micheal Doe";
  a2.type = "Office";
  a2.addressLine1 = '4046  Fleming Street, Montgomery';
  a2.addressLine2 = 'Alabama 36109';
  a2.phoneNo = '334-318-6649';
  list.add(a2);

  return list;
}

List<DTReviewModel> getReviewList() {
  String ProKitShortText =
      'Recently tried out this restaurant, and it was an absolute delight. The dishes were full of exquisite flavors and the service left no room for complaints. The atmosphere was cozy, and I am already planning my next visit. I wholeheartedly recommend it!';
  
  
  List<DTReviewModel> list = [];

  DTReviewModel r1 = DTReviewModel();
  r1.name = "John smith";
  r1.comment = ProKitShortText;
  r1.ratting = 2.0;
  list.add(r1);
  DTReviewModel r2 = DTReviewModel();
  r2.name = "Lora";
  r2.comment = ProKitShortText;
  r2.ratting = 4.0;
  list.add(r2);
  DTReviewModel r3 = DTReviewModel();
  r3.name = "Isabella";
  r3.comment = ProKitShortText;
  r3.ratting = 5.0;
  list.add(r3);
  DTReviewModel r4 = DTReviewModel();
  r4.name = "Emma";
  r4.comment = ProKitShortText;
  r4.ratting = 3.0;
  list.add(r4);
  DTReviewModel r5 = DTReviewModel();
  r5.name = "John";
  r5.comment = ProKitShortText;
  r5.ratting = 5.0;
  list.add(r5);
  DTReviewModel r6 = DTReviewModel();
  r6.name = "Nora";
  r6.comment = ProKitShortText;
  r6.ratting = 3.0;
  list.add(r6);
  DTReviewModel r7 = DTReviewModel();
  r7.name = "Nora";
  r7.comment = 'ProKitShortText';
  r7.ratting = 3.0;
  list.add(r7);
  DTReviewModel r8 = DTReviewModel();
  r8.name = "John";
  r8.comment = ProKitShortText;
  r8.ratting = 5.0;
  list.add(r8);

  return list;
}
