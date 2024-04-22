import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RunJsView extends StatefulWidget {
  const RunJsView({super.key});

  @override
  State<RunJsView> createState() => _RunJsViewState();
}

class _RunJsViewState extends State<RunJsView> {
  late JavascriptRuntime flutterJs;
  late WebViewController controller;

  @override
  void initState() {
    super.initState();

    flutterJs = getJavascriptRuntime();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadHtmlString('''
<!DOCTYPE html>
<html>
<head>
  <title>Nice Payment</title>
  <script src="https://pay.nicepay.co.kr/v1/js/"></script>
</head>
<body>
<button id="payButton">Pay Now</button>
        <script>
          document.getElementById('payButton').onclick = function() {
            AUTHNICE.requestPay();
          };
        </script>
  <!-- 웹 페이지의 내용 -->
  <h1>Payment Integration Example</h1>
  <!-- 여기에 더 많은 HTML 및 자바스크립트 콘텐츠를 추가할 수 있습니다 -->
</body>
</html>
        ''');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: WebViewWidget(
                controller: controller,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                onTaprequestPay();
                // runJsCode(context);
              },
              child: Text('Run JS Code'),
            ),
          ],
        ),
      ),
    );
  }

  void onTaprequestPay() {
    controller
        .runJavaScriptReturningResult(requestPayStr)
        .then((value) => print(value));
  }

  void runJsCode(BuildContext context) {
    try {
      JsEvalResult jsResult = flutterJs.evaluate(thirdParty);
      print(jsResult);
      final result2 = flutterJs.evaluate(thirdParty);
      // final result2 = flutterJs.evaluate(
      //     'AUTHNICE.requestPay({clientId: "R1_000000000000", orderId: "1234567890", amount: 1000, goodsName: "Test", method: "card", fnError: function() {}});');
    } catch (e) {
      print(e);
    }
  }
}

String thirdParty = '"<script src="https://pay.nicepay.co.kr/v1/js"></script>"';

String requestPayStr = '''
AUTHNICE.requestPay({
    clientId: 'af0d116236df437f831483ee9c500bc4', // clientId에 따라 Server / Client 방식 분리
    method: 'vbank',
    orderId: 'your-unique-orderid',
    amount: 1004,
    goodsName: '나이스페이-상품',
    vbankHolder: '나이스',
    returnUrl: 'http://localhost:4567/serverAuth'
  });
    ''';
