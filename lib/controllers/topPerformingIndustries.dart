import 'package:get/get.dart';
import 'package:markets/util/Dataconstants.dart';
import '../Connection/ISecITS/ITSClient.dart';
import '../model/jmModel/topPerformingIndustries.dart';
import '../util/CommonFunctions.dart';

class TopPerformingIndustriesController extends GetxController{

  static var topPerformingIndustries = TopPerformingIndustries().obs;
  static List<Datum> getTopPerformingIndustriesListItems = <Datum>[].obs;
  static var isLoading = true.obs;

  @override
  void onInit() {
    // getBankDetails();
    super.onInit();
  }

  Future<void> getTopPerformingIndustries () async{
    isLoading(true);

    try {

      var res1;

      res1 = await ITSClient.httpGetWithHeader(
          'SPD002',
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6IlNQRDAwMiIsIk1pZGRsZVdhcmVfTWFwcGluZyI6IjEwIiwiTWlkZGxlV2FyZV9Kc29uRGF0YSI6IntcIlB1YmxpY0tleTRIYXNoXCI6XCI5MGUxZjA0YjIyYTVlM2FhMGQxZDhlMmUzZGE2MDczYmQ1NTM5MjZkNzM1NDc3MjUyMDlmZWI0MzU0NDJhYzUzXCIsXCJzX3ByZHRfYWxpXCI6XCJCTzpCT3x8Q05DOkNOQ3x8Q086Q098fE1JUzpNSVN8fE1URjpNVEZ8fE5STUw6TlJNTFwiLFwiYnJrTmFtZVwiOlwiSk1GSU5BTkNJQUxcIixcIkFjY291bnRJRFwiOlwiU1BEMDAyXCIsXCJCUkFOQ0hJRFwiOlwiSE9cIixcIlVzZXJOYW1lXCI6XCJTcHlkZXIgU29mdFwiLFwiSnNlc3Npb25JZFwiOlwidG9tY2F0MlwiLFwiUHVibGljS2V5NHBlbVwiOlwiLS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS1cXG5NSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQXV1VXFzTnlIMXpyR1BEYnZLOGdaXFxuWGxtZ3ZRcm1xMSt0WHFrWURZT3JaVXlvZ3R6bDdXTGIycUJpMHpqZW1ycnJaUGptM01yVjR0aStlQVFmb1padVxcbjlERUc4Q0F0L1A5UjlCYm9XUngxR2h3Z0ptbFlEcUNvU3lBVW53ZWVxT1V4WHFaeDhQYXFHVWhBTGplclFIWlNcXG5MY0NxL0NHWFR6eTl0eFFOeXdNc3lTMVNEWUpqVE5WanVFaEVUQzdjdnNwZ1NEK0hkSUU5NHliZmlyWkpYYWU1XFxuRmFWaWFwV2JISENCMnN2Z2pya2oxUjNOZWVSTGd3aXNKRmlhQkVlcW9zMjhiOWllbnBubzlERFdWc0xvVXpoSVxcbk1PbzM2MnRVR1RwL2NVYlpMTVlGUE5OMmM4Y1VBUEIranloTW1zNGxtQ2xMUHEzYmpJcFR5NnJmV1JzUEhUQ2tcXG5ud0lEQVFBQlxcbi0tLS0tRU5EIFBVQkxJQyBLRVktLS0tLVxcblwiLFwiTG9naW5JRFwiOlwiU1BEMDAyXCIsXCJMYXN0TG9naW5UaW1lXCI6XCIwOC8wMy8yMDIzIDE0OjQxOjAzXCJ9IiwiRGV2aWNlSWQiOiJlYmNhNThlYjA0NWI2NGQwIiwiRGV2aWNlVHlwZSI6IkFuZHJvaWQiLCJMb2dpbklkIjoiU1BEMDAyIiwibmJmIjoxNjc4MjY3MDgxLCJleHAiOjE2NzgyNjg4ODEsImlhdCI6MTY3ODI2NzA4MX0.BQQm4p3H7eMi0WL1m2SLcpCT8SL8Nt74MCxRtcaj24w'
      );

      print("Hello");

      topPerformingIndustries.value = topPerformingIndustriesFromJson(res1);
      getTopPerformingIndustriesListItems.clear();

      for (var i = 0; i < topPerformingIndustries.value.data.length; i++) {
        getTopPerformingIndustriesListItems.add(topPerformingIndustries.value.data[i]);
      }

    } catch (e, s) {
      print(e);
    } finally {
      isLoading(false);
    }
    return;

  }

}