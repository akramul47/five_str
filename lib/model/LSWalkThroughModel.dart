import '../utils/LSImages.dart';

class LSWalkThroughModel {
  String? img;
  String? title;
  String? backgroundImg;

  LSWalkThroughModel({this.img, this.title, this.backgroundImg});
}

List lsWalkThroughList = [
  LSWalkThroughModel(img: LSWalk1, title: 'Decide', backgroundImg: LSBgWalk1),
  LSWalkThroughModel(img: LSWalk2, title: 'Share', backgroundImg: LSBgWalk2),
  // LSWalkThroughModel(img: LSWalk4, title: 'Get Top Washing Facilities', backgroundImg: LSBgWalk3),
  LSWalkThroughModel(img: LSWalk3, title: 'Rate', backgroundImg: LSBgWalk4),
  // LSWalkThroughModel(img: LSWalk5, title: 'Pay Later & Feel satisfied', backgroundImg: LSBgWalk5),
];
