import 'package:flutter/material.dart';
import 'home_page.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  @override _LoginPageState createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final api = ApiService('http://10.0.2.2:8000'); // change to server IP
  bool loading=false;

  void doLogin() async {
    setState(()=>loading=true);
    final res = await api.login(emailC.text, passC.text);
    setState(()=>loading=false);
    if(res['token']!=null){
      api.setToken(res['token']);
      Navigator.pushReplacement(context, MaterialPageRoute(builder:(c)=>HomePage(api:api)));
    }else{
      showDialog(context: context, builder: (_)=>AlertDialog(title:Text('Login failed'),content:Text(res.toString())));
    }
  }

  @override Widget build(BuildContext context){
    return Scaffold(body: Padding(padding: EdgeInsets.all(20), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children:[
      Text('Teknisi Login', style: TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
      SizedBox(height:12),
      TextField(controller: emailC, decoration: InputDecoration(labelText:'Email')),
      TextField(controller: passC, obscureText:true, decoration: InputDecoration(labelText:'Password')),
      SizedBox(height:12),
      ElevatedButton(onPressed: loading?null:doLogin, child: loading?CircularProgressIndicator():Text('Login'))
    ]))));
  }
}
