import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  String? token;
  ApiService(this.baseUrl);
  void setToken(String t){ token = t; }
  Future<Map<String,dynamic>> login(String email,String password) async {
    final res = await http.post(Uri.parse('$baseUrl/api/login'), body: {'email':email,'password':password});
    return json.decode(res.body);
  }
  Future<dynamic> getAssets() async {
    final res = await http.get(Uri.parse('$baseUrl/api/assets'), headers: _headers());
    return json.decode(res.body);
  }
  Map<String,String> _headers(){
    final h = {'Accept':'application/json'};
    if(token!=null) h['Authorization'] = 'Bearer $token';
    return h;
  }
}
