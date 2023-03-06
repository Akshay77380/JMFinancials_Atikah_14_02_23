
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../Connection/ISecITS/ITSClient.dart';
import '../model/jmModel/FIICashModel.dart';

class FIICashController extends GetxController{

  static var fiiCash = FiiCash().obs;
  static List<Datum> getFiiCashListItems = <Datum>[].obs;
  static var isLoading = true.obs;

  @override
  void onInit() {
    // getBalanceSheet();
    super.onInit();
  }

  Future<void> getFiicash () async{

    isLoading(true);
    var fiicashVariable;
    fiicashVariable = await ITSClient.httpGetWithHeader(
        'https://cmdatafeed.jmfonline.in/api/FIIDII-DailyEOD',
        '9lRjr6IxdL_kOegjJmnnOafSx73sTqtFaVozg_EtU8cTpjTnLDbb0VQ3Y1J6UZdiQTwYvfU6SLjy9WnAUt4v9RXR13WcnnKayWEEZL_06xdR7_lTHszbYE4TATLP8yEy2a58q9JV8WqVdbUleaIeps6ae9rzODlAZekfxGmChoJ8JzHHgAcRsuLUQkYd7QyM4oVfXtHNRZBtSJYldNdVp0Hi1fzynB_g-HcKTJj36INtHEo0I3ttPZTBVeagrZ6CM8u7HNUZ_F-X8HxBb6Blk62-Pn8_qTMb01iFulJ-nQUBtdvmDURRqiOQaT17duef'
    );

    print(fiicashVariable);
    try {

      fiiCash.value = fiiCashFromJson(fiicashVariable);
      getFiiCashListItems.clear();

      for (var i = 0; i < fiiCash.value.data.length; i++) {
        getFiiCashListItems.add(fiiCash.value.data[i]);
      }

      // print("List items: $getBalanceSheetDetailsListItems");

    } catch (e) {

    } finally {
      isLoading(false);
    }
    return;

  }

}