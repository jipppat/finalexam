import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Webby Fondue',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ListDetail> webbies = [];
  List<ListDetail> filteredWebbies = [];

  final TextEditingController urlController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController typeController = TextEditingController();

  @override
  @override
  void initState() {
    super.initState();
    _populateWebbies(); // Call function to populate webbies list
  }

  void _populateWebbies() {
    // JSON data from API response
    String jsonData = '''
  [
    {"id":"gambling","title":"เว็บพนัน","subtitle":"การพนัน แทงบอล และอื่นๆ","image":"/images/webby_fondue/gambling.jpg"},
    {"id":"fraud","title":"เว็บปลอมแปลง เลียนแบบ","subtitle":"หลอกให้กรอกข้อมูลส่วนตัว/รหัสผ่าน","image":"/images/webby_fondue/fraud.png"},
    {"id":"fake-news","title":"เว็บข่าวมั่ว","subtitle":"Fake news, ข้อมูลที่ทำให้เข้าใจผิด","image":"/images/webby_fondue/fake_news_2.jpg"},
    {"id":"share","title":"เว็บแชร์ลูกโซ่","subtitle":"หลอกลงทุน","image":"/images/webby_fondue/thief.jpg"},
    {"id":"other","title":"อื่นๆ","subtitle":"เว็บเลวในรูปแบบอื่นๆ","image":"/images/webby_fondue/evil.jpg"}
  ]
  ''';

    final List<dynamic> webbiesJson = jsonDecode(jsonData);

    setState(() {
      webbies = webbiesJson
          .map((webbyJson) => ListDetail.fromJson(webbyJson))
          .toList();
      filteredWebbies = List.from(webbies);
      filteredWebbies.sort((a, b) => a.title.compareTo(b.title));
    });
  }

  void _fetchAPI() async {
    try {
      String response = await ApiCaller().get('todos', params: null);
      final List<dynamic> webbiesJson = jsonDecode(response);

      setState(() {
        webbies = webbiesJson
            .map((webbyJson) => ListDetail.fromJson(webbyJson))
            .toList();
        filteredWebbies = List.from(webbies);
        filteredWebbies.sort((a, b) => a.title.compareTo(b.title));
      });
    } catch (e) {
      print('Error fetching webbies: $e');
    }
  }

  void showWebbyDetails(BuildContext context, ListDetail webby) {
    // Construct full image URL by appending the image path to the base URL
    String fullImageUrl = webby.imageUrl.isNotEmpty
        ? 'https://cpsu-api-49b593d4e146.herokuapp.com${webby.imageUrl}'
        : '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(webby.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Subtitle: ${webby.subtitle}'),
                Text('Image URL: $fullImageUrl'), // Display the full image URL
                SizedBox(height: 20),
                webby.imageUrl.isNotEmpty
                    ? Image.network(
                        fullImageUrl, // Use the full image URL here
                        height: 100,
                        width: 150,
                      )
                    : Container(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
void _handleWebbySelection(ListDetail selectedWebby) {
  // ล้างการเลือกรายการที่เลือกไว้ก่อนหน้านี้
  for (final webby in webbies) {
    if (webby != selectedWebby && webby.selected) {
      setState(() {
        webby.selected = false;
      });
    }
  }

  // เลือกรายการใหม่
  setState(() {
    selectedWebby.selected = !selectedWebby.selected;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Text(
              'Webby Fondue',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6), // Add SizedBox to adjust spacing
            Text(
              'ระบบรายงานเว็บเลวๆ',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
      Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0),
  child: TextField(
    controller: urlController,
    decoration: InputDecoration(
      labelText: urlController.text.isEmpty ? 'กรอกข้อมูลURL' : ' URL*', // แก้ไขที่นี่เพื่อแสดงข้อความที่ถูกต้อง
      hintText: ' URL*',//เมื่อกดกรอกURL แล้วแจ้งเตือนจะเด้งขึ้นด้านบนคับบบ
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
    ),
  ),
),

          SizedBox(height: 20), // Add space between the text fields
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: descriptionController, // Add controller here
              decoration: InputDecoration(
                hintText:
                    'รายละเอียด', // Provide a hint for the second TextField
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
            ),
            
          ),
          Expanded(
            child: ListView.builder(
  itemCount: filteredWebbies.length,
  itemBuilder: (context, index) {
    final webby = filteredWebbies[index];

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        color: webby.selected ? Color.fromARGB(255, 187, 167, 255) : null, // เปลี่ยนสีพื้นหลังของการ์ดเมื่อถูกเลือกเป็นสีฟ้าเข้ม
        child: ListTile(
          title: Text(webby.title),
          subtitle: Text(webby.subtitle),
          onTap: () {
            _handleWebbySelection(webby); // เรียกใช้เมท็อดเพื่อจัดการการเลือกรายการ
            showWebbyDetails(context, webby);
          },
        ),
      ),
    );
  },
),

            ),
          
          SizedBox(height: 20), // Add space between the text fields
          Padding(
  padding: const EdgeInsets.all(5.0),
  child: Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: Colors.white,
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        backgroundColor: Color.fromARGB(255, 216, 189, 255),
         // กำหนดขนาดของปุ่ม
      ),
      onPressed: () async {
        // Check if URL is empty before sending data
        if (urlController.text.isEmpty) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('แจ้งเตือน'),
                content: Text('กรุณาใส่ URL ก่อนที่จะส่งข้อมูล'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('ปิด'),
                  ),
                ],
              );
            },
          );
          return; // Exit the function early if URL is empty
        }

        // Call API to post web report
        try {
          Map<String, dynamic> result = await ApiCaller().postWebReport(
            url: urlController.text,
            description: descriptionController.text,
            type: typeController.text,
          );
          // Handle result as needed
          debugPrint('API Result: $result');
        } catch (e) {
          // Handle error
          debugPrint('Error posting web report: $e');
        }
      },
      child: Text('ส่งข้อมูล'),
    ),
  ),
),

          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class ListDetail {
  final String title;
  final String subtitle;
  final String imageUrl;
  bool selected; // ไม่ต้องกำหนดเป็น final แล้ว

  ListDetail({
    // เพิ่ม `{}` ที่นี่
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.selected = false, // กำหนดค่าเริ่มต้นให้เป็น false
  }); // เพิ่ม `{}` ที่นี่

  factory ListDetail.fromJson(Map<String, dynamic> json) {
    return ListDetail(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      imageUrl: json['image'] ?? '',
      selected: json['selected'] ?? false,
    );
  }
}

class ApiCaller {
  static const host = 'https://cpsu-api-49b593d4e146.herokuapp.com';
  static const baseUrl = '$host/api';
  static final _dio = Dio(BaseOptions(responseType: ResponseType.plain));

  Future<String> get(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      final response =
          await _dio.get('$baseUrl/$endpoint', queryParameters: params);
      debugPrint('Status code: ${response.statusCode}');
      debugPrint(response.data.toString());
      return response.data.toString();
    } on DioError catch (e) {
      var msg = e.response?.data.toString();
      debugPrint(msg);
      throw Exception(msg);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<Map<String, dynamic>> postWebReport({
    required String url,
    required String description,
    required String type,
  }) async {
    try {
      final response =
          await _dio.post('$baseUrl/2_2566/final/report_web', data: {
        'url': url,
        'description': description,
        'type': type,
      });
      debugPrint('Status code: ${response.statusCode}');
      debugPrint(response.data.toString());
      return jsonDecode(response.data.toString());
    } on DioError catch (e) {
      var msg = e.response?.data.toString();
      debugPrint(msg);
      throw Exception(msg);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
