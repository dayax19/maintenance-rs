import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TicketListPage extends StatefulWidget {
  final ApiService api;
  TicketListPage({required this.api});
  @override _TicketListPageState createState()=>_TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage>{
  List items = [];
  bool loading = true;
  @override void initState(){ super.initState(); load(); }
  void load() async {
    final res = await widget.api.getAssets();
    setState(()=> items = res['data'] ?? [], loading=false);
  }
  @override Widget build(BuildContext context){
    if(loading) return Center(child:CircularProgressIndicator());
    return ListView.builder(itemCount: items.length, itemBuilder: (_,i){
      final a = items[i];
      return Card(child: ListTile(title: Text(a['name'] ?? '---'), subtitle: Text(a['asset_code'] ?? ''), trailing: ElevatedButton(onPressed: (){}, child: Text('Open'))));
    });
  }
}
