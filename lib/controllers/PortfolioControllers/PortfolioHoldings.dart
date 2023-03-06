import 'dart:convert';

import 'package:get/get.dart';
import '../../Connection/ISecITS/ITSClient.dart';
import '../../model/jmModel/PortfolioModels/PortfolioHoldings.dart';
import '../../util/Dataconstants.dart';

class PortfolioHoldingController extends GetxController {

  static var holdings = PortfolioHoldings().obs;
  static List<TrPositionsCmDetailGetDataResult> getHoldingListItems = <TrPositionsCmDetailGetDataResult>[].obs;

  static var isLoading = true.obs;

  @override
  void onInit() {

    super.onInit();
  }

  Future<void> getHoldings() async {
    isLoading(true);
    String rawData = "${Dataconstants.feUserID}:${Dataconstants.authKey}";
    String bs64 = base64.encode(rawData.codeUnits);
    print(bs64);

    var res1 = await ITSClient.httpGetDpHoldings(
        "https://mobilepms.jmfonline.in/TrPositionsCMDetail.svc/TrPositionsCMDetailGetData?EncryptedParameters=${Dataconstants.feUserID}~~*~~*~~*~~*~~1.0.0.0~~*~~${Dataconstants.feUserID}",
        bs64
    );

    print(res1);
    try {
      holdings.value = portfolioHoldingsFromJson(res1);
      getHoldingListItems.clear();

      for (var i = 0; i < holdings.value.trPositionsCmDetailGetDataResult.length; i++) {
        getHoldingListItems.add(holdings.value.trPositionsCmDetailGetDataResult[i]);
      }

      print(getHoldingListItems.length);

    } catch (e, s) {
      print(e);
    } finally {
      isLoading(false);
    }
    return;
  }

}