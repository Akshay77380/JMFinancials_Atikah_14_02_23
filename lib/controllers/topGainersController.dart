import 'package:get/get.dart';
import 'package:markets/model/jmModel/topGainers.dart';
import '../Connection/ISecITS/ITSClient.dart';

class TopGainersController extends GetxController {
  static var isLoading = true.obs;
  static var topGainers = TopGainers().obs;
  static List<Datum> getTopGainersListItems = <Datum>[].obs;

  @override
  void onInit() {
    // getTopGainers;
    super.onInit();
  }

  Future<void> getTopGainers(duration) async {
    isLoading(true);
    try {
      var topGainersVariable;
      var link = 'https://cmdatafeed.jmfonline.in/api/Gainers/bse/bse_sensex/$duration/10';
      var accessToken = '9lRjr6IxdL_kOegjJmnnOafSx73sTqtFaVozg_EtU8cTpjTnLDbb0VQ3Y1J6UZdiQTwYvfU6SLjy9WnAUt4v9RXR13WcnnKayWEEZL_06xdR7_lTHszbYE4TATLP8yEy2a58q9JV8WqVdbUleaIeps6ae9rzODlAZekfxGmChoJ8JzHHgAcRsuLUQkYd7QyM4oVfXtHNRZBtSJYldNdVp0Hi1fzynB_g-HcKTJj36INtHEo0I3ttPZTBVeagrZ6CM8u7HNUZ_F-X8HxBb6Blk62-Pn8_qTMb01iFulJ-nQUBtdvmDURRqiOQaT17duef';
      // print("link -- $link --- access Token -- $accessToken");
      topGainersVariable = await ITSClient.httpGetWithHeader(
          link, accessToken);

      //pnlVariable = await ITSClient.httpGet('https://cmdatafeed.jmfonline.in/api/ProftandLoss/6/s');
      print("TopGainersVar : ${topGainersVariable.runtimeType}");

      print("Hello");

      topGainers.value = topGainersFromJson(topGainersVariable);
      getTopGainersListItems.clear();

      for (var i = 0; i < topGainers.value.data.length; i++) {
        getTopGainersListItems.add(topGainers.value.data[i]);
      }

      // print("List items: $getTopGainersListItems");
    } catch (e, s) {
      print("Error $e");
    } finally {
    }
    isLoading(false);
    return;
  }
}
