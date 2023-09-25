import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:anochat/controller.dart';
import 'package:anochat/firstScreen.dart';
import 'package:anochat/newfile.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_settings/app_settings.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
 
 
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: 
      ChatScreen(),
    );
  }


}

class ChatScreen extends StatefulWidget {

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
   



  @override
  Widget build(BuildContext context) {
    
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat App'),
      ),
      body: FirstScreen(),
    );
  }
}

class ChatRoom extends StatefulWidget {
  String news;
  ChatRoom({ required this.news});
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _textController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _messages = FirebaseFirestore.instance.collection('messages');
  final CollectionReference _code = FirebaseFirestore.instance.collection('code');
   SharedPreferences? prefs;
  


  

 AudioPlayer audioPlayer = AudioPlayer();
  void _sendMessage(String message)async {

    _code.doc(widget.news).collection("message").add({
      'text': message,
      'timestamp': FieldValue.serverTimestamp(),
       'image_url': "",
       "audio":"",
       "id":controllers.action
    });
        print("SADAS  +${controllers.action}");
    _textController.clear();
  }

  void _clearMessages() async {
    QuerySnapshot snapshot = await  _code.doc(widget.news).collection("message").get();
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      doc.reference.delete();
    }
  }



final picker = ImagePicker();

Future<void> pickImageFromGallery() async {
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    // Upload the selected image to Firebase Storage
   final  imageUrl = await uploadImageToStorage(File(pickedFile.path));

    // Send a message with the image URL to Firestore
    sendMessageWithImage(imageUrl);
  }
}



Future<void> pickImageFromCamera() async {
  final pickedFile = await picker.pickImage(source: ImageSource.camera);

  if (pickedFile != null) {
    // Upload the selected image to Firebase Storage
    final imageUrl = await uploadImageToStorage(File(pickedFile.path));

    // Send a message with the image URL to Firestore
    sendMessageWithImage(imageUrl);
  }
}

Future<String> uploadImageToStorage(File imageFile) async {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final Reference ref = storage.ref().child('chat_images/${DateTime.now().toString()}');
  final UploadTask uploadTask = ref.putFile(imageFile);
  final TaskSnapshot taskSnapshot = await uploadTask;
  final imageUrl = await taskSnapshot.ref.getDownloadURL();
  return imageUrl;
}

 

final FirebaseFirestore firestore = FirebaseFirestore.instance;
String recordFilePath="";
void sendMessageWithImage(String imageUrl) async{

   _code.doc(widget.news).collection("message").add({
      'text': "",
      'timestamp': FieldValue.serverTimestamp(),
       'image_url': imageUrl,
       "audio":"",
       "id":controllers.action
    });

}
  bool isRecording = false;
    void startRecord() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      recordFilePath = await getFilePath();

      RecordMp3.instance.start(recordFilePath, (type) {
        setState(() {});
      });
    } else {}
    setState(() {});
  }
 bool isSending = false;
bool  isPlayingMsg = false;
  void stopRecord() async {
    bool s = RecordMp3.instance.stop();
    if (s) {
      setState(() {
        isSending = true;
      });
      await uploadAudio();

      setState(() {
        isPlayingMsg = false;
      });
    }
  }
  uploadAudio() async{
      final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference firebaseStorageRef = storage
        .ref()
        .child(
            'profilepics/audio${DateTime.now().millisecondsSinceEpoch.toString()}}.jpg');

   UploadTask task = firebaseStorageRef.putFile(File(recordFilePath));
    // task.onComplete.then((value) async {
      print('##############done#########');
        final TaskSnapshot taskSnapshot = await task;
      var audioURL = await taskSnapshot.ref.getDownloadURL();
      String strVal = audioURL.toString();
      await sendAudioMsg(strVal);
    // })
    // .catchError((e) {
    //   print(e);
    // });
  }
    Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }
    int i = 0;
  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return sdPath + "/test_${i++}.mp3";
  }


  sendAudioMsg(String audioMsg) async {

    if (audioMsg.isNotEmpty) {
      _code.doc(widget.news).collection("message").add({
      'text': "",
      'timestamp': FieldValue.serverTimestamp(),
       'image_url': "",
       "audio":audioMsg,
       "id":controllers.action
    })
      .then((value) {
        setState(() {
          isSending = false;
        });
      });

    } else {
      print("Hello");
    }
  }
   Future _loadFile(String url) async {
    // Uint8List bytes = Uint8List.fromList(utf8.encode(url));
    // // final bytes = await readBytes(url);
    // final dir = await getApplicationDocumentsDirectory();
    // final file = File('${dir.path}/audio.mp3');

    // await file.writeAsBytes(bytes);
     await play(url);
    // if (await file.exists()) {
    //   setState(() {
    //     recordFilePath = file.path;
    //     isPlayingMsg = true;
    //     print(isPlayingMsg);
    //   });
    //   await play(url);
    //   setState(() {
    //     isPlayingMsg = false;
    //     print(isPlayingMsg);
    //   });
    // }
  }

    Future<void> play(String url) async {
            AudioPlayer audioPlayer = AudioPlayer();
 await audioPlayer.play(UrlSource(recordFilePath));
  // try {
  //   final response = await http.get(Uri.parse(recordFilePath));
  //   if (response.statusCode == 200) {
  //     final audioBytes = response.bodyBytes;

  //     // Initialize the audio player
  //     AudioPlayer audioPlayer = AudioPlayer();

  //     // Play the audio from bytes
  //     await audioPlayer.play(audioBytes)

  //     // You can also add additional playback controls or display playback status as needed.
  //   } else {
  //     print('Failed to fetch audio: ${response.statusCode}');
  //   }
  // } catch (e) {
  //   print('Error: $e');
  // }



  //   if (recordFilePath != null && File(recordFilePath).existsSync()) {
  //     AudioPlayer audioPlayer = AudioPlayer();
  //     await audioPlayer.play(UrlSource(recordFilePath));
  //   }
  }

         final Controllerss controllers= Get.put(Controllerss()); 
  void getShared()async {
  prefs = await SharedPreferences.getInstance();
  controllers.action = await prefs!.getString('action');
}

  @override
  Widget build(BuildContext context) {
      @override
void initState() {
    // TODO: implement initState
    super.initState();
getShared();

  }

        

    return Scaffold(
      appBar: AppBar(title: Text("Chat Screen ${news} Long press to stop recording "),
      automaticallyImplyLeading: false,
      
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:  _code.doc(widget.news).collection("message").orderBy('timestamp').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final messages = snapshot.data!.docs;
                // List<Widget> messageWidgets = [];
                // for (var message in messages) {
                //   final messageText = message['text'];
                //   final messageWidget = MessageWidget(messageText);
                //   messageWidgets.add(messageWidget);
                // }
                return 
              ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
            final userDoc = messages[index];
                  // final messageData = messages[index].data();
                final isImageMessage = userDoc['image_url'] ;
                final audio = userDoc["audio"];
                
                  if(isImageMessage != ""){
                return   Column(
                  children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
            height: 500,width: 500,
                       decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(userDoc["image_url"]),fit: BoxFit.contain)),
            
            ),
                ),
                
                  ],
                );
                  }
                  else if(audio != "") {
                return
                 Padding(
                  padding: EdgeInsets.only(
            top: 8,
                  
            ),
                  child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
            color: 
               isPlayingMsg==false ?
                Colors.orangeAccent : Colors.purple ,
            borderRadius: BorderRadius.circular(10),
            ),
            child: GestureDetector(
              onTap: () {
                 //         _loadFile(audio);
                
                 setState(() {
                   isPlayingMsg =true;
                 });
                
                
                 audioPlayer.play(UrlSource(audio));
              },
              onDoubleTap: () {
                setState(() {
                   isPlayingMsg = false;
                });
               
                stopRecord();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(isPlayingMsg==false
                       ? Icons.cancel : Icons.play_arrow),
                      // Text(
                      //   'Audio-${doc['timestamp']}',
                      //   maxLines: 10,
                      // ),
                    ],
                  ),
                  // Text(
                  //   date + " " + hour.toString() + ":" + min.toString() + ampm,
                  //   style: TextStyle(fontSize: 10),
                  // )
                ],
              )),
                  ),
                );
                
                  }
                
                  else {
                 return   Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Container(
                 
                     color:userDoc["id"] == controllers.action ? Colors.greenAccent:Colors.orange,
                     child: Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: Text( userDoc['text'],textAlign: userDoc["id"] == controllers.action ? TextAlign.right : TextAlign.left,style: TextStyle(fontSize: 30,),),
                     )),
                 );
                  }
                
                
                  
                  
                  
                  //  isImageMessage != ""
                  //     ? 
                  //     Container(
                  //       height: 300,
                  //       width: MediaQuery.of(context).size.width,
                  //       child: Image.network(userDoc['image_url'],fit: BoxFit.fill,))
                  //     : Text(userDoc['text']);
                },
                  );
                },
              
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_textController.text);
                  },
                ),
                  IconButton(
                  icon: Icon(Icons.browse_gallery),
                  onPressed: () {
                   pickImageFromGallery();
                  },
                ),
      
                 IconButton(
                  icon: Icon(Icons.camera),
                  onPressed: () {
                   pickImageFromCamera();
                  },
                ),
              
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _clearMessages();
                  },
                ),
               Container(
                            height: 40,
                            margin: EdgeInsets.fromLTRB(5, 5, 10, 5),
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                  color: isRecording
                                      ? Colors.white
                                      : Colors.black12,
                                  spreadRadius: 4)
                            ], color: Colors.pink, shape: BoxShape.circle),
                            child: GestureDetector(
                              onTap: () {
                           Get.snackbar(
        "Success",
        "Recording in Progress,Kindly long press button again to stop recording",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(milliseconds: 1000)
      );
                                startRecord();
                                setState(() {
                                  isRecording = true;
                                });
                              },
                             onLongPressEnd: (details) {
                                     Get.snackbar(
        "End",
        "Recording End",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
         duration: Duration(milliseconds: 1000)
      );
                                stopRecord();
                                setState(() {
                                  isRecording = false;
                                });
                              },
                              child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: isRecording == false ? 
                                  Icon(
                                    Icons.mic,
                                    color: Colors.white,
                                    size: 20,
                                  ):
                                     Icon(
                                    Icons.mic_external_off,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                
                                  
                                  ),
                            )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  final String messageText;

  MessageWidget(this.messageText);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        messageText,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}







