import 'dart:math';

import 'package:anochat/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirstScreen extends StatefulWidget {
  // const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}
 final TextEditingController _textController = TextEditingController();
final CollectionReference _messages = FirebaseFirestore.instance.collection('code');
 String passwordNumberGenerated(){
  var rndnumber="";
  var rnd= new Random();
  for (var i = 0; i < 4; i++) {
  rndnumber = rndnumber + rnd.nextInt(9).toString() ;
  }
  print(rndnumber);
  return rndnumber;
}

var news = "";
  Future _sendMessage() async{
     news = await passwordNumberGenerated();
    _messages.doc(news).set({
      'code': news,
     
    });

    // Get.to(ChatRoom(news:news));
   
  }
  List<DocumentSnapshot> documents = [];

  Future pioneer(String nam) async{
    //  news = await passwordNumberGenerated();
    // _messages.doc(news).set({
    //   'code': news,
     
    // });
     final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('code')
        .where('code', isEqualTo: nam)
        .get();
    documents = result.docs;


     if (documents.length > 0) {
         
       Get.to(ChatRoom(news:nam));

 
  
    } else {
      Get.snackbar(
        "Error",
        "Code not valid",
      );
      
     
    }   

   




   
  }



class _FirstScreenState extends State<FirstScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      Container(
        child:
         Column(
          children: [
             Row(
               children: [
                 Container(
                  height: 40,
                  width: 260,
                   child: TextField(
                     controller: _textController,
                     decoration: InputDecoration(hintText: 'Write a code'),
                   ),
                 ),

              SizedBox(width: 30,),
                    GestureDetector(
          onTap: () async{
        await    pioneer(_textController.text);
            //  setState(() {});
          },
          
          child: Container(
            
            color: Colors.red,
            height: 50,width: 100,child: Text("Open Chat"),)) ,
               ],
             ),


                SizedBox(height: 60,),
      //  news != "" ?
        GestureDetector(
          onTap: () async{
        await    _sendMessage();
             setState(() {});
          },
          
          child: Container(
            
            color: Colors.red,
            height: 50,width: 100,child: Text("Generate Code"),)) ,
            //  : 
            //  Container(),
          Text("${news}")
      ],),),
    );
  }
}