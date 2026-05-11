import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://api.5str.xyz/api/v1/businesses/171');
  final response = await http.get(url, headers: {
    'User-Agent': 'ReactNative/5StrApp',
    'Accept': 'application/json'
  });
  
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    final encoder = JsonEncoder.withIndent('  ');
    print(encoder.convert(data));
  } else {
    print('Failed: ${response.statusCode}');
    print(response.body);
  }
}
