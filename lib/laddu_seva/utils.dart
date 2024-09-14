import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:intl/intl.dart';

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

Future<String> CalculateSessionTitle(DateTime session) async {
  String sessionTitle = DateFormat("EEE, MMM dd").format(session);
  LadduReturn lr = await FB().readLadduReturnStatus(session);
  if (lr.count >= 0) {
    String endSession = DateFormat("EEE, MMM dd").format(lr.timestamp);
    if (sessionTitle != endSession) {
      sessionTitle += " - $endSession";
    }
  } else {
    DateTime now = DateTime.now();
    if (session.day != now.day) {
      sessionTitle += DateFormat(" - EEE, MMM dd").format(now);
    }
  }

  return sessionTitle;
}
