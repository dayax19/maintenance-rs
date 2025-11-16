import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'ticket_list_page.dart';

class HomePage extends StatefulWidget{
  final ApiService api;
  HomePage({required this.api});
  @override _HomePageState createState()=>_HomePageState();
}

class _HomePageState extends State<HomePage>{
  int idx=0;
  static List<Widget> pages=[];
  @override void initState(){
    super.initState();
    pages = [Center(child:Text('Home content')), TicketListPage(api:widget.api), Center(child:Text('History')), Center(child:Text('Profile'))];
  }
  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Teknisi')),
      body: pages[idx],
      bottomNavigationBar: BottomNavigationBar(currentIndex: idx, onTap: (i){ setState(()=>idx=i); }, items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Tickets'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ]),
    );
  }
}
