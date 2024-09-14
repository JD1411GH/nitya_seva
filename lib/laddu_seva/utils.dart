import 'package:garuda/laddu_seva/datatypes.dart';

int CalculateTotalLadduPacks(LadduServe serve) {
  int total = 0;
  serve.packsPushpanjali.forEach((element) {
    element.forEach((key, value) {
      total += value;
    });
  });

  serve.packsOtherSeva.forEach((element) {
    element.forEach((key, value) {
      total += value;
    });
  });

  serve.packsMisc.forEach((element) {
    element.forEach((key, value) {
      total += value;
    });
  });

  return total;
}
