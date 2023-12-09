import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:five_str/defaultTheme/model/DTReviewModel.dart';
import 'package:five_str/defaultTheme/utils/DTDataProvider.dart';
import 'package:five_str/defaultTheme/utils/DTWidgets.dart';
import 'package:five_str/main.dart';
import 'package:five_str/main/utils/AppColors.dart';
import 'package:five_str/main/utils/AppWidget.dart';
import 'package:five_str/main/utils/flutter_rating_bar.dart';

import '../defaultTheme/screens/ReviewWidget.dart';

class DTReviewScreen extends StatefulWidget {
  static String tag = '/DTReviewScreen';
  static String ProKitShortText =  'Recently tried out this restaurant, and it was an absolute delight. The dishes were full of exquisite flavors and the service left no room for complaints. The atmosphere was cozy, and I am already planning my next visit. I wholeheartedly recommend it!';
  @override
  DTReviewScreenState createState() => DTReviewScreenState();
}

class DTReviewScreenState extends State<DTReviewScreen> {
  
  List<DTReviewModel> list = getReviewList();
  var scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
     Widget reviewListing() {
      return ReviewWidget(list: list);
    }
    Widget mobileWidget() {
      return SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 16, bottom: 16, left: 8, right: 8),
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor,
                  width: 3,),
                  borderRadius: BorderRadius.circular(8)),
              child: Text('Write a Review',
                  style: boldTextStyle(color: appColorPrimary)),
            ).onTap(() async {
              DTReviewModel? model = await showInDialog(context,
                  child: WriteReviewDialog(),
                  backgroundColor: Colors.transparent,
                  contentPadding: EdgeInsets.all(0));
              if (model != null) {
                list.insert(0, model);
                setState(() {});
              }
            }),
            reviewListing(),
          ],
        ),
      );
    }

    Widget webWidget() {
      return Row(
        children: [
          16.width,
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                children: [
                  16.height,
                  Container(
                    alignment: Alignment.center,
                    width: dynamicWidth(context),
                    padding:
                        EdgeInsets.only(top: 16, bottom: 16, left: 8, right: 8),
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text('Write a Review',
                        style: boldTextStyle(color: appColorPrimary)),
                  ).onTap(() async {
                    DTReviewModel? model = await showInDialog(context,
                        child: WriteReviewDialog(),
                        backgroundColor: Colors.transparent,
                        contentPadding: EdgeInsets.all(0));
                    if (model != null) {
                      list.insert(0, model);
                      setState(() {});
                    }
                  }),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: reviewListing(),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: appBarWidget(
        'Review & Rating',
        showBack: false,
        center: true,
        color: context.cardColor,),
      body: ContainerX(
        mobile: mobileWidget(),
        web: webWidget(),
      ),
    );
  }
}

// ignore: must_be_immutable
class WriteReviewDialog extends StatelessWidget {
  var reviewCont = TextEditingController();
  var reviewFocus = FocusNode();
  double ratting = 0.0;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: dynamicBoxConstraints(),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.scaffoldBackgroundColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Write a Review', style: boldTextStyle(size: 18)),
                  IconButton(
                    icon: Icon(Icons.close, color: appStore.iconColor),
                    onPressed: () {
                      finish(context);
                    },
                  )
                ],
              ),
              GestureDetector(
                onTap: () {
                  finish(context);
                },
                child: Container(
                    padding: EdgeInsets.all(4),
                    alignment: Alignment.centerRight),
              ),
              8.height,
              Center(
                child: RatingBar(
                  onRatingUpdate: (r) {
                    ratting = r;
                  },
                  itemSize: 35.0,
                  glow: false,
                  initialRating: 0.0,
                  allowHalfRating: false,
                  ratingWidget: RatingWidget(
                    full: Icon(Icons.star, color: Colors.amber),
                    half: Icon(Icons.star, color: Colors.amber),
                    empty: Icon(Icons.star_border, color: Colors.amber),
                  ),
                ),
              ),
              16.height,
              TextField(
                controller: reviewCont,
                focusNode: reviewFocus,
                style: primaryTextStyle(),
                decoration: InputDecoration(
                  labelText: 'Write here',
                  contentPadding: EdgeInsets.all(16),
                  labelStyle: secondaryTextStyle(),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: appColorPrimary)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          BorderSide(color: appStore.textSecondaryColor!)),
                ),
                keyboardType: TextInputType.multiline,
                minLines: 1,
                //Normal textInputField will be displayed
                maxLines: 5,
                textInputAction: TextInputAction
                    .newline, // when user presses enter it will adapt to it
              ),
              30.height,
              GestureDetector(
                onTap: () {
                  if (reviewCont.text != '') {
                    var reviewData = DTReviewModel();
                    reviewData.name = "Benjamin";
                    reviewData.comment = reviewCont.text.validate();
                    reviewData.ratting = ratting;
                    finish(context, reviewData);
                    toasty(context, 'Review is submitted');
                  } else {
                    toasty(context, errorThisFieldRequired);
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: appColorPrimary,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Center(
                    child: Text("Submit", style: boldTextStyle(color: white)),
                  ),
                ),
              ),
              16.height,
            ],
          ),
        ),
      ),
    );
  }
}
