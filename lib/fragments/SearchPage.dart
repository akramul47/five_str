import 'package:flutter/material.dart';
import '../model/LSServiceModel.dart';
import 'package:nb_utils/nb_utils.dart';
import '../screens/ServiceDetail/LSServiceDetailScreen.dart';
import '../utils/LSColors.dart';
import '../utils/LSWidgets.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            alignment: Alignment.centerLeft,
            child: Text(
              'Suggetions',
              style:
                Theme.of(context).textTheme.titleLarge,
              ),),
          
          Expanded(
            child: ListView.separated(
                separatorBuilder: (context, index) {
                  return Divider(height: 1, thickness: 2);
                },
                itemCount: getNearByServiceList().length,
                padding: EdgeInsets.only(top: 16, bottom: 16),
                shrinkWrap: true,
                itemBuilder: (_, i) {
                  LSServiceModel data = getNearByServiceList()[i];

                  return Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(8),
                    width: context.width(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        commonCacheImageWidget(data.img.validate(), 90,
                                width: 100, fit: BoxFit.cover)
                            .cornerRadiusWithClipRRect(8),
                        16.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            4.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(data.title.validate(),
                                    style: boldTextStyle()),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        child: Icon(Icons.star,
                                                color: Colors.yellow, size: 16)
                                            .paddingRight(4),
                                      ),
                                      TextSpan(
                                          text: '${data.rating.validate()}',
                                          style: primaryTextStyle(
                                              color: LSColorPrimary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            4.height,
                            // Text('145 Valencia St, San Francisco',
                            //     style: secondaryTextStyle()),
                            // 4.height,
                            Text(data.location.validate(),
                                    style: secondaryTextStyle())
                                .paddingOnly(left: 0, right: 8),
                            8.height,
                            Text('0.2 Km Away',
                                style: boldTextStyle(
                                    size: 14, color: LSColorPrimary)),
                          ],
                        ).expand()
                      ],
                    ),
                  ).onTap(() {
                    LSServiceDetailScreen().launch(context);
                  });
                }),
          ),
        ],
      ),
    );
  }
}